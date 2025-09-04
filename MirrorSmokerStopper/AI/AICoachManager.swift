//
//  AICoachManager.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import Foundation
import SwiftData
import os.log

@available(iOS 26, *)
@MainActor
class AICoachManager: ObservableObject {
    static let shared = AICoachManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "AICoachManager")
    private let coachEngine = CoachEngine.shared
    private let featureStore = FeatureStore.shared
    
    @Published var currentTip: String?
    @Published var currentMood: CoachMood = .encouraging
    @Published var isGeneratingTip = false
    @Published var patternInsights: [PatternInsight] = []
    
    private var featureHistory: [CoachFeatures] = []
    private let maxHistorySize = 100
    
    private init() {
        loadFeatureHistory()
    }
    
    // MARK: - Public Interface
    
    func generateDailyTip(modelContext: ModelContext, userProfile: UserProfile? = nil) async {
        guard !isGeneratingTip else { return }
        
        isGeneratingTip = true
        logger.info("Generating daily AI coaching tip")
        
        // Get current features
        let features = await featureStore.collect(from: modelContext, userProfile: userProfile)
        
        // Store in history
        addToHistory(features)
        
        // Use advanced AI coach for iOS 26+
        if #available(iOS 26, *), AIConfiguration.shared.isAIAvailable {
            let context = CoachLLM.Context(features: features, language: getCurrentLanguage())
            currentTip = await CoachLLM.generateTip(context: context)
            logger.info("Generated AI tip using iOS 26 local intelligence")
        } else {
            // Fallback to basic coach engine
            let action = await coachEngine.decide(modelContext: modelContext, userProfile: userProfile, forceEvaluation: true)
            currentTip = action.tip ?? getEmergencyTip()
            logger.info("Generated tip using fallback coach engine")
        }
        
        isGeneratingTip = false
    }
    
    func generateMotivationalMessage(mood: CoachMood, modelContext: ModelContext, userProfile: UserProfile? = nil) async -> String {
        logger.info("Generating motivational message with mood: \(mood.rawValue)")
        
        guard #available(iOS 26, *), AIConfiguration.shared.isAIAvailable else {
            return getFallbackMotivationalMessage(mood: mood)
        }
        
        let features = await featureStore.collect(from: modelContext, userProfile: userProfile)
        let context = CoachLLM.Context(features: features, language: getCurrentLanguage())
        
        return await CoachLLM.generateMotivationalMessage(context: context, mood: mood)
    }
    
    func analyzePatterns(modelContext: ModelContext, userProfile: UserProfile? = nil) async {
        guard #available(iOS 26, *), AIConfiguration.shared.isAIAvailable else {
            logger.info("Pattern analysis requires iOS 26+")
            return
        }
        
        logger.info("Analyzing behavioral patterns with AI")
        
        let currentFeatures = await featureStore.collect(from: modelContext, userProfile: userProfile)
        let insight = await CoachLLM.analyzePattern(features: currentFeatures, history: featureHistory)
        
        // Update patterns array
        if !patternInsights.contains(where: { $0.patternType == insight.patternType }) {
            patternInsights.append(insight)
            
            // Keep only the most relevant patterns
            patternInsights = Array(patternInsights.sorted { $0.confidence > $1.confidence }.prefix(3))
        }
    }
    
    func getPersonalizedNudge(context: TriggerContext, modelContext: ModelContext, userProfile: UserProfile? = nil) async -> String? {
        logger.info("Getting personalized nudge for context: \(context.rawValue)")
        
        let action = await coachEngine.decide(modelContext: modelContext, userProfile: userProfile, forceEvaluation: true)
        return action.tip
    }
    
    // MARK: - Private Methods
    
    private func addToHistory(_ features: CoachFeatures) {
        featureHistory.append(features)
        
        // Keep history size manageable
        if featureHistory.count > maxHistorySize {
            featureHistory = Array(featureHistory.suffix(maxHistorySize))
        }
        
        saveFeatureHistory()
    }
    
    private func loadFeatureHistory() {
        if let data = UserDefaults.standard.data(forKey: "ai_coach_feature_history"),
           let history = try? JSONDecoder().decode([CoachFeatures].self, from: data) {
            featureHistory = history
            logger.info("Loaded \(history.count) feature history entries")
        }
    }
    
    private func saveFeatureHistory() {
        if let data = try? JSONEncoder().encode(featureHistory) {
            UserDefaults.standard.set(data, forKey: "ai_coach_feature_history")
        }
    }
    
    private func getCurrentLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    private func getEmergencyTip() -> String {
        let language = getCurrentLanguage()
        
        if language == "it" {
            return "🌟 Respira profondamente. Ogni momento senza fumare è un progresso."
        } else {
            return "🌟 Take a deep breath. Every moment without smoking is progress."
        }
    }
    
    private func getFallbackMotivationalMessage(mood: CoachMood) -> String {
        let language = getCurrentLanguage()
        
        switch mood {
        case .encouraging:
            return language == "it" ? "🌟 Stai facendo un ottimo lavoro!" : "🌟 You're doing great!"
        case .motivating:
            return language == "it" ? "🔥 Continua così, sei più forte!" : "🔥 Keep going, you're stronger!"
        case .supportive:
            return language == "it" ? "🤗 Siamo qui per sostenerti." : "🤗 We're here to support you."
        case .celebrating:
            return language == "it" ? "🎉 Celebriamo i tuoi progressi!" : "🎉 Let's celebrate your progress!"
        case .gentle:
            return language == "it" ? "🌸 Sii gentile con te stesso." : "🌸 Be gentle with yourself."
        case .challenging:
            return language == "it" ? "💪 Sei pronto per la sfida?" : "💪 Are you ready for the challenge?"
        }
    }
}

// MARK: - Supporting Types

enum TriggerContext: String, CaseIterable {
    case morningRoutine = "morning_routine"
    case stressfulMoment = "stressful_moment"
    case socialSituation = "social_situation"
    case boredom = "boredom"
    case habitalTiming = "habitual_timing"
    case celebration = "celebration"
}

@available(iOS 26, *)
extension CoachMood: Identifiable {
    var id: String { rawValue }
}

@available(iOS 26, *)
extension PatternInsight: Identifiable {
    var id: String { patternType.rawValue }
}