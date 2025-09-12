# FASE 1 - CRITICAL FIXES CHECKLIST

## Task 1.1: iOS 26 Dependencies Removal (4-6h)

### Files da modificare:

#### 1. MirrorSmokerStopper/AI/CoachLLM.swift
- [ ] Rimuovere `@available(iOS 26, *)`
- [ ] Sostituire con implementazione rule-based
- [ ] Mantenere stessa interfaccia pubblica
- [ ] Test: Verificare che compili su iOS 17

```swift
// PRIMA (FAKE):
@available(iOS 26, *)
class CoachLLM {
    // Fake Foundation Models implementation
}

// DOPO (REAL):
class CoachLLM {
    // Rule-based implementation che funziona davvero
    private let templates: [String: [String]] = [
        "craving": [
            "Take 5 deep breaths. This craving will pass in 3-5 minutes.",
            "Remember why you decided to quit. You're stronger than this urge.",
            "Drink a glass of water and do 10 jumping jacks."
        ],
        "stress": [
            "Try the 4-7-8 breathing technique: inhale 4, hold 7, exhale 8.",
            "Take a 2-minute walk, even if it's just around the room.",
            "Listen to your favorite calming music for a few minutes."
        ]
    ]
}
```

#### 2. MirrorSmokerStopper/AI/AICoachManager.swift
- [ ] Rimuovere `@available(iOS 26, *)`
- [ ] Implementare fallback per tutte le funzioni
- [ ] Sostituire chiamate fake con logica reale
- [ ] Test: Verificare funzionalità su dispositivo iOS 17

#### 3. MirrorSmokerStopper/Views/AICoachTestView.swift
- [ ] Rimuovere `@available(iOS 26, *)`
- [ ] Sostituire con test view funzionante
- [ ] Rimuovere riferimenti a Foundation Models
- [ ] Test: View si apre senza errori

#### 4. MirrorSmokerStopper/AI/QuitPlanOptimizer.swift
```swift
// Rimuovere:
// This would use Apple Intelligence Foundation Models
// Would be enhanced with Apple Intelligence

// Sostituire con:
private func generateOptimizedRecommendation(
    profile: UserProfile,
    behavioralData: BehavioralAnalysisResult
) -> QuitPlanRecommendation {
    // Algoritmo matematico reale basato su:
    // - Dependency level
    // - Historical success rates
    // - Behavioral patterns
    // - Medical recommendations
}
```

### Validation Checklist:
- [ ] App compila senza warning iOS 26
- [ ] Nessun crash su iPhone fisico iOS 17/18
- [ ] AI Coach mostra contenuti reali
- [ ] Test su simulatore iOS 17.0

---

## Task 1.2: Marketing Metadata Cleanup (2-3h)

### Files da correggere:

#### 1. fastlane/metadata/en-US/description.txt
```diff
- • World-class AI Coach leveraging Apple Intelligence
+ • Intelligent AI Coach with personalized recommendations
- • 100% LOCAL PROCESSING with Apple Intelligence  
+ • 100% LOCAL PROCESSING with advanced algorithms
- • AI-optimized quit plans powered by Apple Intelligence
+ • AI-optimized quit plans powered by behavioral analysis
```

#### 2. fastlane/metadata/*/promotional_text.txt (tutte le lingue)
```diff
- Revolutionary AI Coach + Apple Intelligence integration
+ Revolutionary AI Coach with advanced behavioral analysis
```

#### 3. fastlane/metadata/*/keywords.txt
```diff
- Apple Intelligence,quit smoking,iOS,AI coach
+ AI coach,quit smoking,iOS,behavioral analysis,health
```

### Validation:
- [ ] Nessun riferimento a "Apple Intelligence"
- [ ] Nessun riferimento a "Foundation Models" 
- [ ] Claims sono veritieri e implementati
- [ ] Test: Preview in fastlane looks correct

---

## Task 1.3: Core ML References Cleanup (1-2h)

#### MirrorSmokerStopper/AI/CoachEngine.swift
```swift
// PRIMA:
// Core ML model for risk classification (placeholder until actual model is trained)
private var model: MLModel?

// DOPO:
// Statistical risk classification based on behavioral patterns
private let riskAnalyzer = StatisticalRiskAnalyzer()
```

### Validation:
- [ ] Nessun riferimento a modelli ML inesistenti
- [ ] Risk classification funziona con algoritmi statistici
- [ ] Performance accettabile (<100ms per prediction)