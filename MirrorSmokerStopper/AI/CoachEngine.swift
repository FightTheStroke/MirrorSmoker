//
//  CoachEngine.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import CoreML
import SwiftData
import UserNotifications
import os.log

enum CoachAction: Equatable {
    case nudge(String)
    case none
    
    var tip: String? {
        if case .nudge(let tip) = self {
            return tip
        }
        return nil
    }
}

@MainActor
final class CoachEngine: ObservableObject {
    static let shared = CoachEngine()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "CoachEngine")
    private let featureStore = FeatureStore.shared
    
    // Core ML model for risk classification (placeholder until actual model is trained)
    private var model: MLModel?
    
    // Rate limiting and quiet hours
    private var lastNudgeTime: Date?
    private var quietHoursStart: Int = 22 // 10 PM
    private var quietHoursEnd: Int = 6 // 6 AM
    private let minimumNudgeInterval: TimeInterval = 4 * 3600 // 4 hours
    
    private init() {
        loadModel()
    }
    
    func decide(
        modelContext: ModelContext,
        userProfile: UserProfile? = nil,
        forceEvaluation: Bool = false
    ) async -> CoachAction {
        
        // Check rate limiting unless forced
        if !forceEvaluation && shouldSkipDueToRateLimit() {
            logger.debug("Skipping coach evaluation due to rate limit")
            return .none
        }
        
        // Check quiet hours unless forced
        if !forceEvaluation && isQuietHour() {
            logger.debug("Skipping coach evaluation during quiet hours")
            return .none
        }
        
        // Collect features
        let features = await featureStore.collect(from: modelContext, userProfile: userProfile)
        logger.debug("Collected features: \(features.asDictionary)")
        
        // Apply safety rules
        if !SafetyRules.shared.shouldAllowNudge(features: features, userProfile: userProfile) {
            logger.debug("Safety rules prevented nudge generation")
            return .none
        }
        
        // Determine risk level
        let riskLevel = await calculateRiskLevel(features: features)
        logger.debug("Calculated risk level: \(riskLevel)")
        
        // Generate tip if risk is high enough
        if riskLevel > 0.6 {
            let tip = await generateTip(features: features, userProfile: userProfile)
            
            if !forceEvaluation {
                lastNudgeTime = Date()
            }
            
            logger.info("Generated coaching tip for high risk situation")
            return .nudge(tip)
        }
        
        return .none
    }
    
    // MARK: - Risk Calculation
    
    private func calculateRiskLevel(features: CoachFeatures) async -> Double {
        // If Core ML model is available, use it
        if let model = model {
            return await classifyWithCoreML(features: features, model: model)
        }
        
        // Fallback: rule-based risk calculation
        return calculateRuleBasedRisk(features: features)
    }
    
    private func classifyWithCoreML(features: CoachFeatures, model: MLModel) async -> Double {
        do {
            // This would be the actual Core ML prediction
            // For now, using rule-based fallback since we don't have a trained model yet
            logger.debug("Core ML model not yet implemented, using rule-based risk")
            return calculateRuleBasedRisk(features: features)
            
            /*
             Future implementation with trained Core ML model:
             
             let input = OnDeviceNudgeClassifierInput(
                 minutesSinceLastCig: features.minutesSinceLastCig,
                 hour: Double(features.hour),
                 stepsLast3h: features.stepsLast3h,
                 sleptShortLastNight: features.sleptShortLastNight ? 1 : 0,
                 usedNRTLast12h: features.usedNRTLast12h ? 1 : 0,
                 timeOfDayRisk: features.timeOfDayRisk,
                 avgCigarettesPerDay: features.avgCigarettesPerDay
             )
             
             let output = try model.prediction(from: input)
             return output.risk
             */
        }
    }
    
    private func calculateRuleBasedRisk(features: CoachFeatures) -> Double {
        var risk: Double = 0.0
        
        // Recent cigarette increases risk
        if features.minutesSinceLastCig < 60 {
            risk += 0.3
        } else if features.minutesSinceLastCig < 120 {
            risk += 0.2
        }
        
        // Time-of-day historical risk
        risk += features.timeOfDayRisk * 0.4
        
        // Poor sleep increases risk
        if features.sleptShortLastNight {
            risk += 0.2
        }
        
        // Low activity increases risk
        if features.stepsLast3h < 1000 {
            risk += 0.15
        }
        
        // High average consumption increases baseline risk
        if features.avgCigarettesPerDay > 15 {
            risk += 0.1
        }
        
        // NRT usage reduces risk
        if features.usedNRTLast12h {
            risk *= 0.7
        }
        
        // Longer streaks reduce risk
        if features.currentStreak > 0 {
            risk *= max(0.3, 1.0 - (Double(features.currentStreak) / 30.0))
        }
        
        return min(1.0, max(0.0, risk))
    }
    
    // MARK: - Tip Generation
    
    private func generateTip(features: CoachFeatures, userProfile: UserProfile?) async -> String {
        let language = getCurrentLanguage()
        
        // Use iOS 26 Apple Intelligence if available
        if #available(iOS 26, *) {
            let context = CoachLLM.Context(
                features: features,
                language: language
            )
            return await CoachLLM.generateTip(context: context)
        } else {
            // Fallback for iOS < 26
            let fallbackContext = FallbackCoach.Context(features: features, language: language)
            return FallbackCoach.generateTip(context: fallbackContext)
        }
    }
    
    // MARK: - Rate Limiting & Quiet Hours
    
    private func shouldSkipDueToRateLimit() -> Bool {
        guard let lastNudgeTime = lastNudgeTime else { return false }
        
        let timeSinceLastNudge = Date().timeIntervalSince(lastNudgeTime)
        return timeSinceLastNudge < minimumNudgeInterval
    }
    
    private func isQuietHour() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Handle quiet hours spanning midnight (e.g., 22 PM to 6 AM)
        if quietHoursStart > quietHoursEnd {
            return hour >= quietHoursStart || hour <= quietHoursEnd
        } else {
            return hour >= quietHoursStart && hour <= quietHoursEnd
        }
    }
    
    func updateQuietHours(start: Int, end: Int) {
        quietHoursStart = start
        quietHoursEnd = end
        logger.info("Updated quiet hours: \(start):00 to \(end):00")
    }
    
    func updateQuietHours(_ hours: ClosedRange<Int>) {
        // For backward compatibility with existing range-based API
        quietHoursStart = hours.lowerBound
        quietHoursEnd = hours.upperBound
        logger.info("Updated quiet hours: \(hours.lowerBound):00 to \(hours.upperBound):00")
    }
    
    // MARK: - Model Loading
    
    private func loadModel() {
        // Placeholder for Core ML model loading
        // The actual model would be trained offline and included in the app bundle
        
        /*
         Future implementation:
         
         guard let modelURL = Bundle.main.url(forResource: "OnDeviceNudgeClassifier", withExtension: "mlmodelc") else {
             logger.warning("Core ML model not found in bundle")
             return
         }
         
         do {
             let config = MLModelConfiguration()
             config.computeUnits = .all
             model = try MLModel(contentsOf: modelURL, configuration: config)
             logger.info("Successfully loaded Core ML model")
         } catch {
             logger.error("Failed to load Core ML model: \(error.localizedDescription)")
         }
         */
        
        logger.debug("Core ML model placeholder - using rule-based risk assessment")
    }
    
    // MARK: - Utilities
    
    private func getCurrentLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
}

// MARK: - Safety Rules Extension

extension SafetyRules {
    func shouldAllowNudge(features: CoachFeatures, userProfile: UserProfile?) -> Bool {
        // Don't nudge if user just smoked (less than 10 minutes ago)
        if features.minutesSinceLastCig < 10 {
            return false
        }
        
        // Don't nudge during very late or very early hours unless high risk
        let hour = Calendar.current.component(.hour, from: Date())
        if (hour >= 23 || hour <= 5) && features.timeOfDayRisk < 0.8 {
            return false
        }
        
        // Don't nudge if user has a very long current streak (they're doing well)
        if features.currentStreak > 30 && features.timeOfDayRisk < 0.9 {
            return false
        }
        
        return true
    }
}
