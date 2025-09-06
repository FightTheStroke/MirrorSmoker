//
//  AICoachManagerCompat.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import Foundation
import SwiftData
import os.log

// Compatibility wrapper for AICoachManager that works on all iOS versions
@MainActor
class AICoachManagerCompat: ObservableObject {
    static let shared = AICoachManagerCompat()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "AICoachManagerCompat")
    
    @Published var currentTip: String?
    @Published var isGeneratingTip = false
    
    // Internal reference to iOS 26+ manager - created conditionally
    private var modernManager: Any?
    
    private init() {}
    
    func generateDailyTip(modelContext: ModelContext, userProfile: UserProfile? = nil) async {
        guard !isGeneratingTip else { return }
        
        isGeneratingTip = true
        logger.info("Generating daily tip with compatibility layer")
        
        if #available(iOS 26, *) {
            // Use modern AI Coach for iOS 26+
            if modernManager == nil {
                modernManager = AICoachManager.shared
            }
            guard let manager = modernManager as? AICoachManager else {
                logger.error("Failed to cast modernManager to AICoachManager")
                await generateFallbackTip(modelContext: modelContext, userProfile: userProfile)
                isGeneratingTip = false
                return
            }
            await manager.generateDailyTip(modelContext: modelContext, userProfile: userProfile)
            currentTip = manager.currentTip
        } else {
            // Fallback for iOS < 26
            await generateFallbackTip(modelContext: modelContext, userProfile: userProfile)
        }
        
        isGeneratingTip = false
    }
    
    private func generateFallbackTip(modelContext: ModelContext, userProfile: UserProfile?) async {
        // Use basic CoachEngine for older iOS versions
        let coachEngine = CoachEngine.shared
        let action = await coachEngine.decide(modelContext: modelContext, userProfile: userProfile, forceEvaluation: true)
        currentTip = action.tip ?? getFallbackTip()
        logger.info("Generated fallback tip for iOS < 26")
    }
    
    private func getFallbackTip() -> String {
        let language = getCurrentLanguage()
        
        let tips = [
            language == "it" ? "🌟 Respira profondamente. Ogni momento senza fumare è un progresso." : "🌟 Take a deep breath. Every moment without smoking is progress.",
            language == "it" ? "💪 La tua forza di volontà cresce ogni giorno." : "💪 Your willpower grows stronger each day.",
            language == "it" ? "🎯 Concentrati sui tuoi obiettivi di salute." : "🎯 Focus on your health goals.",
            language == "it" ? "🌱 Ogni giorno senza fumare è un passo verso una vita più sana." : "🌱 Every smoke-free day is a step toward a healthier life."
        ]
        
        return tips.randomElement() ?? tips[0]
    }
    
    private func getCurrentLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
}