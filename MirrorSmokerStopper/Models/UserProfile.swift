//
//  UserProfile.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

#if os(watchOS)
// Define DependencyLevel for watchOS since it doesn't have access to SmokingInsight.swift
enum DependencyLevel: String, CaseIterable, Codable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}
#endif

enum ReductionCurve: String, CaseIterable, Codable {
    case linear = "linear"
    case exponential = "exponential"
    case logarithmic = "logarithmic"
    case stepped = "stepped"
    case gentle = "gentle"
}

enum SmokingType: String, CaseIterable, Codable {
    case cigarettes = "cigarettes"
    case electronic = "electronic"
    case tobacco = "tobacco"
    
    var displayName: String {
        switch self {
        case .cigarettes:
            return NSLocalizedString("smoking.type.cigarettes", comment: "")
        case .electronic:
            return NSLocalizedString("smoking.type.electronic", comment: "")
        case .tobacco:
            return NSLocalizedString("smoking.type.tobacco", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .cigarettes:
            return "lungs.fill"
        case .electronic:
            return "battery.100"
        case .tobacco:
            return "leaf.fill"
        }
    }
}

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var birthDate: Date?
    var weight: Double = 0.0 // in kg
    var smokingTypeRaw: String = SmokingType.cigarettes.rawValue
    var startedSmokingAge: Int = 18
    var notificationsEnabled: Bool = true
    var themePreference: String = "system"
    var lastUpdated: Date = Date()
    
    var quitDate: Date? // Target date to quit completely
    var enableGradualReduction: Bool = true // Whether to enable gradual reduction
    
    // New properties for migration compatibility (using raw values for enums)
    var reductionCurveRaw: String = ReductionCurve.linear.rawValue
    var startingSmokerTypeRaw: String = SmokingType.cigarettes.rawValue
    var healthInsights: String = ""
    var motivationalMessages: String = ""
    var createdAt: Date = Date()
    var dailyAverage: Double = 0.0 // NEW: Custom daily average
    var preferredCurrency: String = "EUR" // NEW: User's preferred currency
    
    // Daily targets cache (to avoid recalculating every time)
    // Format: "YYYY-MM-DD" -> target value
    // This gets cleared when quit plan changes
    // Note: Using @Transient requires iOS 17+, but it's not stored in the database
    private var dailyTargetsCache: [String: Int] = [:]
    
    // Computed properties for enum access
    var reductionCurve: ReductionCurve {
        get {
            return ReductionCurve(rawValue: reductionCurveRaw) ?? .linear
        }
        set {
            reductionCurveRaw = newValue.rawValue
        }
    }
    
    var startingSmokerType: SmokingType {
        get {
            return SmokingType(rawValue: startingSmokerTypeRaw) ?? .cigarettes
        }
        set {
            startingSmokerTypeRaw = newValue.rawValue
        }
    }
    
    // Computed property for smokingType that handles nil/invalid values gracefully
    var smokingType: SmokingType {
        get {
            return SmokingType(rawValue: smokingTypeRaw) ?? .cigarettes
        }
        set {
            smokingTypeRaw = newValue.rawValue
        }
    }
    
    // Computed property for age
    var age: Int {
        guard let birthDate = birthDate else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    // Computed property for years smoking
    var yearsSmokingSince: Int {
        max(0, age - startedSmokingAge)
    }
    
    func calculateDailyAverage(from cigarettes: [Any]) -> Double {
        // Cast to Cigarette array safely
        let validCigarettes = cigarettes.compactMap { $0 as? Cigarette }
        
        guard !validCigarettes.isEmpty else { return 0.0 }
        
        // Calculate average over last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = validCigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        
        guard !recentCigarettes.isEmpty else { return 0.0 }
        
        // Calculate actual days with data instead of always using 30
        let daysWithData = max(1, Calendar.current.dateComponents([.day], from: thirtyDaysAgo, to: Date()).day ?? 1)
        return Double(recentCigarettes.count) / Double(min(30, daysWithData))
    }
    
    /// Update the daily average based on current cigarette data
    func updateDailyAverage(from cigarettes: [Any]) {
        self.dailyAverage = calculateDailyAverage(from: cigarettes)
        self.clearTargetsCache() // Clear cache since average changed
    }
    
    func todayTarget(dailyAverage: Double) -> Int {
        guard enableGradualReduction, let quitDate = quitDate else {
            return Int(dailyAverage) // If there's no plan, use current average
        }
        
        return cachedTargetForDate(Date(), dailyAverage: dailyAverage, quitDate: quitDate)
    }
    
    // Get target for any specific date (useful for historical analysis or future planning)
    func targetForDate(_ date: Date, dailyAverage: Double) -> Int {
        guard enableGradualReduction, let quitDate = quitDate else {
            return Int(dailyAverage)
        }
        
        return cachedTargetForDate(date, dailyAverage: dailyAverage, quitDate: quitDate)
    }
    
    // Clear cache when quit plan changes
    func clearTargetsCache() {
        dailyTargetsCache.removeAll()
    }
    
    // Generate targets for the entire quit plan (for visualization)
    func generateAllPlanTargets(dailyAverage: Double) -> [(Date, Int)] {
        guard enableGradualReduction, let quitDate = quitDate else {
            return []
        }
        
        let calendar = Calendar.current
        let startDate = Date()
        var results: [(Date, Int)] = []
        var currentDate = startDate
        
        while currentDate <= quitDate {
            let target = cachedTargetForDate(currentDate, dailyAverage: dailyAverage, quitDate: quitDate)
            results.append((currentDate, target))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? quitDate
        }
        
        return results
    }
    
    private func cachedTargetForDate(_ date: Date, dailyAverage: Double, quitDate: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        
        if let cachedTarget = dailyTargetsCache[dateKey] {
            return cachedTarget
        }
        
        let target = improvedTargetForDate(date, dailyAverage: dailyAverage, quitDate: quitDate)
        dailyTargetsCache[dateKey] = target
        return target
    }
    
    // MARK: - Enhanced Quit Plan Algorithm
    private func improvedTargetForDate(_ date: Date, dailyAverage: Double, quitDate: Date) -> Int {
        let calendar = Calendar.current
        
        // Normalize dates to start of day for consistent calculation
        let startDate = calendar.startOfDay(for: Date()) // Plan always starts from today
        let targetDate = calendar.startOfDay(for: date)
        let endDate = calendar.startOfDay(for: quitDate)
        
        // If the date is before today or after/equal to quit date, return 0
        if targetDate < startDate || targetDate >= endDate {
            return 0
        }
        
        // Calculate days using TimeInterval for more reliable calculation
        let daysRemaining = Int(endDate.timeIntervalSince(targetDate) / (24 * 3600))
        let totalDays = Int(endDate.timeIntervalSince(startDate) / (24 * 3600))
        
        if totalDays <= 0 || daysRemaining <= 0 {
            return 0
        }
        
        // Calculate dependency level based on daily average
        let dependencyLevel = calculateDependencyLevel(dailyAverage: dailyAverage)
        
        // Choose reduction curve based on dependency
        let reductionCurve = selectReductionCurve(dependencyLevel: dependencyLevel, totalDays: totalDays)
        
        // Calculate personalized target
        let targetForDate = calculatePersonalizedTarget(
            dailyAverage: dailyAverage,
            daysRemaining: daysRemaining,
            totalDays: totalDays,
            curve: reductionCurve
        )
        
        return max(0, Int(ceil(targetForDate)))
    }
    
    private func calculateDependencyLevel(dailyAverage: Double) -> DependencyLevel {
        switch dailyAverage {
        case 0..<5:
            return .low
        case 5..<10:
            return .moderate
        case 10..<20:
            return .high
        default:
            return .severe
        }
    }
    
    private func selectReductionCurve(dependencyLevel: DependencyLevel, totalDays: Int) -> ReductionCurve {
        switch dependencyLevel {
        case .low:
            return totalDays >= 14 ? .linear : .gentle
        case .moderate:
            return totalDays >= 21 ? .exponential : .linear
        case .high:
            return totalDays >= 30 ? .logarithmic : .exponential
        case .severe:
            return totalDays >= 45 ? .stepped : .logarithmic
        }
    }
    
    private func calculatePersonalizedTarget(
        dailyAverage: Double,
        daysRemaining: Int,
        totalDays: Int,
        curve: ReductionCurve
    ) -> Double {
        let progress = Double(totalDays - daysRemaining) / Double(totalDays)
        
        switch curve {
        case .linear:
            // Standard linear reduction
            return dailyAverage * (1.0 - progress)
            
        case .exponential:
            // Faster reduction at the beginning, then slows down
            let exponentialProgress = pow(progress, 0.7)
            return dailyAverage * (1.0 - exponentialProgress)
            
        case .logarithmic:
            // Slow reduction at the beginning, then accelerates
            let logProgress = progress == 0 ? 0 : log(1 + progress * 9) / log(10)
            return dailyAverage * (1.0 - logProgress)
            
        case .stepped:
            // Step reduction for high dependency
            let stepSize = totalDays / 5 // 5 steps
            let currentStep = min(4, (totalDays - daysRemaining) / stepSize)
            let reduction = Double(currentStep) / 4.0 * 0.8 // Max 80% reduction in steps
            return dailyAverage * (1.0 - reduction)
            
        case .gentle:
            // Very gradual reduction for low dependency
            let gentleProgress = pow(progress, 1.3)
            return dailyAverage * (1.0 - gentleProgress)
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        birthDate: Date? = nil,
        weight: Double = 0.0,
        smokingType: SmokingType = .cigarettes,
        startedSmokingAge: Int = 18,
        notificationsEnabled: Bool = true,
        themePreference: String = "system",
        quitDate: Date? = nil,
        enableGradualReduction: Bool = true,
        reductionCurve: ReductionCurve = .linear,
        startingSmokerType: SmokingType = .cigarettes,
        healthInsights: String = "",
        motivationalMessages: String = "",
        createdAt: Date = Date(),
        dailyAverage: Double = 0.0,
        preferredCurrency: String = "EUR"
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.weight = weight
        self.smokingTypeRaw = smokingType.rawValue
        self.startedSmokingAge = startedSmokingAge
        self.notificationsEnabled = notificationsEnabled
        self.themePreference = themePreference
        self.quitDate = quitDate
        self.enableGradualReduction = enableGradualReduction
        self.reductionCurveRaw = reductionCurve.rawValue
        self.startingSmokerTypeRaw = startingSmokerType.rawValue
        self.healthInsights = healthInsights
        self.motivationalMessages = motivationalMessages
        self.createdAt = createdAt
        self.dailyAverage = dailyAverage
        self.preferredCurrency = preferredCurrency
        self.lastUpdated = Date()
    }
}