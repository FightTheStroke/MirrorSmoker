//
//  SmokingInsight.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 02/01/25.
//

import Foundation
import SwiftData

enum InsightTrigger: Codable, Hashable {
    case morningPattern(firstCigaretteMinutes: Int)
    case eveningPattern(lastCigaretteHour: Int)
    case tagPattern(tag: String, frequency: Double)
    case streakBroken(previousStreak: Int)
    case goalExceeded(exceeded: Int)
    case improvementDetected(improvement: String)
    case dependencyLevel(level: DependencyLevel)
    case timeGapPattern(averageGap: TimeInterval)
}

enum DependencyLevel: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate" 
    case high = "high"
    case severe = "severe"
    
    var displayName: String {
        switch self {
        case .low: return NSLocalizedString("dependency.low", comment: "")
        case .moderate: return NSLocalizedString("dependency.moderate", comment: "")
        case .high: return NSLocalizedString("dependency.high", comment: "")
        case .severe: return NSLocalizedString("dependency.severe", comment: "")
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "orange" 
        case .severe: return "red"
        }
    }
}

enum InsightTiming: Codable {
    case morning
    case afternoon
    case evening
    case immediate
    case weekly
}

enum InsightPriority: Int, Codable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

struct SmokingInsight: Codable, Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let actionable: String
    let trigger: InsightTrigger
    let priority: InsightPriority
    let timing: InsightTiming
    let icon: String
    let category: InsightCategory
    
    enum InsightCategory: String, Codable, CaseIterable {
        case behavioral = "behavioral"
        case timing = "timing"
        case progress = "progress"
        case health = "health"
        case motivation = "motivation"
        
        var displayName: String {
            switch self {
            case .behavioral: return NSLocalizedString("insight.category.behavioral", comment: "")
            case .timing: return NSLocalizedString("insight.category.timing", comment: "")
            case .progress: return NSLocalizedString("insight.category.progress", comment: "")
            case .health: return NSLocalizedString("insight.category.health", comment: "")
            case .motivation: return NSLocalizedString("insight.category.motivation", comment: "")
            }
        }
    }
}

@Model
final class InsightHistory {
    var id: UUID = UUID()
    var insightData: Data // Encoded SmokingInsight
    var shownAt: Date = Date()
    var dismissed: Bool = false
    var actionTaken: Bool = false
    
    var insight: SmokingInsight? {
        get {
            try? JSONDecoder().decode(SmokingInsight.self, from: insightData)
        }
        set {
            if let newValue = newValue {
                insightData = (try? JSONEncoder().encode(newValue)) ?? Data()
            }
        }
    }
    
    init(insight: SmokingInsight) {
        self.insightData = (try? JSONEncoder().encode(insight)) ?? Data()
        self.shownAt = Date()
    }
}

// MARK: - Insight Generation System
class InsightEngine {
    
    static func generateInsights(
        for cigarettes: [Cigarette],
        profile: UserProfile,
        tags: [Tag]
    ) -> [SmokingInsight] {
        var insights: [SmokingInsight] = []
        
        // Analizza pattern comportamentali
        insights.append(contentsOf: analyzeMorningPattern(cigarettes))
        insights.append(contentsOf: analyzeEveningPattern(cigarettes))
        insights.append(contentsOf: analyzeTagPatterns(cigarettes, tags: tags))
        insights.append(contentsOf: analyzeProgressPatterns(cigarettes, profile: profile))
        insights.append(contentsOf: analyzeDependencyLevel(cigarettes))
        insights.append(contentsOf: analyzeTimeGaps(cigarettes))
        
        // Sort by priority and return top 3
        return Array(insights.sorted { $0.priority.rawValue > $1.priority.rawValue }.prefix(3))
    }
    
    private static func analyzeMorningPattern(_ cigarettes: [Cigarette]) -> [SmokingInsight] {
        guard !cigarettes.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let recentCigarettes = cigarettes.filter { $0.timestamp >= weekAgo }
        
        var morningTimes: [Int] = []
        
        for cigarette in recentCigarettes {
            let startOfDay = calendar.startOfDay(for: cigarette.timestamp)
            let components = calendar.dateComponents([.hour, .minute], from: startOfDay, to: cigarette.timestamp)
            let minutesFromWaking = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            
            // Considera solo le prime ore del giorno (6-11 AM)
            if (components.hour ?? 0) >= 6 && (components.hour ?? 0) <= 11 {
                if morningTimes.isEmpty || minutesFromWaking < morningTimes.min()! + 120 {
                    morningTimes.append(minutesFromWaking)
                }
            }
        }
        
        guard let averageMorningTime = morningTimes.isEmpty ? nil : morningTimes.reduce(0, +) / morningTimes.count else {
            return []
        }
        
        if averageMorningTime < 30 { // Fuma entro 30 minuti dal risveglio
            return [SmokingInsight(
                title: NSLocalizedString("insight.morning.early.title", comment: ""),
                message: String(format: NSLocalizedString("insight.morning.early.message", comment: ""), averageMorningTime),
                actionable: NSLocalizedString("insight.morning.early.action", comment: ""),
                trigger: .morningPattern(firstCigaretteMinutes: averageMorningTime),
                priority: .high,
                timing: .morning,
                icon: "sun.rise",
                category: .timing
            )]
        } else if averageMorningTime < 60 {
            return [SmokingInsight(
                title: NSLocalizedString("insight.morning.moderate.title", comment: ""),
                message: String(format: NSLocalizedString("insight.morning.moderate.message", comment: ""), averageMorningTime),
                actionable: NSLocalizedString("insight.morning.moderate.action", comment: ""),
                trigger: .morningPattern(firstCigaretteMinutes: averageMorningTime),
                priority: .medium,
                timing: .morning,
                icon: "sun.rise.fill",
                category: .timing
            )]
        }
        
        return []
    }
    
    private static func analyzeEveningPattern(_ cigarettes: [Cigarette]) -> [SmokingInsight] {
        guard !cigarettes.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let recentCigarettes = cigarettes.filter { $0.timestamp >= weekAgo }
        
        let eveningCigarettes = recentCigarettes.filter { cigarette in
            let hour = calendar.component(.hour, from: cigarette.timestamp)
            return hour >= 21 // Dopo le 21:00
        }
        
        if eveningCigarettes.count >= 3 {
            let averageHour = eveningCigarettes.map { calendar.component(.hour, from: $0.timestamp) }.reduce(0, +) / eveningCigarettes.count
            
            if averageHour >= 23 {
                return [SmokingInsight(
                    title: NSLocalizedString("insight.evening.late.title", comment: ""),
                    message: String(format: NSLocalizedString("insight.evening.late.message", comment: ""), averageHour),
                    actionable: NSLocalizedString("insight.evening.late.action", comment: ""),
                    trigger: .eveningPattern(lastCigaretteHour: averageHour),
                    priority: .medium,
                    timing: .evening,
                    icon: "moon",
                    category: .health
                )]
            }
        }
        
        return []
    }
    
    private static func analyzeTagPatterns(_ cigarettes: [Cigarette], tags: [Tag]) -> [SmokingInsight] {
        guard !cigarettes.isEmpty, !tags.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCigarettes = cigarettes.filter { $0.timestamp >= weekAgo }
        
        var tagFrequency: [String: Int] = [:]
        
        for cigarette in recentCigarettes {
            if let cigaretteTags = cigarette.tags {
                for tag in cigaretteTags {
                    tagFrequency[tag.name, default: 0] += 1
                }
            }
        }
        
        guard let mostUsedTag = tagFrequency.max(by: { $0.value < $1.value }) else { return [] }
        
        let frequency = Double(mostUsedTag.value) / Double(recentCigarettes.count)
        
        if frequency > 0.3 { // More than 30% of cigarettes have this tag
            return [SmokingInsight(
                title: NSLocalizedString("insight.tag.frequent.title", comment: ""),
                message: String(format: NSLocalizedString("insight.tag.frequent.message", comment: ""), mostUsedTag.key, Int(frequency * 100)),
                actionable: String(format: NSLocalizedString("insight.tag.frequent.action", comment: ""), mostUsedTag.key.lowercased()),
                trigger: .tagPattern(tag: mostUsedTag.key, frequency: frequency),
                priority: .high,
                timing: .immediate,
                icon: "tag.fill",
                category: .behavioral
            )]
        }
        
        return []
    }
    
    private static func analyzeProgressPatterns(_ cigarettes: [Cigarette], profile: UserProfile) -> [SmokingInsight] {
        guard !cigarettes.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let todayCount = cigarettes.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
        let yesterdayCount = cigarettes.filter { calendar.isDate($0.timestamp, inSameDayAs: yesterday) }.count
        let weekAverage = cigarettes.filter { $0.timestamp >= weekAgo }.count / 7
        
        let dailyAverage = profile.calculateDailyAverage(from: cigarettes)
        let target = profile.todayTarget(dailyAverage: dailyAverage)
        
        if todayCount > target {
            let exceeded = todayCount - target
            return [SmokingInsight(
                title: NSLocalizedString("insight.goal.exceeded.title", comment: ""),
                message: String(format: NSLocalizedString("insight.goal.exceeded.message", comment: ""), exceeded, target),
                actionable: NSLocalizedString("insight.goal.exceeded.action", comment: ""),
                trigger: .goalExceeded(exceeded: exceeded),
                priority: .high,
                timing: .immediate,
                icon: "exclamationmark.triangle",
                category: .progress
            )]
        } else if todayCount < yesterdayCount && yesterdayCount > 0 {
            let improvement = yesterdayCount - todayCount
            return [SmokingInsight(
                title: NSLocalizedString("insight.improvement.title", comment: ""),
                message: String(format: NSLocalizedString("insight.improvement.message", comment: ""), improvement),
                actionable: NSLocalizedString("insight.improvement.action", comment: ""),
                trigger: .improvementDetected(improvement: "\(improvement) cigarettes"),
                priority: .medium,
                timing: .immediate,
                icon: "arrow.down.circle.fill",
                category: .motivation
            )]
        }
        
        return []
    }
    
    private static func analyzeDependencyLevel(_ cigarettes: [Cigarette]) -> [SmokingInsight] {
        guard !cigarettes.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCigarettes = cigarettes.filter { $0.timestamp >= weekAgo }
        
        // Calculate dependency level based on frequency and temporal patterns
        let dailyAverage = Double(recentCigarettes.count) / 7.0
        
        let dependencyLevel: DependencyLevel
        if dailyAverage >= 20 {
            dependencyLevel = .severe
        } else if dailyAverage >= 10 {
            dependencyLevel = .high
        } else if dailyAverage >= 5 {
            dependencyLevel = .moderate
        } else {
            dependencyLevel = .low
        }
        
        return [SmokingInsight(
            title: String(format: NSLocalizedString("insight.dependency.title", comment: ""), dependencyLevel.displayName),
            message: String(format: NSLocalizedString("insight.dependency.message", comment: ""), Int(dailyAverage), dependencyLevel.displayName),
            actionable: NSLocalizedString("insight.dependency.action.\(dependencyLevel.rawValue)", comment: ""),
            trigger: .dependencyLevel(level: dependencyLevel),
            priority: dependencyLevel == .severe ? .critical : .medium,
            timing: .weekly,
            icon: "heart.text.square",
            category: .health
        )]
    }
    
    private static func analyzeTimeGaps(_ cigarettes: [Cigarette]) -> [SmokingInsight] {
        guard cigarettes.count >= 2 else { return [] }
        
        let sortedCigarettes = cigarettes.sorted { $0.timestamp < $1.timestamp }
        var gaps: [TimeInterval] = []
        
        for i in 1..<sortedCigarettes.count {
            let gap = sortedCigarettes[i].timestamp.timeIntervalSince(sortedCigarettes[i-1].timestamp)
            gaps.append(gap)
        }
        
        let averageGap = gaps.reduce(0, +) / Double(gaps.count)
        let averageGapMinutes = averageGap / 60
        
        if averageGapMinutes < 30 {
            return [SmokingInsight(
                title: NSLocalizedString("insight.frequency.high.title", comment: ""),
                message: String(format: NSLocalizedString("insight.frequency.high.message", comment: ""), Int(averageGapMinutes)),
                actionable: NSLocalizedString("insight.frequency.high.action", comment: ""),
                trigger: .timeGapPattern(averageGap: averageGap),
                priority: .high,
                timing: .immediate,
                icon: "clock.fill",
                category: .behavioral
            )]
        }
        
        return []
    }
}