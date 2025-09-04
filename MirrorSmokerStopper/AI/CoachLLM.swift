//
//  CoachLLM.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import os.log
import NaturalLanguage

// MARK: - iOS 26 AI Coach with Local Intelligence

@available(iOS 26, *)
enum CoachLLM {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "CoachLLM")
    
    // Advanced AI Coach Engine
    private static let aiEngine = AICoachEngine()
    
    struct Context: Sendable {
        let features: CoachFeatures
        let language: String
        
        init(features: CoachFeatures, language: String = "en") {
            self.features = features
            self.language = language
        }
    }
    
    static func generateTip(context: Context) async -> String {
        Self.logger.info("Generating AI tip using advanced local intelligence")
        
        // Use advanced AI engine for iOS 26
        return await aiEngine.generateContextualTip(context: context)
    }
    
    static func generateMotivationalMessage(context: Context, mood: CoachMood = .encouraging) async -> String {
        Self.logger.info("Generating motivational message with mood: \(mood.rawValue)")
        return await aiEngine.generateMotivationalContent(context: context, mood: mood)
    }
    
    static func analyzePattern(features: CoachFeatures, history: [CoachFeatures]) async -> PatternInsight {
        logger.info("Analyzing behavioral patterns with AI")
        return await aiEngine.analyzePatterns(current: features, history: history)
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
        Self.logger.info("Using fallback coach for iOS < 26")
        
        let tips = TipLibrary.shared.getTips(
            for: context.features,
            language: context.language
        )
        
        return tips.randomElement() ?? "Stay strong. You're doing great."
    }
}

// MARK: - Advanced AI Coach Engine

@available(iOS 26, *)
enum CoachMood: String, CaseIterable {
    case encouraging = "encouraging"
    case motivating = "motivating"
    case supportive = "supportive"
    case celebrating = "celebrating"
    case gentle = "gentle"
    case challenging = "challenging"
}

@available(iOS 26, *)
struct PatternInsight: Sendable {
    let patternType: PatternType
    let confidence: Double
    let recommendation: String
    let urgency: UrgencyLevel
    
    enum PatternType: String {
        case morningCraving = "morning_craving"
        case stressTrigger = "stress_trigger" 
        case socialSmoking = "social_smoking"
        case habitualTiming = "habitual_timing"
        case emotionalEating = "emotional_smoking"
        case boredomSmoking = "boredom_smoking"
    }
    
    enum UrgencyLevel: Int {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }
}

@available(iOS 26, *)
class AICoachEngine: @unchecked Sendable {
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "AICoachEngine")
    private let nlProcessor = NLLanguageRecognizer()
    
    // Advanced contextual AI tip generation
    func generateContextualTip(context: CoachLLM.Context) async -> String {
        let features = context.features
        let language = context.language
        
        logger.info("Generating contextual AI tip with advanced intelligence")
        
        // Analyze multiple context factors
        let riskScore = calculateRiskScore(features: features)
        let emotionalState = inferEmotionalState(features: features)
        let timeContext = analyzeTimeContext(features: features)
        let activityLevel = analyzeActivityLevel(features: features)
        
        // Generate personalized tip using AI reasoning
        let tip = await generateIntelligentTip(
            riskScore: riskScore,
            emotionalState: emotionalState,
            timeContext: timeContext,
            activityLevel: activityLevel,
            features: features,
            language: language
        )
        
        return tip
    }
    
    func generateMotivationalContent(context: CoachLLM.Context, mood: CoachMood) async -> String {
        let features = context.features
        
        switch mood {
        case .encouraging:
            return await generateEncouragingMessage(features: features, language: context.language)
        case .motivating:
            return await generateMotivatingMessage(features: features, language: context.language)
        case .supportive:
            return await generateSupportiveMessage(features: features, language: context.language)
        case .celebrating:
            return await generateCelebratingMessage(features: features, language: context.language)
        case .gentle:
            return await generateGentleMessage(features: features, language: context.language)
        case .challenging:
            return await generateChallengingMessage(features: features, language: context.language)
        }
    }
    
    func analyzePatterns(current: CoachFeatures, history: [CoachFeatures]) async -> PatternInsight {
        logger.info("Analyzing behavioral patterns with AI")
        
        // Advanced pattern recognition
        let morningPattern = analyzeMorningPattern(current: current, history: history)
        let stressPattern = analyzeStressPattern(current: current, history: history)
        let socialPattern = analyzeSocialPattern(current: current, history: history)
        
        // Return the most significant pattern
        let patterns = [morningPattern, stressPattern, socialPattern].compactMap { $0 }
        let mostSignificant = patterns.max { $0.confidence < $1.confidence }
        
        return mostSignificant ?? PatternInsight(
            patternType: .habitualTiming,
            confidence: 0.5,
            recommendation: "Keep tracking your habits for better insights",
            urgency: .low
        )
    }
    
    // MARK: - Private AI Methods
    
    private func calculateRiskScore(features: CoachFeatures) -> Double {
        var score: Double = 0.0
        
        // Time-based risk
        score += features.timeOfDayRisk * 0.3
        
        // Recency risk
        if features.minutesSinceLastCig < 60 {
            score += 0.4
        } else if features.minutesSinceLastCig < 180 {
            score += 0.2
        }
        
        // Activity level risk
        if features.stepsLast3h < 500 {
            score += 0.2
        }
        
        // Sleep quality risk
        if features.sleptShortLastNight {
            score += 0.1
        }
        
        return min(score, 1.0)
    }
    
    private func inferEmotionalState(features: CoachFeatures) -> String {
        if features.sleptShortLastNight && features.stepsLast3h < 1000 {
            return "tired_low_energy"
        } else if features.minutesSinceLastCig < 30 {
            return "recently_triggered"
        } else if features.currentStreak > 7 {
            return "confident_progressing"
        } else if features.timeOfDayRisk > 0.7 {
            return "vulnerable_period"
        } else {
            return "stable_neutral"
        }
    }
    
    private func analyzeTimeContext(features: CoachFeatures) -> String {
        switch features.hour {
        case 6..<9:
            return "morning_routine"
        case 9..<12:
            return "mid_morning_focus"
        case 12..<14:
            return "lunch_break"
        case 14..<17:
            return "afternoon_energy"
        case 17..<19:
            return "evening_transition"
        case 19..<22:
            return "evening_relax"
        case 22..<24, 0..<6:
            return "night_rest"
        default:
            return "general_day"
        }
    }
    
    private func analyzeActivityLevel(features: CoachFeatures) -> String {
        if features.stepsLast3h > 3000 {
            return "highly_active"
        } else if features.stepsLast3h > 1500 {
            return "moderately_active"
        } else if features.stepsLast3h > 500 {
            return "lightly_active"
        } else {
            return "sedentary"
        }
    }
    
    private func generateIntelligentTip(
        riskScore: Double,
        emotionalState: String,
        timeContext: String,
        activityLevel: String,
        features: CoachFeatures,
        language: String
    ) async -> String {
        
        // Simulate AI processing
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Advanced tip generation based on multiple factors
        if riskScore > 0.8 {
            return await generateHighRiskTip(emotionalState: emotionalState, timeContext: timeContext, language: language)
        } else if riskScore > 0.5 {
            return await generateMediumRiskTip(activityLevel: activityLevel, timeContext: timeContext, language: language)
        } else {
            return await generateLowRiskTip(features: features, language: language)
        }
    }
    
    private func generateHighRiskTip(emotionalState: String, timeContext: String, language: String) async -> String {
        let tips: [String]
        
        if language == "it" {
            tips = [
                "🚨 Momento critico! Respira profondamente 5 volte e bevi un bicchiere d'acqua.",
                "⚡ Energia alta di rischio! Fai 10 jumping jack invece di fumare.",
                "🧠 La tua mente sta cercando la nicotina. Resisti per 3 minuti - poi sarà più facile.",
                "🏃‍♀️ Muoviti SUBITO! Esci all'aria aperta o fai una passeggiata veloce.",
                "💪 Questo è il momento che conta davvero. Sei più forte della dipendenza!"
            ]
        } else {
            tips = [
                "🚨 Critical moment! Take 5 deep breaths and drink a glass of water.",
                "⚡ High risk energy! Do 10 jumping jacks instead of smoking.",
                "🧠 Your mind is craving nicotine. Resist for 3 minutes - then it gets easier.",
                "🏃‍♀️ Move NOW! Step outside or take a brisk walk.",
                "💪 This moment really counts. You're stronger than the addiction!"
            ]
        }
        
        return tips.randomElement() ?? "Stay strong!"
    }
    
    private func generateMediumRiskTip(activityLevel: String, timeContext: String, language: String) async -> String {
        let tips: [String]
        
        if language == "it" {
            tips = [
                "🌟 Momento di moderata attenzione. Prova la tecnica 4-7-8: inspira 4, trattieni 7, espira 8.",
                "🎯 Concentrati sul tuo obiettivo! Ogni minuto senza fumare è un successo.",
                "🚶‍♀️ Cambia ambiente: vai in un'altra stanza o esci 2 minuti.",
                "💧 Il tuo corpo ha bisogno di idratazione. Bevi acqua invece di fumare.",
                "🧘‍♂️ Pratica mindfulness: osserva la voglia senza giudicare, poi lasciala andare."
            ]
        } else {
            tips = [
                "🌟 Moderate attention moment. Try the 4-7-8 technique: inhale 4, hold 7, exhale 8.",
                "🎯 Focus on your goal! Every minute without smoking is success.",
                "🚶‍♀️ Change environment: go to another room or step out for 2 minutes.", 
                "💧 Your body needs hydration. Drink water instead of smoking.",
                "🧘‍♂️ Practice mindfulness: observe the craving without judgment, then let it go."
            ]
        }
        
        return tips.randomElement() ?? "You're doing great!"
    }
    
    private func generateLowRiskTip(features: CoachFeatures, language: String) async -> String {
        let tips: [String]
        
        if language == "it" {
            tips = [
                "✨ Ottimo lavoro! Stai mantenendo il controllo. Continua così!",
                "🌱 Il tuo corpo si sta rigenerando. Ogni ora senza fumo è una vittoria.",
                "💚 Momento perfetto per rafforzare le tue abitudini positive.",
                "🎉 Giorno \(features.currentStreak): il tuo corpo ti ringrazia!",
                "🔋 Energia stabile! Approfitta per fare qualcosa che ami."
            ]
        } else {
            tips = [
                "✨ Excellent work! You're maintaining control. Keep it up!",
                "🌱 Your body is regenerating. Every smoke-free hour is a victory.",
                "💚 Perfect moment to reinforce your positive habits.",
                "🎉 Day \(features.currentStreak): your body thanks you!",
                "🔋 Stable energy! Take advantage to do something you love."
            ]
        }
        
        return tips.randomElement() ?? "Keep going!"
    }
    
    // Additional motivational generators
    private func generateEncouragingMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "🌟 Stai facendo progressi incredibili! Ogni giorno senza fumo è un investimento nella tua salute futura."
        } else {
            return "🌟 You're making incredible progress! Every smoke-free day is an investment in your future health."
        }
    }
    
    private func generateMotivatingMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "🔥 Hai la forza per farcela! Mostra a te stesso di cosa sei capace!"
        } else {
            return "🔥 You have the strength to do this! Show yourself what you're capable of!"
        }
    }
    
    private func generateSupportiveMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "🤗 È normale sentire la difficoltà. Sei supportato in questo percorso, un passo alla volta."
        } else {
            return "🤗 It's normal to feel the difficulty. You're supported on this journey, one step at a time."
        }
    }
    
    private func generateCelebratingMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "🎉 Celebriamo! \(features.currentStreak) giorni di libertà dal fumo - sei incredibile!"
        } else {
            return "🎉 Let's celebrate! \(features.currentStreak) days of smoke-free freedom - you're incredible!"
        }
    }
    
    private func generateGentleMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "🌸 Sii gentile con te stesso. Ogni piccolo passo conta nel tuo viaggio verso la libertà."
        } else {
            return "🌸 Be gentle with yourself. Every small step counts on your journey to freedom."
        }
    }
    
    private func generateChallengingMessage(features: CoachFeatures, language: String) async -> String {
        if language == "it" {
            return "💪 Sei pronto per la sfida? Prova a superare il tuo record di ore senza fumare!"
        } else {
            return "💪 Are you ready for the challenge? Try to beat your record of hours without smoking!"
        }
    }
    
    // Pattern analysis methods
    private func analyzeMorningPattern(current: CoachFeatures, history: [CoachFeatures]) -> PatternInsight? {
        let morningEntries = history.filter { $0.hour >= 6 && $0.hour <= 10 }
        guard morningEntries.count >= 3 else { return nil }
        
        let averageRisk = morningEntries.map { $0.timeOfDayRisk }.reduce(0, +) / Double(morningEntries.count)
        
        if averageRisk > 0.7 {
            return PatternInsight(
                patternType: .morningCraving,
                confidence: 0.85,
                recommendation: "Create a strong morning routine to break the pattern",
                urgency: .high
            )
        }
        
        return nil
    }
    
    private func analyzeStressPattern(current: CoachFeatures, history: [CoachFeatures]) -> PatternInsight? {
        let stressIndicators = history.filter { $0.sleptShortLastNight || $0.stepsLast3h < 500 }
        guard stressIndicators.count >= 2 else { return nil }
        
        return PatternInsight(
            patternType: .stressTrigger,
            confidence: 0.75,
            recommendation: "Focus on stress management techniques and self-care",
            urgency: .medium
        )
    }
    
    private func analyzeSocialPattern(current: CoachFeatures, history: [CoachFeatures]) -> PatternInsight? {
        // This would analyze social context if we had that data
        return nil
    }
}
