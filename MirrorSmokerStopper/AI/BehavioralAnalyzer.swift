//
//  BehavioralAnalyzer.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData
import HealthKit
import os.log

/// AI-powered behavioral analysis system for smoking patterns
@MainActor
final class BehavioralAnalyzer: ObservableObject, Sendable {
    static let shared = BehavioralAnalyzer()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "BehavioralAnalyzer")
    private let healthKitManager = HealthKitManager.shared
    
    // MARK: - Analysis Results
    
    struct BehavioralInsight: Codable, Sendable, Identifiable {
        let id = UUID()
        let type: InsightType
        let title: String
        let description: String
        let confidence: Double // 0.0 to 1.0
        let actionableRecommendations: [String]
        let riskScore: Double // 0.0 = low risk, 1.0 = high risk
        let detectedAt: Date
        let supportingData: [String: Double]
    }
    
    enum InsightType: String, CaseIterable, Codable {
        case timePattern = "time_pattern"
        case triggerPattern = "trigger_pattern"
        case streakBreaker = "streak_breaker"
        case socialInfluence = "social_influence"
        case environmentalTrigger = "environmental_trigger"
        case emotionalTrigger = "emotional_trigger"
        case habitualRoutine = "habitual_routine"
        case stressResponse = "stress_response"
        case replacementBehavior = "replacement_behavior"
        case progressRegression = "progress_regression"
    }
    
    struct SmokingPattern: Codable, Sendable {
        let peakHours: [Int]
        let peakDays: [Int] // 1-7, Sunday = 1
        let averageInterval: TimeInterval
        let mostCommonTriggers: [String]
        let environmentalFactors: [String]
        let seasonalVariations: [String: Double]
        let stressCorrelation: Double
        let socialContexts: [String]
        let replacementAttempts: [String]
        let progressTrends: TrendAnalysis
    }
    
    struct TrendAnalysis: Codable, Sendable {
        let weeklyChange: Double // % change in cigarettes per week
        let monthlyChange: Double // % change in cigarettes per month
        let streakLengths: [Int] // Days without smoking
        let averageStreakLength: Double
        let longestStreak: Int
        let relapsePatterns: [RelapsePattern]
        let complianceRate: Double // % of days meeting targets
    }
    
    struct RelapsePattern: Codable, Sendable {
        let trigger: String
        let timeOfDay: Int
        let dayOfWeek: Int
        let frequency: Int
        let severity: RelapseSeverity
    }
    
    enum RelapseSeverity: String, CaseIterable, Codable {
        case minor = "minor" // 1-2 cigarettes over target
        case moderate = "moderate" // 3-5 cigarettes over target
        case major = "major" // >5 cigarettes over target
    }
    
    // Published state for UI
    @Published var currentInsights: [BehavioralInsight] = []
    @Published var smokingPattern: SmokingPattern?
    @Published var isAnalyzing = false
    
    private init() {}
    
    // MARK: - Main Analysis Methods
    
    /// Perform comprehensive behavioral analysis
    func performFullAnalysis(
        modelContext: ModelContext,
        userProfile: UserProfile?
    ) async -> [BehavioralInsight] {
        
        logger.info("Starting comprehensive behavioral analysis")
        
        await MainActor.run {
            isAnalyzing = true
        }
        
        do {
            // Fetch cigarette data
            let descriptor = FetchDescriptor<Cigarette>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let cigarettes = try modelContext.fetch(descriptor)
            
            // Analyze different behavioral aspects
            let timeInsights = await analyzeTimePatterns(cigarettes: cigarettes)
            let triggerInsights = await analyzeTriggerPatterns(cigarettes: cigarettes)
            let streakInsights = await analyzeStreakPatterns(cigarettes: cigarettes, profile: userProfile)
            let socialInsights = await analyzeSocialPatterns(cigarettes: cigarettes)
            let environmentalInsights = await analyzeEnvironmentalPatterns(cigarettes: cigarettes)
            let progressInsights = await analyzeProgressPatterns(cigarettes: cigarettes, profile: userProfile)
            
            // Combine all insights
            let allInsights = timeInsights + triggerInsights + streakInsights + 
                             socialInsights + environmentalInsights + progressInsights
            
            // Create smoking pattern summary
            let pattern = await createSmokingPattern(cigarettes: cigarettes)
            
            await MainActor.run {
                currentInsights = allInsights.sorted { $0.riskScore > $1.riskScore }
                smokingPattern = pattern
                isAnalyzing = false
            }
            
            logger.info("Behavioral analysis completed with \(allInsights.count) insights")
            return allInsights
            
        } catch {
            logger.error("Failed to perform behavioral analysis: \(error.localizedDescription)")
            
            await MainActor.run {
                isAnalyzing = false
            }
            
            return []
        }
    }
    
    /// Get high-risk behavioral insights for immediate action
    func getHighRiskInsights() -> [BehavioralInsight] {
        return currentInsights.filter { $0.riskScore > 0.7 }
    }
    
    /// Get actionable insights for current context
    func getContextualInsights(
        currentHour: Int,
        dayOfWeek: Int,
        recentCigarettes: [Cigarette]
    ) -> [BehavioralInsight] {
        
        return currentInsights.filter { insight in
            // Filter based on current context relevance
            switch insight.type {
            case .timePattern:
                return insight.supportingData["peak_hour"] == Double(currentHour)
            case .triggerPattern:
                return recentCigarettes.count > 0
            case .streakBreaker:
                return recentCigarettes.isEmpty // Relevant when not smoking
            case .socialInfluence:
                return [6, 7, 1].contains(dayOfWeek) // Weekends
            case .stressResponse:
                return [9, 13, 17, 21].contains(currentHour) // Common stress times
            default:
                return insight.riskScore > 0.5
            }
        }
    }
    
    // MARK: - Pattern Analysis Methods
    
    private func analyzeTimePatterns(cigarettes: [Cigarette]) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        // Analyze hourly patterns
        let hourCounts = Dictionary(grouping: cigarettes) {
            Calendar.current.component(.hour, from: $0.timestamp)
        }.mapValues { $0.count }
        
        let totalCigarettes = cigarettes.count
        guard totalCigarettes > 0 else { return insights }
        
        // Find peak hours (more than 15% of total smoking)
        let peakHours = hourCounts.filter { $0.value > totalCigarettes / 7 } // ~15%
            .sorted { $0.value > $1.value }
            .prefix(3)
        
        if !peakHours.isEmpty {
            let mainPeakHour = peakHours.first!.key
            let peakPercentage = Double(peakHours.first!.value) / Double(totalCigarettes) * 100
            
            insights.append(BehavioralInsight(
                type: .timePattern,
                title: NSLocalizedString("behavioral.insight.time.peak.title", comment: "Peak smoking time detected"),
                description: String(format: NSLocalizedString("behavioral.insight.time.peak.description", comment: "You smoke %.0f%% of your cigarettes around %d:00"), peakPercentage, mainPeakHour),
                confidence: min(0.95, peakPercentage / 50.0),
                actionableRecommendations: [
                    String(format: NSLocalizedString("behavioral.recommendation.time.avoid", comment: "Plan alternative activities for %d:00-%d:00"), mainPeakHour, mainPeakHour + 1),
                    NSLocalizedString("behavioral.recommendation.time.replacement", comment: "Practice deep breathing during peak craving times"),
                    NSLocalizedString("behavioral.recommendation.time.schedule", comment: "Schedule important tasks during your peak smoking hours")
                ],
                riskScore: min(0.9, peakPercentage / 40.0),
                detectedAt: Date(),
                supportingData: [
                    "peak_hour": Double(mainPeakHour),
                    "peak_percentage": peakPercentage,
                    "total_cigarettes": Double(totalCigarettes)
                ]
            ))
        }
        
        // Analyze weekly patterns
        let weekdayAvg = cigarettes.filter { 
            let weekday = Calendar.current.component(.weekday, from: $0.timestamp)
            return weekday >= 2 && weekday <= 6 // Mon-Fri
        }.count / max(1, getWeeksInData(cigarettes))
        
        let weekendAvg = cigarettes.filter {
            let weekday = Calendar.current.component(.weekday, from: $0.timestamp)
            return weekday == 1 || weekday == 7 // Sun, Sat
        }.count / max(1, getWeekendsInData(cigarettes))
        
        if weekendAvg > weekdayAvg + 2 {
            insights.append(BehavioralInsight(
                type: .socialInfluence,
                title: NSLocalizedString("behavioral.insight.weekend.title", comment: "Weekend smoking spike"),
                description: String(format: NSLocalizedString("behavioral.insight.weekend.description", comment: "You smoke %d more cigarettes on weekends"), weekendAvg - weekdayAvg),
                confidence: 0.8,
                actionableRecommendations: [
                    NSLocalizedString("behavioral.recommendation.weekend.plan", comment: "Plan smoke-free weekend activities"),
                    NSLocalizedString("behavioral.recommendation.weekend.social", comment: "Identify and avoid smoking social situations"),
                    NSLocalizedString("behavioral.recommendation.weekend.routine", comment: "Maintain weekday routines on weekends")
                ],
                riskScore: min(0.8, Double(weekendAvg - weekdayAvg) / 10.0),
                detectedAt: Date(),
                supportingData: [
                    "weekday_avg": Double(weekdayAvg),
                    "weekend_avg": Double(weekendAvg),
                    "difference": Double(weekendAvg - weekdayAvg)
                ]
            ))
        }
        
        return insights
    }
    
    private func analyzeTriggerPatterns(cigarettes: [Cigarette]) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        // Analyze tag patterns (triggers)
        let tagCounts = cigarettes.compactMap { $0.tags }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { counts, tag in
                counts[tag.name, default: 0] += 1
            }
        
        let totalWithTags = cigarettes.filter { $0.tags?.isEmpty == false }.count
        guard totalWithTags > 0 else { return insights }
        
        // Find dominant triggers (>20% of tagged cigarettes)
        let dominantTriggers = tagCounts.filter { $0.value > totalWithTags / 5 }
            .sorted { $0.value > $1.value }
        
        for (trigger, count) in dominantTriggers.prefix(3) {
            let percentage = Double(count) / Double(totalWithTags) * 100
            
            insights.append(BehavioralInsight(
                type: .triggerPattern,
                title: String(format: NSLocalizedString("behavioral.insight.trigger.title", comment: "Trigger pattern: %@"), trigger),
                description: String(format: NSLocalizedString("behavioral.insight.trigger.description", comment: "%@ triggers %.0f%% of your smoking"), trigger, percentage),
                confidence: min(0.9, percentage / 50.0),
                actionableRecommendations: generateTriggerRecommendations(trigger: trigger),
                riskScore: min(0.9, percentage / 30.0),
                detectedAt: Date(),
                supportingData: [
                    "trigger": Double(count),
                    "percentage": percentage,
                    "total_tagged": Double(totalWithTags)
                ]
            ))
        }
        
        return insights
    }
    
    private func analyzeStreakPatterns(cigarettes: [Cigarette], profile: UserProfile?) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        let streaks = calculateStreaks(cigarettes: cigarettes)
        guard !streaks.isEmpty else { return insights }
        
        let averageStreak = Double(streaks.reduce(0, +)) / Double(streaks.count)
        let longestStreak = streaks.max() ?? 0
        
        // Analyze streak breaking patterns
        if averageStreak > 0 {
            let relapseAnalysis = analyzeRelapsePatterns(cigarettes: cigarettes, streaks: streaks)
            
            if !relapseAnalysis.isEmpty {
                let commonPattern = relapseAnalysis.first!
                
                insights.append(BehavioralInsight(
                    type: .streakBreaker,
                    title: NSLocalizedString("behavioral.insight.streak.title", comment: "Streak breaking pattern"),
                    description: String(format: NSLocalizedString("behavioral.insight.streak.description", comment: "Your streaks often end due to %@ at %d:00"), commonPattern.trigger, commonPattern.timeOfDay),
                    confidence: 0.7,
                    actionableRecommendations: [
                        String(format: NSLocalizedString("behavioral.recommendation.streak.prepare", comment: "Prepare coping strategies for %@"), commonPattern.trigger),
                        String(format: NSLocalizedString("behavioral.recommendation.streak.avoid", comment: "Avoid %@ situations at %d:00"), commonPattern.trigger, commonPattern.timeOfDay),
                        NSLocalizedString("behavioral.recommendation.streak.support", comment: "Have support ready during vulnerable times")
                    ],
                    riskScore: min(0.8, Double(commonPattern.frequency) / 10.0),
                    detectedAt: Date(),
                    supportingData: [
                        "average_streak": averageStreak,
                        "longest_streak": Double(longestStreak),
                        "relapse_frequency": Double(commonPattern.frequency)
                    ]
                ))
            }
        }
        
        return insights
    }
    
    private func analyzeSocialPatterns(cigarettes: [Cigarette]) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        // Look for social smoking patterns in tags
        let socialTags = ["social", "friends", "party", "bar", "restaurant", "work_break", "meeting"]
        let socialCigarettes = cigarettes.filter { cigarette in
            cigarette.tags?.contains { tag in
                socialTags.contains(tag.name.lowercased())
            } ?? false
        }
        
        if socialCigarettes.count > cigarettes.count / 4 { // More than 25% social
            let socialPercentage = Double(socialCigarettes.count) / Double(cigarettes.count) * 100
            
            insights.append(BehavioralInsight(
                type: .socialInfluence,
                title: NSLocalizedString("behavioral.insight.social.title", comment: "Social smoking pattern"),
                description: String(format: NSLocalizedString("behavioral.insight.social.description", comment: "%.0f%% of your smoking happens in social situations"), socialPercentage),
                confidence: 0.8,
                actionableRecommendations: [
                    NSLocalizedString("behavioral.recommendation.social.alternative", comment: "Find non-smoking social activities"),
                    NSLocalizedString("behavioral.recommendation.social.support", comment: "Tell friends about your quit plan"),
                    NSLocalizedString("behavioral.recommendation.social.escape", comment: "Practice polite ways to decline smoking invitations")
                ],
                riskScore: min(0.7, socialPercentage / 50.0),
                detectedAt: Date(),
                supportingData: [
                    "social_percentage": socialPercentage,
                    "social_count": Double(socialCigarettes.count)
                ]
            ))
        }
        
        return insights
    }
    
    private func analyzeEnvironmentalPatterns(cigarettes: [Cigarette]) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        // Analyze location-based patterns if available
        let environmentalTags = ["home", "work", "car", "outside", "balcony", "kitchen", "office"]
        let locationCounts = cigarettes.compactMap { cigarette in
            cigarette.tags?.first { tag in
                environmentalTags.contains(tag.name.lowercased())
            }?.name
        }.reduce(into: [String: Int]()) { counts, location in
            counts[location, default: 0] += 1
        }
        
        let totalWithLocation = locationCounts.values.reduce(0, +)
        guard totalWithLocation > 0 else { return insights }
        
        let dominantLocation = locationCounts.max { $0.value < $1.value }
        if let (location, count) = dominantLocation, count > totalWithLocation / 3 {
            let percentage = Double(count) / Double(totalWithLocation) * 100
            
            insights.append(BehavioralInsight(
                type: .environmentalTrigger,
                title: String(format: NSLocalizedString("behavioral.insight.environment.title", comment: "Environmental trigger: %@"), location),
                description: String(format: NSLocalizedString("behavioral.insight.environment.description", comment: "%.0f%% of your smoking happens at %@"), percentage, location),
                confidence: 0.8,
                actionableRecommendations: [
                    String(format: NSLocalizedString("behavioral.recommendation.environment.modify", comment: "Modify your %@ environment to reduce triggers"), location),
                    String(format: NSLocalizedString("behavioral.recommendation.environment.avoid", comment: "Limit time spent in %@ when possible"), location),
                    NSLocalizedString("behavioral.recommendation.environment.replacement", comment: "Create new positive associations with this space")
                ],
                riskScore: min(0.8, percentage / 40.0),
                detectedAt: Date(),
                supportingData: [
                    "location_percentage": percentage,
                    "location_count": Double(count)
                ]
            ))
        }
        
        return insights
    }
    
    private func analyzeProgressPatterns(cigarettes: [Cigarette], profile: UserProfile?) async -> [BehavioralInsight] {
        var insights: [BehavioralInsight] = []
        
        guard let profile = profile, cigarettes.count >= 7 else { return insights }
        
        // Analyze recent progress (last 7 vs previous 7 days)
        let now = Date()
        let lastWeek = cigarettes.filter { 
            $0.timestamp > now.addingTimeInterval(-7 * 24 * 3600)
        }.count
        
        let previousWeek = cigarettes.filter {
            $0.timestamp > now.addingTimeInterval(-14 * 24 * 3600) &&
            $0.timestamp <= now.addingTimeInterval(-7 * 24 * 3600)
        }.count
        
        let weeklyTarget = profile.todayTarget(dailyAverage: profile.dailyAverage) * 7
        
        // Check for regression
        if lastWeek > previousWeek + 3 && lastWeek > weeklyTarget {
            let increase = lastWeek - previousWeek
            
            insights.append(BehavioralInsight(
                type: .progressRegression,
                title: NSLocalizedString("behavioral.insight.regression.title", comment: "Progress regression detected"),
                description: String(format: NSLocalizedString("behavioral.insight.regression.description", comment: "Smoking increased by %d cigarettes this week"), increase),
                confidence: 0.9,
                actionableRecommendations: [
                    NSLocalizedString("behavioral.recommendation.regression.reassess", comment: "Review what changed in your routine this week"),
                    NSLocalizedString("behavioral.recommendation.regression.support", comment: "Reach out for additional support"),
                    NSLocalizedString("behavioral.recommendation.regression.gentle", comment: "Be patient with yourself - setbacks are normal")
                ],
                riskScore: min(0.9, Double(increase) / 10.0),
                detectedAt: Date(),
                supportingData: [
                    "last_week": Double(lastWeek),
                    "previous_week": Double(previousWeek),
                    "increase": Double(increase),
                    "target": Double(weeklyTarget)
                ]
            ))
        }
        
        return insights
    }
    
    // MARK: - Helper Methods
    
    private func createSmokingPattern(cigarettes: [Cigarette]) async -> SmokingPattern {
        let hourCounts = Dictionary(grouping: cigarettes) {
            Calendar.current.component(.hour, from: $0.timestamp)
        }.mapValues { $0.count }
        
        let dayCounts = Dictionary(grouping: cigarettes) {
            Calendar.current.component(.weekday, from: $0.timestamp)
        }.mapValues { $0.count }
        
        let peakHours = hourCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        let peakDays = dayCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        let intervals = calculateIntervals(cigarettes: cigarettes)
        let averageInterval = intervals.isEmpty ? 0 : intervals.reduce(0, +) / Double(intervals.count)
        
        let triggerCounts = cigarettes.compactMap { $0.tags }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { counts, tag in
                counts[tag.name, default: 0] += 1
            }
        
        let commonTriggers = triggerCounts.sorted { $0.value > $1.value }
            .prefix(5).map { $0.key }
        
        let streaks = calculateStreaks(cigarettes: cigarettes)
        let trends = TrendAnalysis(
            weeklyChange: calculateWeeklyChange(cigarettes: cigarettes),
            monthlyChange: calculateMonthlyChange(cigarettes: cigarettes),
            streakLengths: streaks,
            averageStreakLength: streaks.isEmpty ? 0 : Double(streaks.reduce(0, +)) / Double(streaks.count),
            longestStreak: streaks.max() ?? 0,
            relapsePatterns: analyzeRelapsePatterns(cigarettes: cigarettes, streaks: streaks),
            complianceRate: 0.8 // Would be calculated based on target adherence
        )
        
        return SmokingPattern(
            peakHours: Array(peakHours),
            peakDays: Array(peakDays),
            averageInterval: averageInterval,
            mostCommonTriggers: Array(commonTriggers),
            environmentalFactors: [], // Would extract from location tags
            seasonalVariations: [:], // Would require longer-term data
            stressCorrelation: 0.6, // Would correlate with stress indicators
            socialContexts: [], // Would extract from social tags
            replacementAttempts: [], // Would track successful alternatives
            progressTrends: trends
        )
    }
    
    private func calculateIntervals(cigarettes: [Cigarette]) -> [TimeInterval] {
        guard cigarettes.count > 1 else { return [] }
        
        let sortedCigarettes = cigarettes.sorted { $0.timestamp < $1.timestamp }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedCigarettes.count {
            let interval = sortedCigarettes[i].timestamp.timeIntervalSince(sortedCigarettes[i-1].timestamp)
            intervals.append(interval)
        }
        
        return intervals
    }
    
    private func calculateStreaks(cigarettes: [Cigarette]) -> [Int] {
        guard !cigarettes.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let sortedCigarettes = cigarettes.sorted { $0.timestamp < $1.timestamp }
        
        var streaks: [Int] = []
        var currentStreak = 0
        var lastDate: Date?
        
        let dateRange = generateDateRange(from: sortedCigarettes.first!.timestamp, to: Date())
        
        for date in dateRange {
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let cigarettesThisDay = sortedCigarettes.filter { 
                $0.timestamp >= dayStart && $0.timestamp < dayEnd
            }
            
            if cigarettesThisDay.isEmpty {
                currentStreak += 1
            } else {
                if currentStreak > 0 {
                    streaks.append(currentStreak)
                    currentStreak = 0
                }
            }
        }
        
        if currentStreak > 0 {
            streaks.append(currentStreak)
        }
        
        return streaks
    }
    
    private func analyzeRelapsePatterns(cigarettes: [Cigarette], streaks: [Int]) -> [RelapsePattern] {
        // Simplified implementation - would analyze the cigarettes that broke streaks
        return []
    }
    
    private func generateTriggerRecommendations(trigger: String) -> [String] {
        let lowercaseTrigger = trigger.lowercased()
        
        switch lowercaseTrigger {
        case "stress":
            return [
                NSLocalizedString("behavioral.recommendation.stress.breathing", comment: "Practice 4-7-8 breathing when stressed"),
                NSLocalizedString("behavioral.recommendation.stress.exercise", comment: "Take a 5-minute walk when feeling stressed"),
                NSLocalizedString("behavioral.recommendation.stress.mindfulness", comment: "Use a mindfulness app for stress management")
            ]
        case "social":
            return [
                NSLocalizedString("behavioral.recommendation.social.alternative", comment: "Find non-smoking social activities"),
                NSLocalizedString("behavioral.recommendation.social.support", comment: "Tell friends about your quit plan"),
                NSLocalizedString("behavioral.recommendation.social.escape", comment: "Practice polite ways to decline smoking invitations")
            ]
        case "boredom":
            return [
                NSLocalizedString("behavioral.recommendation.boredom.activities", comment: "Keep a list of 5-minute activities handy"),
                NSLocalizedString("behavioral.recommendation.boredom.hobby", comment: "Start a new hobby that keeps your hands busy"),
                NSLocalizedString("behavioral.recommendation.boredom.productive", comment: "Turn boredom into productive micro-tasks")
            ]
        default:
            return [
                String(format: NSLocalizedString("behavioral.recommendation.generic.identify", comment: "Identify early warning signs of %@ triggers"), trigger),
                String(format: NSLocalizedString("behavioral.recommendation.generic.alternative", comment: "Create healthy alternatives for %@ situations"), trigger),
                String(format: NSLocalizedString("behavioral.recommendation.generic.avoid", comment: "Avoid or minimize %@ triggers when possible"), trigger)
            ]
        }
    }
    
    // Utility methods
    private func getWeeksInData(_ cigarettes: [Cigarette]) -> Int {
        guard let earliest = cigarettes.map({ $0.timestamp }).min(),
              let latest = cigarettes.map({ $0.timestamp }).max() else { return 1 }
        
        return max(1, Int(latest.timeIntervalSince(earliest) / (7 * 24 * 3600)))
    }
    
    private func getWeekendsInData(_ cigarettes: [Cigarette]) -> Int {
        return max(1, getWeeksInData(cigarettes) * 2)
    }
    
    private func calculateWeeklyChange(cigarettes: [Cigarette]) -> Double {
        // Simplified - would calculate actual weekly change
        return -5.0 // Placeholder for 5% weekly reduction
    }
    
    private func calculateMonthlyChange(cigarettes: [Cigarette]) -> Double {
        // Simplified - would calculate actual monthly change
        return -20.0 // Placeholder for 20% monthly reduction
    }
    
    private func generateDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}

// MARK: - Extensions

extension BehavioralAnalyzer.InsightType {
    var icon: String {
        switch self {
        case .timePattern: return "clock"
        case .triggerPattern: return "exclamationmark.triangle"
        case .streakBreaker: return "flame.fill"
        case .socialInfluence: return "person.3"
        case .environmentalTrigger: return "location"
        case .emotionalTrigger: return "heart"
        case .habitualRoutine: return "repeat"
        case .stressResponse: return "waveform.path.ecg"
        case .replacementBehavior: return "arrow.triangle.swap"
        case .progressRegression: return "chart.line.downtrend.xyaxis"
        }
    }
    
    var color: String {
        switch self {
        case .timePattern: return "blue"
        case .triggerPattern: return "orange"
        case .streakBreaker: return "red"
        case .socialInfluence: return "purple"
        case .environmentalTrigger: return "green"
        case .emotionalTrigger: return "pink"
        case .habitualRoutine: return "indigo"
        case .stressResponse: return "red"
        case .replacementBehavior: return "mint"
        case .progressRegression: return "orange"
        }
    }
}