//
//  CoachingModels.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation

// MARK: - Coaching Context
struct CoachingContext {
    let dailyCigarettes: Int
    let todayTarget: Int
    let currentStreak: Int
    let motivationStatements: [String]
    let behavioralPatterns: [BehavioralPattern]
    let recentTriggers: [Trigger]
    let coachingIntensity: CoachingIntensity
    let personalGoals: [String]

    enum CoachingIntensity: String, CaseIterable {
        case gentle = "gentle"
        case moderate = "moderate" 
        case intensive = "intensive"
        
        var displayName: String {
            switch self {
            case .gentle: return "coaching.intensity.gentle".local()
            case .moderate: return "coaching.intensity.moderate".local()
            case .intensive: return "coaching.intensity.intensive".local()
            }
        }
    }
}

// MARK: - Daily Tip
struct DailyTip: Identifiable {
    let id = UUID()
    let content: String
    let actionableStep: String?
    let category: TipCategory
    let confidenceScore: Double
    let personalizationContext: PersonalizationContext
    let timestamp: Date
    
    enum TipCategory: String, CaseIterable {
        case motivation = "motivation"
        case triggerAwareness = "trigger_awareness"
        case habitChange = "habit_change"
        case mindfulness = "mindfulness"
        case socialSupport = "social_support"
        
        var displayName: String {
            switch self {
            case .motivation: return "tip.category.motivation".local()
            case .triggerAwareness: return "tip.category.trigger.awareness".local()
            case .habitChange: return "tip.category.habit.change".local()
            case .mindfulness: return "tip.category.mindfulness".local()
            case .socialSupport: return "tip.category.social.support".local()
            }
        }
        
        var icon: String {
            switch self {
            case .motivation: return "heart.fill"
            case .triggerAwareness: return "exclamationmark.triangle.fill"
            case .habitChange: return "arrow.clockwise"
            case .mindfulness: return "brain.head.profile"
            case .socialSupport: return "person.3.fill"
            }
        }
    }
    
    init(content: String, actionableStep: String? = nil, category: TipCategory, confidenceScore: Double = 0.8, personalizationContext: PersonalizationContext = PersonalizationContext(), timestamp: Date = Date()) {
        self.content = content
        self.actionableStep = actionableStep
        self.category = category
        self.confidenceScore = confidenceScore
        self.personalizationContext = personalizationContext
        self.timestamp = timestamp
    }
}

// MARK: - Personalization Context
struct PersonalizationContext {
    let triggerBased: Trigger?
    let motivationalAlignmentScore: Double
    let behavioralPatternMatch: BehavioralPattern?
    let timeBasedRelevance: TimeRelevance
    let progressBasedAdjustment: ProgressAdjustment?

    enum TimeRelevance: String, CaseIterable {
        case morning = "morning"
        case afternoon = "afternoon"
        case evening = "evening"
        case night = "night"
        
        var displayName: String {
            switch self {
            case .morning: return "time.morning".local()
            case .afternoon: return "time.afternoon".local()
            case .evening: return "time.evening".local()
            case .night: return "time.night".local()
            }
        }
    }

    enum ProgressAdjustment: String, CaseIterable {
        case celebration = "celebration"
        case encouragement = "encouragement"
        case intervention = "intervention"
        case gentleReminder = "gentle_reminder"
        
        var displayName: String {
            switch self {
            case .celebration: return "progress.celebration".local()
            case .encouragement: return "progress.encouragement".local()
            case .intervention: return "progress.intervention".local()
            case .gentleReminder: return "progress.gentle.reminder".local()
            }
        }
    }
    
    init(triggerBased: Trigger? = nil, motivationalAlignmentScore: Double = 0.5, behavioralPatternMatch: BehavioralPattern? = nil, timeBasedRelevance: TimeRelevance = .morning, progressBasedAdjustment: ProgressAdjustment? = nil) {
        self.triggerBased = triggerBased
        self.motivationalAlignmentScore = motivationalAlignmentScore
        self.behavioralPatternMatch = behavioralPatternMatch
        self.timeBasedRelevance = timeBasedRelevance
        self.progressBasedAdjustment = progressBasedAdjustment
    }
}

// MARK: - Trigger Prediction
struct TriggerPrediction: Identifiable {
    let id = UUID()
    let trigger: Trigger
    let riskScore: Double // 0.0 to 1.0
    let predictedTime: Date
    let confidence: Double
    let interventionStrategy: InterventionStrategy
    
    enum InterventionStrategy: String, CaseIterable {
        case preemptive = "preemptive"
        case realtime = "realtime"
        case postevent = "postevent"
        
        var displayName: String {
            switch self {
            case .preemptive: return "intervention.preemptive".local()
            case .realtime: return "intervention.realtime".local()
            case .postevent: return "intervention.postevent".local()
            }
        }
    }
}

// MARK: - Behavioral Pattern
struct BehavioralPattern: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let frequency: PatternFrequency
    let triggers: [Trigger]
    let timeOfDay: [Int] // Hour ranges when pattern occurs
    let confidence: Double
    let lastDetected: Date
    
    enum PatternFrequency: String, CaseIterable {
        case daily = "daily"
        case weekly = "weekly"
        case situational = "situational"
        case occasional = "occasional"
        
        var displayName: String {
            switch self {
            case .daily: return "pattern.frequency.daily".local()
            case .weekly: return "pattern.frequency.weekly".local()
            case .situational: return "pattern.frequency.situational".local()
            case .occasional: return "pattern.frequency.occasional".local()
            }
        }
    }
}

// MARK: - Trigger
struct Trigger: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: TriggerType
    let intensity: TriggerIntensity
    let description: String
    let associatedEmotions: [String]
    
    enum TriggerType: String, CaseIterable {
        case emotional = "emotional"
        case social = "social"
        case situational = "situational"
        case temporal = "temporal"
        case physical = "physical"
        
        var displayName: String {
            switch self {
            case .emotional: return "trigger.type.emotional".local()
            case .social: return "trigger.type.social".local()
            case .situational: return "trigger.type.situational".local()
            case .temporal: return "trigger.type.temporal".local()
            case .physical: return "trigger.type.physical".local()
            }
        }
        
        var icon: String {
            switch self {
            case .emotional: return "heart.fill"
            case .social: return "person.2.fill"
            case .situational: return "location.fill"
            case .temporal: return "clock.fill"
            case .physical: return "figure.walk"
            }
        }
    }
    
    enum TriggerIntensity: String, CaseIterable {
        case low = "low"
        case moderate = "moderate"
        case high = "high"
        case severe = "severe"
        
        var displayName: String {
            switch self {
            case .low: return "trigger.intensity.low".local()
            case .moderate: return "trigger.intensity.moderate".local()
            case .high: return "trigger.intensity.high".local()
            case .severe: return "trigger.intensity.severe".local()
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Trigger, rhs: Trigger) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Motivation Analysis
struct MotivationAnalysis {
    let statements: [String]
    let overallAlignment: Double // 0.0 to 1.0
    let categoryBreakdown: [MotivationCategory: Double]
    let strengthAreas: [String]
    let improvementSuggestions: [String]
    let personalizationScore: Double
    
    enum MotivationCategory: String, CaseIterable {
        case health = "health"
        case family = "family"
        case financial = "financial"
        case freedom = "freedom"
        case appearance = "appearance"
        case social = "social"
        
        var displayName: String {
            switch self {
            case .health: return "motivation.category.health".local()
            case .family: return "motivation.category.family".local()
            case .financial: return "motivation.category.financial".local()
            case .freedom: return "motivation.category.freedom".local()
            case .appearance: return "motivation.category.appearance".local()
            case .social: return "motivation.category.social".local()
            }
        }
    }
}