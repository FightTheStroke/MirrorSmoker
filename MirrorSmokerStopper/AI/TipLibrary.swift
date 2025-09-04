//
//  TipLibrary.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation

// MARK: - Tip Models

struct CoachTip {
    let content: String
    let category: TipCategory
    let contexts: [TipContext]
    let safetyFlags: [SafetyFlag]
    let language: String
    
    init(content: String, category: TipCategory, contexts: [TipContext] = [], safetyFlags: [SafetyFlag] = [], language: String = "en") {
        self.content = content
        self.category = category
        self.contexts = contexts
        self.safetyFlags = safetyFlags
        self.language = language
    }
}

enum TipCategory: String, CaseIterable {
    case breathing
    case distraction
    case ifThen
    case environment
    case social
    case nrt
    case motivation
    case movement
}

enum TipContext: String, CaseIterable {
    case morning
    case postMeal
    case commute
    case highUrge
    case lowSteps
    case afterRelapse
    case onStreak
    case poorSleep
    case highRiskHour
    case recent
}

enum SafetyFlag: String, CaseIterable {
    case none
    case avoidPregnancy
    case consultDoctor
}

// MARK: - Tip Library

class TipLibrary {
    static let shared = TipLibrary()
    
    private var tips: [CoachTip] = []
    
    private init() {
        loadTips()
    }
    
    func getTips(for features: CoachFeatures, language: String = "en") -> [String] {
        var relevantTips: [CoachTip] = []
        
        // Filter by language first
        let languageTips = tips.filter { $0.language == language || $0.language == "en" }
        
        // Context-based filtering
        if features.minutesSinceLastCig < 30 {
            relevantTips.append(contentsOf: languageTips.filter { $0.contexts.contains(.recent) })
        }
        
        if features.currentStreak > 0 {
            relevantTips.append(contentsOf: languageTips.filter { $0.contexts.contains(.onStreak) })
        }
        
        if features.sleptShortLastNight {
            relevantTips.append(contentsOf: languageTips.filter { $0.contexts.contains(.poorSleep) })
        }
        
        if features.stepsLast3h < 1000 {
            relevantTips.append(contentsOf: languageTips.filter { $0.contexts.contains(.lowSteps) })
        }
        
        if features.timeOfDayRisk > 0.7 {
            relevantTips.append(contentsOf: languageTips.filter { $0.contexts.contains(.highRiskHour) })
        }
        
        if features.usedNRTLast12h {
            relevantTips.append(contentsOf: languageTips.filter { $0.category == .nrt })
        }
        
        // If no context matches, use general tips
        if relevantTips.isEmpty {
            relevantTips = languageTips.filter { 
                $0.category == .breathing || $0.category == .motivation 
            }
        }
        
        return relevantTips.map { $0.content }
    }
    
    private func loadTips() {
        // English Tips
        let englishTips: [CoachTip] = [
            // Breathing
            CoachTip(content: "Take 4 slow breaths: in for 4, hold for 4, out for 4, pause for 4.", category: .breathing, contexts: [.recent, .highUrge]),
            CoachTip(content: "Try the 4-7-8 technique: breathe in for 4, hold for 7, exhale for 8.", category: .breathing, contexts: [.poorSleep]),
            CoachTip(content: "One minute of deep belly breathing. Feel your stomach rise and fall.", category: .breathing, contexts: [.morning, .highUrge]),
            
            // Movement
            CoachTip(content: "Take 20 steps. Walk to another room or around the block.", category: .movement, contexts: [.lowSteps, .highRiskHour]),
            CoachTip(content: "Do 10 jumping jacks or stretch your arms above your head.", category: .movement, contexts: [.lowSteps]),
            CoachTip(content: "Stand up and do 5 shoulder rolls. Move your body instead.", category: .movement, contexts: [.commute]),
            
            // Distraction
            CoachTip(content: "Drink a full glass of water slowly. Stay hydrated, not smoked.", category: .distraction, contexts: [.postMeal, .recent]),
            CoachTip(content: "Count backwards from 100 by 7s. Keep your mind busy.", category: .distraction, contexts: [.highUrge]),
            CoachTip(content: "Text someone who supports your quit journey. Share your progress.", category: .social, contexts: [.afterRelapse, .onStreak]),
            
            // If-Then Planning
            CoachTip(content: "If you feel an urge after coffee, then take 3 deep breaths first.", category: .ifThen, contexts: [.morning]),
            CoachTip(content: "If stress hits, then step outside for 2 minutes of fresh air.", category: .ifThen, contexts: [.highUrge]),
            CoachTip(content: "If you reach for a cigarette, then drink water and count to 60.", category: .ifThen, contexts: [.recent]),
            
            // Environment
            CoachTip(content: "Change your location. Go somewhere smoking isn't allowed.", category: .environment, contexts: [.highRiskHour]),
            CoachTip(content: "Remove any smoking materials from sight. Out of sight, out of mind.", category: .environment),
            CoachTip(content: "Keep your hands busy. Hold a stress ball or fidget toy.", category: .environment, contexts: [.highUrge]),
            
            // NRT Support
            CoachTip(content: "Your patch is working. Give it time to reduce the craving.", category: .nrt),
            CoachTip(content: "Chew your gum slowly. Park it between cheek and gum.", category: .nrt),
            CoachTip(content: "Use your inhaler with slow, deep puffs as directed.", category: .nrt),
            
            // Motivation & Streak
            CoachTip(content: "You're on day \(0) smoke-free! Your body is healing right now.", category: .motivation, contexts: [.onStreak]),
            CoachTip(content: "Every minute without smoking is a victory. You're stronger than the urge.", category: .motivation, contexts: [.recent]),
            CoachTip(content: "Think about why you started this journey. You're worth it.", category: .motivation, contexts: [.afterRelapse]),
            CoachTip(content: "Your lungs are cleaning themselves right now. Keep going.", category: .motivation, contexts: [.onStreak])
        ]
        
        // Italian Tips
        let italianTips: [CoachTip] = [
            // Respirazione
            CoachTip(content: "Fai 4 respiri lenti: inspira per 4, tieni per 4, espira per 4, pausa per 4.", category: .breathing, contexts: [.recent, .highUrge], language: "it"),
            CoachTip(content: "Prova la tecnica 4-7-8: inspira per 4, tieni per 7, espira per 8.", category: .breathing, contexts: [.poorSleep], language: "it"),
            CoachTip(content: "Un minuto di respirazione profonda. Senti lo stomaco che si alza e abbassa.", category: .breathing, contexts: [.morning, .highUrge], language: "it"),
            
            // Movimento
            CoachTip(content: "Fai 20 passi. Vai in un'altra stanza o intorno al palazzo.", category: .movement, contexts: [.lowSteps, .highRiskHour], language: "it"),
            CoachTip(content: "Fai 10 salti o allunga le braccia sopra la testa.", category: .movement, contexts: [.lowSteps], language: "it"),
            CoachTip(content: "Alzati e fai 5 rotazioni delle spalle. Muovi il corpo invece.", category: .movement, contexts: [.commute], language: "it"),
            
            // Distrazione
            CoachTip(content: "Bevi un bicchiere d'acqua lentamente. Mantieniti idratato, non fumato.", category: .distraction, contexts: [.postMeal, .recent], language: "it"),
            CoachTip(content: "Conta all'indietro da 100 per 7. Tieni la mente occupata.", category: .distraction, contexts: [.highUrge], language: "it"),
            CoachTip(content: "Manda un messaggio a chi supporta il tuo percorso. Condividi i progressi.", category: .social, contexts: [.afterRelapse, .onStreak], language: "it"),
            
            // Pianificazione Se-Allora
            CoachTip(content: "Se senti l'urgenza dopo il caffè, allora fai prima 3 respiri profondi.", category: .ifThen, contexts: [.morning], language: "it"),
            CoachTip(content: "Se arriva lo stress, allora esci per 2 minuti di aria fresca.", category: .ifThen, contexts: [.highUrge], language: "it"),
            CoachTip(content: "Se cerchi una sigaretta, allora bevi acqua e conta fino a 60.", category: .ifThen, contexts: [.recent], language: "it"),
            
            // Ambiente
            CoachTip(content: "Cambia posto. Vai dove non è permesso fumare.", category: .environment, contexts: [.highRiskHour], language: "it"),
            CoachTip(content: "Rimuovi dalla vista tutto ciò che riguarda il fumo. Lontano dagli occhi, lontano dal cuore.", category: .environment, language: "it"),
            CoachTip(content: "Tieni le mani occupate. Usa una pallina antistress o un fidget.", category: .environment, contexts: [.highUrge], language: "it"),
            
            // Supporto NRT
            CoachTip(content: "Il tuo cerotto sta funzionando. Dagli tempo di ridurre il craving.", category: .nrt, language: "it"),
            CoachTip(content: "Mastica la gomma lentamente. Parcheggiala tra guancia e gengiva.", category: .nrt, language: "it"),
            CoachTip(content: "Usa l'inalatore con boccate lente e profonde come indicato.", category: .nrt, language: "it"),
            
            // Motivazione e Serie
            CoachTip(content: "Sei al giorno \(0) senza fumo! Il tuo corpo si sta curando proprio ora.", category: .motivation, contexts: [.onStreak], language: "it"),
            CoachTip(content: "Ogni minuto senza fumare è una vittoria. Sei più forte dell'impulso.", category: .motivation, contexts: [.recent], language: "it"),
            CoachTip(content: "Pensa al perché hai iniziato questo viaggio. Ne vali la pena.", category: .motivation, contexts: [.afterRelapse], language: "it"),
            CoachTip(content: "I tuoi polmoni si stanno pulendo proprio ora. Continua così.", category: .motivation, contexts: [.onStreak], language: "it")
        ]
        
        tips = englishTips + italianTips
    }
}

// MARK: - Safety Rules

class SafetyRules {
    static let shared = SafetyRules()
    
    private init() {}
    
    func filterSafeTips(_ tips: [CoachTip], userProfile: UserProfile?) -> [CoachTip] {
        // For now, we don't have pregnancy or medical condition flags in UserProfile
        // This could be extended in the future
        
        // Filter out tips that require doctor consultation if user has certain conditions
        return tips.filter { tip in
            // Basic safety filtering - could be expanded based on user profile
            !tip.safetyFlags.contains(.consultDoctor) || userProfile?.age ?? 0 < 65
        }
    }
}