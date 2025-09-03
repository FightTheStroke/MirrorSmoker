//
//  FeatureStore.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData
import os.log

struct CoachFeatures: Codable {
    let minutesSinceLastCig: Double
    let hour: Int
    let stepsLast3h: Double
    let sleptShortLastNight: Bool
    let usedNRTLast12h: Bool
    let daysSinceQuitDate: Int
    let currentStreak: Int
    let avgCigarettesPerDay: Double
    let hasActiveTags: Bool
    let timeOfDayRisk: Double // 0-1 based on historical patterns
    let mindfulSessionsToday: Int
    
    var asDictionary: [String: Any] {
        return [
            "minutesSinceLastCig": minutesSinceLastCig,
            "hour": hour,
            "stepsLast3h": stepsLast3h,
            "sleptShortLastNight": sleptShortLastNight ? 1 : 0,
            "usedNRTLast12h": usedNRTLast12h ? 1 : 0,
            "daysSinceQuitDate": daysSinceQuitDate,
            "currentStreak": currentStreak,
            "avgCigarettesPerDay": avgCigarettesPerDay,
            "hasActiveTags": hasActiveTags ? 1 : 0,
            "timeOfDayRisk": timeOfDayRisk,
            "mindfulSessionsToday": mindfulSessionsToday
        ]
    }
}

@MainActor
class FeatureStore: ObservableObject {
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "FeatureStore")
    private let healthKitManager = HealthKitManager.shared
    
    static let shared = FeatureStore()
    private init() {}
    
    func collect(
        from modelContext: ModelContext,
        userProfile: UserProfile? = nil
    ) async -> CoachFeatures {
        do {
            // Get all cigarettes sorted by timestamp
            let allDescriptor = FetchDescriptor<Cigarette>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allCigarettes = try modelContext.fetch(allDescriptor)
            
            // Get user profile if not provided
            let profile = userProfile ?? {
                let profileDescriptor = FetchDescriptor<UserProfile>()
                return try? modelContext.fetch(profileDescriptor).first
            }()
            
            // Calculate features
            let minutesSinceLastCig = calculateMinutesSinceLastCigarette(cigarettes: allCigarettes)
            let hour = Calendar.current.component(.hour, from: Date())
            let stepsLast3h = await getStepsLast3Hours()
            let sleptShortLastNight = await getSleptShortLastNight()
            let usedNRTLast12h = await getUsedNRTLast12h()
            let daysSinceQuitDate = calculateDaysSinceQuitDate(profile: profile)
            let currentStreak = calculateCurrentStreak(cigarettes: allCigarettes)
            let avgCigarettesPerDay = calculateDailyAverage(cigarettes: allCigarettes)
            let hasActiveTags = checkHasActiveTags(cigarettes: allCigarettes)
            let timeOfDayRisk = calculateTimeOfDayRisk(hour: hour, cigarettes: allCigarettes)
            let mindfulSessionsToday = await getMindfulSessionsToday()
            
            return CoachFeatures(
                minutesSinceLastCig: minutesSinceLastCig,
                hour: hour,
                stepsLast3h: stepsLast3h,
                sleptShortLastNight: sleptShortLastNight,
                usedNRTLast12h: usedNRTLast12h,
                daysSinceQuitDate: daysSinceQuitDate,
                currentStreak: currentStreak,
                avgCigarettesPerDay: avgCigarettesPerDay,
                hasActiveTags: hasActiveTags,
                timeOfDayRisk: timeOfDayRisk,
                mindfulSessionsToday: mindfulSessionsToday
            )
            
        } catch {
            logger.error("Failed to collect features: \(error.localizedDescription)")
            return fallbackFeatures()
        }
    }
    
    // MARK: - Feature Calculations
    
    private func calculateMinutesSinceLastCigarette(cigarettes: [Cigarette]) -> Double {
        guard let lastCigarette = cigarettes.first else {
            return 1440.0 // 24 hours if no cigarettes
        }
        
        let minutesSince = Date().timeIntervalSince(lastCigarette.timestamp) / 60.0
        return max(0, minutesSince)
    }
    
    private func calculateDaysSinceQuitDate(profile: UserProfile?) -> Int {
        guard let quitDate = profile?.quitDate else { return 0 }
        
        let daysSince = Calendar.current.dateComponents([.day], from: quitDate, to: Date()).day ?? 0
        return max(0, daysSince)
    }
    
    private func calculateCurrentStreak(cigarettes: [Cigarette]) -> Int {
        guard !cigarettes.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check each day backwards until we find a day with cigarettes
        for dayOffset in 0..<30 { // Check max 30 days
            let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: currentDate)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
            
            let dayHasCigarettes = cigarettes.contains { cigarette in
                cigarette.timestamp >= checkDate && cigarette.timestamp < nextDate
            }
            
            if dayHasCigarettes {
                break
            } else {
                streak += 1
            }
        }
        
        return streak
    }
    
    private func calculateDailyAverage(cigarettes: [Cigarette]) -> Double {
        guard !cigarettes.isEmpty else { return 0.0 }
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = cigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        
        return Double(recentCigarettes.count) / 30.0
    }
    
    private func checkHasActiveTags(cigarettes: [Cigarette]) -> Bool {
        let recentCigarettes = cigarettes.prefix(5) // Last 5 cigarettes
        return recentCigarettes.contains { cigarette in
            cigarette.tags?.isEmpty == false
        }
    }
    
    private func calculateTimeOfDayRisk(hour: Int, cigarettes: [Cigarette]) -> Double {
        // Analyze historical smoking patterns for this hour
        let thisHourCigarettes = cigarettes.filter { cigarette in
            Calendar.current.component(.hour, from: cigarette.timestamp) == hour
        }
        
        let totalCigarettes = cigarettes.count
        guard totalCigarettes > 0 else { return 0.5 }
        
        let riskRatio = Double(thisHourCigarettes.count) / Double(totalCigarettes)
        
        // Normalize to 0-1 range with some baseline risk
        return min(1.0, max(0.1, riskRatio * 24.0)) // 24 hours normalization
    }
    
    // MARK: - HealthKit Integration
    
    private func getStepsLast3Hours() async -> Double {
        do {
            return try await healthKitManager.getStepCountLast3Hours()
        } catch {
            logger.debug("Could not get step count, using fallback: \(error.localizedDescription)")
            return 1500.0 // Reasonable fallback
        }
    }
    
    private func getSleptShortLastNight() async -> Bool {
        do {
            return try await healthKitManager.didSleepPoorlyLastNight()
        } catch {
            logger.debug("Could not get sleep data, using fallback: \(error.localizedDescription)")
            return false
        }
    }
    
    private func getUsedNRTLast12h() async -> Bool {
        do {
            return try await healthKitManager.didUseNRTRecently()
        } catch {
            logger.debug("Could not get medication data, using fallback: \(error.localizedDescription)")
            return false
        }
    }
    
    private func getMindfulSessionsToday() async -> Int {
        do {
            return try await healthKitManager.getMindfulSessionsToday()
        } catch {
            logger.debug("Could not get mindful sessions data, using fallback: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Fallback
    
    private func fallbackFeatures() -> CoachFeatures {
        return CoachFeatures(
            minutesSinceLastCig: 120.0,
            hour: Calendar.current.component(.hour, from: Date()),
            stepsLast3h: 1500.0,
            sleptShortLastNight: false,
            usedNRTLast12h: false,
            daysSinceQuitDate: 0,
            currentStreak: 0,
            avgCigarettesPerDay: 10.0,
            hasActiveTags: false,
            timeOfDayRisk: 0.5,
            mindfulSessionsToday: 0
        )
    }
}
