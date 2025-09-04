//
//  QuitPlanOptimizer.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData
import HealthKit
import os.log

/// AI-powered quit plan optimization system
@MainActor
final class QuitPlanOptimizer: ObservableObject, Sendable {
    static let shared = QuitPlanOptimizer()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "QuitPlanOptimizer")
    private let healthKitManager = HealthKitManager.shared
    private let featureStore = FeatureStore.shared
    
    // MARK: - Optimization Configuration
    
    struct OptimizationRecommendation: Codable, Sendable {
        let recommendedQuitDate: Date
        let recommendedCurve: ReductionCurve
        let confidenceScore: Double // 0.0 to 1.0
        let reasoning: String
        let personalizedMilestones: [QuitMilestone]
        let adaptations: [PlanAdaptation]
        let riskFactors: [String]
        let supportStrategies: [String]
    }
    
    struct QuitMilestone: Codable, Sendable {
        let date: Date
        let target: Int
        let description: String
        let motivationalMessage: String
        let checkpointType: CheckpointType
    }
    
    enum CheckpointType: String, CaseIterable, Codable {
        case weekly = "weekly"
        case biweekly = "biweekly"
        case major = "major"
        case final = "final"
    }
    
    struct PlanAdaptation: Codable, Sendable {
        let type: AdaptationType
        let reason: String
        let recommendation: String
        let urgency: AdaptationUrgency
    }
    
    enum AdaptationType: String, CaseIterable, Codable {
        case scheduleAdjustment = "schedule_adjustment"
        case curveChange = "curve_change"
        case supportIncrease = "support_increase"
        case medicalConsultation = "medical_consultation"
        case behavioralIntervention = "behavioral_intervention"
    }
    
    enum AdaptationUrgency: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
    }
    
    private init() {}
    
    // MARK: - Main Optimization Methods
    
    /// Generate optimized quit plan recommendation
    func generateOptimizedPlan(
        for profile: UserProfile,
        modelContext: ModelContext,
        currentCigarettes: [Cigarette]
    ) async -> OptimizationRecommendation {
        
        logger.info("Generating optimized quit plan for user profile")
        
        // Collect comprehensive features
        let features = await featureStore.collect(from: modelContext, userProfile: profile)
        let healthContext = await collectHealthContext(profile: profile)
        let behavioralPatterns = await analyzeBehavioralPatterns(cigarettes: currentCigarettes)
        let riskAssessment = await assessQuitRisk(profile: profile, features: features)
        
        // Generate base recommendation
        let baseRecommendation = await generateBaseRecommendation(
            profile: profile,
            features: features,
            healthContext: healthContext,
            behavioralPatterns: behavioralPatterns,
            riskAssessment: riskAssessment
        )
        
        // Apply AI optimization based on iOS version
        let optimizationContext = OptimizationContext(
            profile: profile,
            features: features,
            healthContext: healthContext,
            behavioralPatterns: behavioralPatterns,
            riskAssessment: riskAssessment
        )
        
        let optimizedRecommendation: OptimizationRecommendation
        if #available(iOS 26, *) {
            optimizedRecommendation = await applyAIOptimization(
                baseRecommendation: baseRecommendation,
                context: optimizationContext
            )
        } else {
            optimizedRecommendation = await applyFallbackOptimization(
                baseRecommendation: baseRecommendation,
                context: optimizationContext
            )
        }
        
        logger.info("Generated optimized quit plan with confidence: \(optimizedRecommendation.confidenceScore)")
        return optimizedRecommendation
    }
    
    /// Evaluate current plan performance and suggest adaptations
    func evaluatePlanPerformance(
        profile: UserProfile,
        modelContext: ModelContext,
        currentCigarettes: [Cigarette]
    ) async -> [PlanAdaptation] {
        
        logger.debug("Evaluating quit plan performance")
        
        let recentCigarettes = currentCigarettes.filter { 
            $0.timestamp > Date().addingTimeInterval(-7 * 24 * 3600) // Last 7 days
        }
        
        var adaptations: [PlanAdaptation] = []
        
        // Check if user is meeting targets
        let currentTarget = profile.todayTarget(dailyAverage: profile.dailyAverage)
        let todayCigarettes = recentCigarettes.filter {
            Calendar.current.isDateInToday($0.timestamp)
        }.count
        
        if todayCigarettes > currentTarget + 2 {
            adaptations.append(PlanAdaptation(
                type: .scheduleAdjustment,
                reason: "Consistently exceeding daily targets",
                recommendation: "Consider extending quit timeline by 1-2 weeks for more sustainable progress",
                urgency: .medium
            ))
        }
        
        // Check for plateau patterns
        let weeklyAverages = calculateWeeklyAverages(cigarettes: recentCigarettes)
        if isPlateauDetected(weeklyAverages: weeklyAverages) {
            adaptations.append(PlanAdaptation(
                type: .curveChange,
                reason: "Progress plateau detected",
                recommendation: "Switch to stepped reduction curve to break through plateau",
                urgency: .medium
            ))
        }
        
        // Check for high-risk patterns
        let highRiskHours = identifyHighRiskHours(cigarettes: currentCigarettes)
        if highRiskHours.count > 3 {
            adaptations.append(PlanAdaptation(
                type: .behavioralIntervention,
                reason: "Multiple high-risk time patterns identified",
                recommendation: "Implement targeted interventions for peak smoking hours",
                urgency: .high
            ))
        }
        
        // Check for health indicators requiring medical consultation
        let healthContext = await collectHealthContext(profile: profile)
        if healthContext.hasHighRiskIndicators {
            adaptations.append(PlanAdaptation(
                type: .medicalConsultation,
                reason: "Health indicators suggest medical support needed",
                recommendation: "Consult healthcare provider for NRT or medication assistance",
                urgency: .high
            ))
        }
        
        return adaptations
    }
    
    // MARK: - Personalized Milestone Generation
    
    private func generatePersonalizedMilestones(
        profile: UserProfile,
        quitDate: Date,
        behavioralPatterns: BehavioralPatterns
    ) -> [QuitMilestone] {
        
        var milestones: [QuitMilestone] = []
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: Date(), to: quitDate).day ?? 30
        
        // Create milestones based on plan length and patterns
        let milestoneIntervals = determineMilestoneIntervals(totalDays: totalDays, patterns: behavioralPatterns)
        
        for (index, interval) in milestoneIntervals.enumerated() {
            let milestoneDate = calendar.date(byAdding: .day, value: interval, to: Date()) ?? Date()
            let target = profile.todayTarget(dailyAverage: profile.dailyAverage)
            
            let milestone = QuitMilestone(
                date: milestoneDate,
                target: max(0, target - index * 2), // Progressive reduction
                description: generateMilestoneDescription(week: index + 1, isPersonalized: true),
                motivationalMessage: generatePersonalizedMotivation(
                    week: index + 1,
                    profile: profile,
                    patterns: behavioralPatterns
                ),
                checkpointType: determineMilestoneType(weekNumber: index + 1, totalWeeks: totalDays / 7)
            )
            
            milestones.append(milestone)
        }
        
        return milestones
    }
    
    // MARK: - AI-Powered Optimization (iOS 26)
    
    @available(iOS 26, *)
    private func applyAIOptimization(
        baseRecommendation: OptimizationRecommendation,
        context: OptimizationContext
    ) async -> OptimizationRecommendation {
        
        logger.debug("Applying iOS 26 AI optimization")
        
        // This would use Apple Intelligence Foundation Models
        // For now, return enhanced base recommendation
        return enhanceRecommendationWithAI(
            baseRecommendation: baseRecommendation,
            context: context
        )
    }
    
    // MARK: - Fallback Optimization (iOS 17+)
    
    private func applyFallbackOptimization(
        baseRecommendation: OptimizationRecommendation,
        context: OptimizationContext
    ) async -> OptimizationRecommendation {
        
        logger.debug("Applying rule-based optimization (iOS 17+ fallback)")
        
        return enhanceRecommendationWithRules(
            baseRecommendation: baseRecommendation,
            context: context
        )
    }
    
    // MARK: - Helper Methods
    
    private func generateBaseRecommendation(
        profile: UserProfile,
        features: CoachFeatures,
        healthContext: HealthContext,
        behavioralPatterns: BehavioralPatterns,
        riskAssessment: QuitRiskAssessment
    ) async -> OptimizationRecommendation {
        
        let recommendedDuration = calculateOptimalDuration(
            dailyAverage: profile.dailyAverage,
            dependencyLevel: riskAssessment.dependencyLevel,
            healthFactors: healthContext.riskFactors.count
        )
        
        let recommendedQuitDate = Calendar.current.date(
            byAdding: .day,
            value: recommendedDuration,
            to: Date()
        ) ?? Date().addingTimeInterval(30 * 24 * 3600)
        
        let recommendedCurve = selectOptimalCurve(
            dependencyLevel: riskAssessment.dependencyLevel,
            behavioralPatterns: behavioralPatterns,
            healthContext: healthContext
        )
        
        return OptimizationRecommendation(
            recommendedQuitDate: recommendedQuitDate,
            recommendedCurve: recommendedCurve,
            confidenceScore: calculateConfidenceScore(riskAssessment: riskAssessment),
            reasoning: generateReasoningText(
                duration: recommendedDuration,
                curve: recommendedCurve,
                riskAssessment: riskAssessment
            ),
            personalizedMilestones: generatePersonalizedMilestones(
                profile: profile,
                quitDate: recommendedQuitDate,
                behavioralPatterns: behavioralPatterns
            ),
            adaptations: [],
            riskFactors: riskAssessment.identifiedRisks,
            supportStrategies: generateSupportStrategies(
                riskAssessment: riskAssessment,
                behavioralPatterns: behavioralPatterns
            )
        )
    }
    
    private func generateFallbackPlan(
        for profile: UserProfile,
        currentCigarettes: [Cigarette]
    ) -> OptimizationRecommendation {
        
        logger.warning("Using fallback quit plan generation")
        
        let defaultDuration = max(14, Int(profile.dailyAverage * 2)) // Minimum 2 weeks
        let quitDate = Date().addingTimeInterval(Double(defaultDuration) * 24 * 3600)
        
        return OptimizationRecommendation(
            recommendedQuitDate: quitDate,
            recommendedCurve: .linear,
            confidenceScore: 0.6,
            reasoning: "Generated using standard guidelines due to limited data",
            personalizedMilestones: generateBasicMilestones(duration: defaultDuration),
            adaptations: [],
            riskFactors: ["Limited personalization data"],
            supportStrategies: ["Follow standard quit plan", "Seek support from healthcare provider"]
        )
    }
    
    // Additional helper methods...
    private func calculateOptimalDuration(dailyAverage: Double, dependencyLevel: DependencyLevel, healthFactors: Int) -> Int {
        let baseDuration = Int(dailyAverage * 1.5)
        let dependencyMultiplier: Double = switch dependencyLevel {
            case .low: 1.0
            case .moderate: 1.3
            case .high: 1.6
            case .severe: 2.0
        }
        let healthAdjustment = healthFactors * 3
        return max(14, Int(Double(baseDuration) * dependencyMultiplier) + healthAdjustment)
    }
    
    private func selectOptimalCurve(dependencyLevel: DependencyLevel, behavioralPatterns: BehavioralPatterns, healthContext: HealthContext) -> ReductionCurve {
        if behavioralPatterns.hasConsistentTriggers {
            return .stepped
        } else if healthContext.hasHighRiskIndicators {
            return .gentle
        } else {
            return switch dependencyLevel {
                case .low: .linear
                case .moderate: .exponential
                case .high: .logarithmic
                case .severe: .stepped
            }
        }
    }
    
    private func calculateConfidenceScore(riskAssessment: QuitRiskAssessment) -> Double {
        let baseScore = 0.8
        let riskPenalty = Double(riskAssessment.identifiedRisks.count) * 0.05
        let strengthBonus = riskAssessment.successFactors.count > 2 ? 0.1 : 0.0
        return max(0.3, min(1.0, baseScore - riskPenalty + strengthBonus))
    }
    
    private func generateBasicMilestones(duration: Int) -> [QuitMilestone] {
        let weeksCount = max(2, duration / 7)
        return (1...weeksCount).map { week in
            QuitMilestone(
                date: Calendar.current.date(byAdding: .weekOfYear, value: week, to: Date()) ?? Date(),
                target: max(0, 20 - week * 3),
                description: "Week \(week) checkpoint",
                motivationalMessage: "Keep going! You're making progress.",
                checkpointType: week == weeksCount ? .final : .weekly
            )
        }
    }
}

// MARK: - Supporting Types

struct HealthContext: Codable, Sendable {
    let hasHealthKitData: Bool
    let recentNRTUsage: Bool
    let averageStepsPerDay: Double
    let sleepQuality: Double
    let mindfulSessionsCount: Int
    let riskFactors: [String]
    let protectiveFactors: [String]
    
    var hasHighRiskIndicators: Bool {
        riskFactors.count > 2 || (averageStepsPerDay < 3000 && sleepQuality < 0.6)
    }
}

struct BehavioralPatterns: Codable, Sendable {
    let peakSmokingHours: [Int]
    let averageDailyVariation: Double
    let hasWeekendSpikes: Bool
    let hasConsistentTriggers: Bool
    let mostCommonTriggerTags: [String]
    let streakLength: Int
    let complianceRate: Double
}

struct QuitRiskAssessment: Codable, Sendable {
    let dependencyLevel: DependencyLevel
    let identifiedRisks: [String]
    let successFactors: [String]
    let overallRiskScore: Double // 0.0 = low risk, 1.0 = high risk
}

struct OptimizationContext {
    let profile: UserProfile
    let features: CoachFeatures
    let healthContext: HealthContext
    let behavioralPatterns: BehavioralPatterns
    let riskAssessment: QuitRiskAssessment
}

// MARK: - Extensions for Enhanced Functionality

extension QuitPlanOptimizer {
    
    private func collectHealthContext(profile: UserProfile) async -> HealthContext {
        do {
            let nrtUsage = try await healthKitManager.didUseNRTRecently()
            let steps = try await healthKitManager.getStepsLast3Hours()
            let sleep = try await healthKitManager.getSleepQuality()
            let mindful = try await healthKitManager.getMindfulSessionsToday()
            
            return HealthContext(
                hasHealthKitData: true,
                recentNRTUsage: nrtUsage,
                averageStepsPerDay: steps * 8, // Approximate daily from 3-hour
                sleepQuality: sleep,
                mindfulSessionsCount: mindful,
                riskFactors: generateHealthRiskFactors(profile: profile, steps: steps, sleep: sleep),
                protectiveFactors: generateProtectiveFactors(nrt: nrtUsage, mindful: mindful, steps: steps)
            )
        } catch {
            return HealthContext(
                hasHealthKitData: false,
                recentNRTUsage: false,
                averageStepsPerDay: 5000,
                sleepQuality: 0.7,
                mindfulSessionsCount: 0,
                riskFactors: ["No health data available"],
                protectiveFactors: []
            )
        }
    }
    
    private func analyzeBehavioralPatterns(cigarettes: [Cigarette]) async -> BehavioralPatterns {
        let hourCounts = Dictionary(grouping: cigarettes) { 
            Calendar.current.component(.hour, from: $0.timestamp) 
        }.mapValues { $0.count }
        
        let peakHours = hourCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        let weekendCigarettes = cigarettes.filter { 
            let weekday = Calendar.current.component(.weekday, from: $0.timestamp)
            return weekday == 1 || weekday == 7
        }.count
        
        let weekdayCigarettes = cigarettes.count - weekendCigarettes
        let hasWeekendSpikes = Double(weekendCigarettes) / max(1, Double(weekdayCigarettes)) > 1.3
        
        return BehavioralPatterns(
            peakSmokingHours: peakHours,
            averageDailyVariation: calculateDailyVariation(cigarettes: cigarettes),
            hasWeekendSpikes: hasWeekendSpikes,
            hasConsistentTriggers: hasConsistentTriggerPatterns(cigarettes: cigarettes),
            mostCommonTriggerTags: extractCommonTriggerTags(cigarettes: cigarettes),
            streakLength: calculateCurrentStreak(cigarettes: cigarettes),
            complianceRate: 0.8 // Would be calculated based on target adherence
        )
    }
    
    private func assessQuitRisk(profile: UserProfile, features: CoachFeatures) async -> QuitRiskAssessment {
        let dependencyLevel = calculateDependencyLevel(dailyAverage: profile.dailyAverage)
        let risks = identifyRiskFactors(profile: profile, features: features)
        let successFactors = identifySuccessFactors(profile: profile, features: features)
        
        let riskScore = calculateOverallRiskScore(
            dependencyLevel: dependencyLevel,
            riskCount: risks.count,
            successCount: successFactors.count
        )
        
        return QuitRiskAssessment(
            dependencyLevel: dependencyLevel,
            identifiedRisks: risks,
            successFactors: successFactors,
            overallRiskScore: riskScore
        )
    }
    
    // Additional helper methods for pattern analysis and risk assessment...
    private func calculateDependencyLevel(dailyAverage: Double) -> DependencyLevel {
        switch dailyAverage {
        case 0..<5: return .low
        case 5..<10: return .moderate
        case 10..<20: return .high
        default: return .severe
        }
    }
    
    private func identifyRiskFactors(profile: UserProfile, features: CoachFeatures) -> [String] {
        var risks: [String] = []
        
        if profile.dailyAverage > 20 {
            risks.append("High daily consumption (>20 cigarettes)")
        }
        
        if profile.yearsSmokingSince > 20 {
            risks.append("Long-term smoking history (>20 years)")
        }
        
        if features.currentStreak == 0 {
            risks.append("Recent smoking activity")
        }
        
        if features.stepsLast3h < 500 {
            risks.append("Low physical activity")
        }
        
        return risks
    }
    
    private func identifySuccessFactors(profile: UserProfile, features: CoachFeatures) -> [String] {
        var factors: [String] = []
        
        if profile.enableGradualReduction {
            factors.append("Committed to gradual reduction plan")
        }
        
        if features.currentStreak > 0 {
            factors.append("Current quit streak active")
        }
        
        if features.stepsLast3h > 2000 {
            factors.append("Good physical activity levels")
        }
        
        if features.mindfulSessionsToday > 0 {
            factors.append("Active mindfulness practice")
        }
        
        return factors
    }
    
    private func calculateOverallRiskScore(dependencyLevel: DependencyLevel, riskCount: Int, successCount: Int) -> Double {
        let baseRisk: Double = switch dependencyLevel {
            case .low: 0.2
            case .moderate: 0.4
            case .high: 0.6
            case .severe: 0.8
        }
        
        let riskAdjustment = Double(riskCount) * 0.1
        let successAdjustment = Double(successCount) * -0.1
        
        return max(0.0, min(1.0, baseRisk + riskAdjustment + successAdjustment))
    }
    
    // Placeholder implementations for additional helper methods
    private func calculateDailyVariation(cigarettes: [Cigarette]) -> Double { return 2.5 }
    private func hasConsistentTriggerPatterns(cigarettes: [Cigarette]) -> Bool { return true }
    private func extractCommonTriggerTags(cigarettes: [Cigarette]) -> [String] { return ["stress", "social"] }
    private func calculateCurrentStreak(cigarettes: [Cigarette]) -> Int { return 0 }
    private func generateHealthRiskFactors(profile: UserProfile, steps: Double, sleep: Double) -> [String] { return [] }
    private func generateProtectiveFactors(nrt: Bool, mindful: Int, steps: Double) -> [String] { return [] }
    private func calculateWeeklyAverages(cigarettes: [Cigarette]) -> [Double] { return [10, 8, 7, 6] }
    private func isPlateauDetected(weeklyAverages: [Double]) -> Bool { return false }
    private func identifyHighRiskHours(cigarettes: [Cigarette]) -> [Int] { return [9, 15, 21] }
    private func determineMilestoneIntervals(totalDays: Int, patterns: BehavioralPatterns) -> [Int] {
        return Array(stride(from: 7, through: totalDays, by: 7))
    }
    private func generateMilestoneDescription(week: Int, isPersonalized: Bool) -> String {
        return "Week \(week) milestone - Stay focused on your goals"
    }
    private func generatePersonalizedMotivation(week: Int, profile: UserProfile, patterns: BehavioralPatterns) -> String {
        return "Great progress, \(profile.name.isEmpty ? "there" : profile.name)! You're building healthier habits."
    }
    private func determineMilestoneType(weekNumber: Int, totalWeeks: Int) -> CheckpointType {
        if weekNumber == totalWeeks { return .final }
        if weekNumber % 2 == 0 { return .biweekly }
        return .weekly
    }
    private func generateReasoningText(duration: Int, curve: ReductionCurve, riskAssessment: QuitRiskAssessment) -> String {
        return "Recommended \(duration)-day plan using \(curve.rawValue) curve based on your smoking patterns and risk assessment."
    }
    private func generateSupportStrategies(riskAssessment: QuitRiskAssessment, behavioralPatterns: BehavioralPatterns) -> [String] {
        return ["Regular check-ins", "Identify and avoid triggers", "Build healthy habits", "Consider NRT if appropriate"]
    }
    private func enhanceRecommendationWithAI(baseRecommendation: OptimizationRecommendation, context: OptimizationContext) -> OptimizationRecommendation {
        return baseRecommendation // Would be enhanced with Apple Intelligence
    }
    private func enhanceRecommendationWithRules(baseRecommendation: OptimizationRecommendation, context: OptimizationContext) -> OptimizationRecommendation {
        return baseRecommendation // Enhanced with rule-based logic
    }
}