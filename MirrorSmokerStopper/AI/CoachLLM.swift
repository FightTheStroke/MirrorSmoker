//
//  CoachLLM.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import os.log

// MARK: - iOS 26 AI Coach with Apple Intelligence

@available(iOS 26, *)
enum CoachLLM {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "CoachLLM")
    
    struct Context: Sendable {
        let features: CoachFeatures
        let language: String
        
        init(features: CoachFeatures, language: String = "en") {
            self.features = features
            self.language = language
        }
    }
    
    static func generateTip(context: Context) async -> String {
        // TODO: Replace with actual Apple Intelligence Foundation Models API when available
        // This is a placeholder implementation that will be replaced with the official iOS 26 API
        
        /*
         Future implementation when Apple Intelligence SDK is available:
         
         let model = AI.FoundationModels.defaultSmall()
         let prompt = buildPrompt(context: context)
         
         do {
             let response = try await model.generateText(
                 prompt: prompt,
                 parameters: AI.GenerationParameters(
                     maxTokens: 100,
                     temperature: 0.7,
                     topP: 0.9
                 )
             )
             return response.text
         } catch {
             logger.error("AI generation failed: \(error)")
             return fallbackTip(context: context)
         }
         */
        
        // Current placeholder implementation
        logger.info("Generating AI tip for iOS 26 (placeholder implementation)")
        return await generatePlaceholderTip(context: context)
    }
    
    private static func generatePlaceholderTip(context: Context) async -> String {
        let features = context.features
        let language = context.language
        
        // Simulate AI processing delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Context-aware tip generation based on features
        if features.minutesSinceLastCig < 30 {
            return localizedTip("recent_cigarette", language: language, features: features)
        } else if features.currentStreak > 0 {
            return localizedTip("on_streak", language: language, features: features)
        } else if features.sleptShortLastNight {
            return localizedTip("poor_sleep", language: language, features: features)
        } else if features.stepsLast3h < 1000 {
            return localizedTip("low_activity", language: language, features: features)
        } else if features.timeOfDayRisk > 0.7 {
            return localizedTip("high_risk_hour", language: language, features: features)
        } else if features.usedNRTLast12h {
            return localizedTip("nrt_support", language: language, features: features)
        } else {
            return localizedTip("general_motivation", language: language, features: features)
        }
    }
    
    private static func localizedTip(_ key: String, language: String, features: CoachFeatures) -> String {
        switch language {
        case "it":
            return italianTips(key: key, features: features)
        default:
            return englishTips(key: key, features: features)
        }
    }
    
    private static func englishTips(key: String, features: CoachFeatures) -> String {
        switch key {
        case "recent_cigarette":
            return "Take 5 deep breaths. Each minute without smoking is progress."
        case "on_streak":
            return "Day \(features.currentStreak) smoke-free! Try 3 minutes of mindful breathing."
        case "poor_sleep":
            return "Tired? Try box breathing: 4-4-4-4. Rest without reaching for cigarettes."
        case "low_activity":
            return "Move for 2 minutes. Walk, stretch, or do jumping jacks instead."
        case "high_risk_hour":
            return "This is your trigger time. Drink water and change your environment."
        case "nrt_support":
            return "Your NRT is working. Add 1 minute of breathing exercises for extra support."
        case "general_motivation":
            return "Stay strong. Every moment you resist is your body healing."
        default:
            return "You're doing great. One breath at a time."
        }
    }
    
    private static func italianTips(key: String, features: CoachFeatures) -> String {
        switch key {
        case "recent_cigarette":
            return "Fai 5 respiri profondi. Ogni minuto senza fumare è un progresso."
        case "on_streak":
            return "Giorno \(features.currentStreak) senza fumo! Prova 3 minuti di respirazione consapevole."
        case "poor_sleep":
            return "Stanco? Prova la respirazione quadrata: 4-4-4-4. Riposati senza accendere."
        case "low_activity":
            return "Muoviti per 2 minuti. Cammina, stiracchiati o fai jumping jack."
        case "high_risk_hour":
            return "Questo è il tuo momento critico. Bevi acqua e cambia ambiente."
        case "nrt_support":
            return "La tua terapia sostitutiva sta funzionando. Aggiungi 1 minuto di respirazione."
        case "general_motivation":
            return "Stai andando forte. Ogni momento di resistenza è il tuo corpo che guarisce."
        default:
            return "Stai andando benissimo. Un respiro alla volta."
        }
    }
    
    private static func buildPrompt(context: Context) -> String {
        let features = context.features
        
        let systemPrompt = """
        You are a supportive smoking cessation coach. Generate a brief (20-25 words), actionable tip in \(context.language).
        
        Context:
        - Minutes since last cigarette: \(features.minutesSinceLastCig)
        - Hour of day: \(features.hour)
        - Steps last 3h: \(features.stepsLast3h)
        - Poor sleep: \(features.sleptShortLastNight)
        - Using NRT: \(features.usedNRTLast12h)
        - Smoke-free streak: \(features.currentStreak) days
        - Risk level this hour: \(features.timeOfDayRisk)
        
        Guidelines:
        - Be empathetic, never judgmental
        - Focus on immediate, actionable steps
        - Use breathing, movement, or environment change techniques
        - Keep under 25 words
        - Match the user's language (\(context.language))
        """
        
        return systemPrompt
    }
}

// MARK: - Fallback Coach (iOS < 26)

enum FallbackCoach {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "FallbackCoach")
    
    struct Context: Sendable {
        let features: CoachFeatures
        let language: String
        
        init(features: CoachFeatures, language: String = "en") {
            self.features = features
            self.language = language
        }
    }
    
    static func generateTip(context: Context) -> String {
        logger.info("Using fallback coach for iOS < 26")
        
        let tips = TipLibrary.shared.getTips(
            for: context.features,
            language: context.language
        )
        
        return tips.randomElement() ?? "Stay strong. You're doing great."
    }
}
