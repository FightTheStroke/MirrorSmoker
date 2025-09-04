//
//  WellnessJourneyModels.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Achievement
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirements: AchievementRequirements
    let pointsValue: Int
    let isUnlocked: Bool
    let unlockedDate: Date?
    let rarity: AchievementRarity
    
    enum AchievementCategory: String, CaseIterable {
        case milestone = "milestone"
        case consistency = "consistency"  
        case health = "health"
        case social = "social"
        case savings = "savings"
        case willpower = "willpower"
        case knowledge = "knowledge"
        
        var displayName: String {
            switch self {
            case .milestone: return "achievement.category.milestone".local()
            case .consistency: return "achievement.category.consistency".local()
            case .health: return "achievement.category.health".local()
            case .social: return "achievement.category.social".local()
            case .savings: return "achievement.category.savings".local()
            case .willpower: return "achievement.category.willpower".local()
            case .knowledge: return "achievement.category.knowledge".local()
            }
        }
        
        var color: Color {
            switch self {
            case .milestone: return DS.Colors.primary
            case .consistency: return DS.Colors.smokingProgressExcellent
            case .health: return DS.Colors.healthImprovement
            case .social: return DS.Colors.tagSocial
            case .savings: return DS.Colors.smokingProgressCaution
            case .willpower: return DS.Colors.motivationInspiring
            case .knowledge: return DS.Colors.smokingProgressGood
            }
        }
    }
    
    enum AchievementRarity: String, CaseIterable {
        case common = "common"
        case uncommon = "uncommon"
        case rare = "rare"
        case epic = "epic"
        case legendary = "legendary"
        
        var displayName: String {
            switch self {
            case .common: return "achievement.rarity.common".local()
            case .uncommon: return "achievement.rarity.uncommon".local()
            case .rare: return "achievement.rarity.rare".local()
            case .epic: return "achievement.rarity.epic".local()
            case .legendary: return "achievement.rarity.legendary".local()
            }
        }
    }
    
    struct AchievementRequirements {
        let smokeFreeHours: Int?
        let consistentDays: Int?
        let moneySaved: Double?
        let cigarettesAvoided: Int?
        let customCondition: String?
        
        init(smokeFreeHours: Int? = nil, consistentDays: Int? = nil, moneySaved: Double? = nil, cigarettesAvoided: Int? = nil, customCondition: String? = nil) {
            self.smokeFreeHours = smokeFreeHours
            self.consistentDays = consistentDays
            self.moneySaved = moneySaved
            self.cigarettesAvoided = cigarettesAvoided
            self.customCondition = customCondition
        }
    }
    
    // Static achievement definitions
    static let defaultAchievements: [Achievement] = [
        Achievement(
            title: "achievement.first.hour.title",
            description: "achievement.first.hour.description",
            icon: "⏰",
            category: .milestone,
            requirements: AchievementRequirements(smokeFreeHours: 1),
            pointsValue: 10,
            isUnlocked: false,
            unlockedDate: nil,
            rarity: .common
        ),
        Achievement(
            title: "achievement.first.day.title",
            description: "achievement.first.day.description", 
            icon: "🌅",
            category: .milestone,
            requirements: AchievementRequirements(smokeFreeHours: 24),
            pointsValue: 50,
            isUnlocked: false,
            unlockedDate: nil,
            rarity: .uncommon
        ),
        Achievement(
            title: "achievement.first.week.title",
            description: "achievement.first.week.description",
            icon: "📅",
            category: .milestone,
            requirements: AchievementRequirements(smokeFreeHours: 168),
            pointsValue: 200,
            isUnlocked: false,
            unlockedDate: nil,
            rarity: .rare
        ),
        Achievement(
            title: "achievement.consistency.champion.title",
            description: "achievement.consistency.champion.description",
            icon: "🏆",
            category: .consistency,
            requirements: AchievementRequirements(consistentDays: 7),
            pointsValue: 100,
            isUnlocked: false,
            unlockedDate: nil,
            rarity: .uncommon
        ),
        Achievement(
            title: "achievement.money.saver.title",
            description: "achievement.money.saver.description",
            icon: "💰",
            category: .savings,
            requirements: AchievementRequirements(moneySaved: 100),
            pointsValue: 150,
            isUnlocked: false,
            unlockedDate: nil,
            rarity: .rare
        )
    ]
}

// MARK: - Wellness Journey ViewModel
@MainActor
class WellnessJourneyViewModel: ObservableObject {
    @Published var journeyProgress: Double = 0.0
    @Published var recentAchievements: [Achievement] = []
    @Published var nextMajorMilestone: Milestone?
    @Published var journeyInsights: [String] = []
    @Published var totalPoints: Int = 0
    @Published var currentLevel: Int = 1
    @Published var smokeFreeTime: TimeInterval = 0
    
    private let achievementEngine = AchievementEngine()
    
    init() {
        // Initialize with mock data
        self.recentAchievements = Achievement.defaultAchievements.filter { $0.isUnlocked }
    }
    
    func updateJourneyStats() async {
        // Calculate progress towards next milestone
        journeyProgress = await calculateProgress()
        
        // Check for newly unlocked achievements
        recentAchievements = await achievementEngine.checkForAchievements()
        
        // Determine next major milestone
        nextMajorMilestone = await determineNextMilestone()
        
        // Generate AI-powered insights about journey
        journeyInsights = await generateJourneyInsights()
        
        // Update level and points
        totalPoints = recentAchievements.reduce(0) { $0 + $1.pointsValue }
        currentLevel = calculateLevel(from: totalPoints)
    }
    
    private func calculateProgress() async -> Double {
        // Implementation for progress calculation
        // Based on quit progress, consistency, insights engaged, etc.
        
        let smokeFreeHours = smokeFreeTime / 3600
        let maxHoursForProgress = 168.0 // 1 week for 100% progress
        
        let baseProgress = min(1.0, smokeFreeHours / maxHoursForProgress)
        
        // Bonus progress for achievements
        let achievementBonus = Double(recentAchievements.count) * 0.05
        
        return min(1.0, baseProgress + achievementBonus)
    }
    
    private func determineNextMilestone() async -> Milestone? {
        let smokeFreeHours = Int(smokeFreeTime / 3600)
        
        // Determine next milestone based on current progress
        let milestones = [
            (1, "milestone.one.hour", "🕐", "1 hour"),
            (24, "milestone.one.day", "🌅", "1 day"),
            (72, "milestone.three.days", "📅", "3 days"),
            (168, "milestone.one.week", "🗓️", "1 week"),
            (720, "milestone.one.month", "📆", "1 month")
        ]
        
        for (hours, titleKey, icon, value) in milestones {
            if smokeFreeHours < hours {
                return Milestone(
                    title: titleKey,
                    description: "\(titleKey).description",
                    achievedDate: Date(),
                    icon: icon,
                    category: .smokeFree,
                    value: value
                )
            }
        }
        
        return nil // All major milestones achieved
    }
    
    private func generateJourneyInsights() async -> [String] {
        var insights: [String] = []
        
        let smokeFreeHours = Int(smokeFreeTime / 3600)
        let achievementCount = recentAchievements.count
        
        if smokeFreeHours > 0 {
            insights.append("journey.insight.smoke.free.time".local())
        }
        
        if achievementCount > 0 {
            insights.append("journey.insight.achievements.earned".local())
        }
        
        if journeyProgress > 0.5 {
            insights.append("journey.insight.halfway.point".local())
        }
        
        // Add some motivational insights
        insights.append("journey.insight.keep.going".local())
        
        return insights
    }
    
    private func calculateLevel(from points: Int) -> Int {
        // Simple level calculation: 100 points per level
        return max(1, points / 100 + 1)
    }
}

// MARK: - Achievement Engine
@MainActor
class AchievementEngine: ObservableObject {
    func checkForAchievements() async -> [Achievement] {
        // Mock implementation - in real app would check against actual user data
        let mockAchievements = Achievement.defaultAchievements.enumerated().compactMap { index, achievement -> Achievement? in
            // Mock unlock some achievements
            if index < 2 {
                return Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    category: achievement.category,
                    requirements: achievement.requirements,
                    pointsValue: achievement.pointsValue,
                    isUnlocked: true,
                    unlockedDate: Date().addingTimeInterval(-TimeInterval(index * 86400)),
                    rarity: achievement.rarity
                )
            }
            return nil
        }
        
        return mockAchievements
    }
    
    func checkSpecificAchievement(_ achievement: Achievement, userData: UserData) -> Bool {
        // Implementation to check if specific achievement requirements are met
        let requirements = achievement.requirements
        
        if let smokeFreeHours = requirements.smokeFreeHours {
            return userData.smokeFreeTime >= TimeInterval(smokeFreeHours * 3600)
        }
        
        if let consistentDays = requirements.consistentDays {
            return userData.consistentDays >= consistentDays
        }
        
        if let moneySaved = requirements.moneySaved {
            return userData.moneySaved >= moneySaved
        }
        
        if let cigarettesAvoided = requirements.cigarettesAvoided {
            return userData.cigarettesAvoided >= cigarettesAvoided
        }
        
        return false
    }
}

// MARK: - User Data for Achievement Checking
struct UserData {
    let smokeFreeTime: TimeInterval
    let consistentDays: Int
    let moneySaved: Double
    let cigarettesAvoided: Int
    let totalCigarettes: Int
    let lastSmokedDate: Date?
}