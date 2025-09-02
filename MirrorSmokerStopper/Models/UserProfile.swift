//
//  UserProfile.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

#if os(watchOS)
// Define DependencyLevel for watchOS since it doesn't have access to SmokingInsight.swift
enum DependencyLevel: String, CaseIterable, Codable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}
#endif

enum ReductionCurve: String, CaseIterable, Codable {
    case linear = "linear"
    case exponential = "exponential"
    case logarithmic = "logarithmic"
    case stepped = "stepped"
    case gentle = "gentle"
}

enum SmokingType: String, CaseIterable, Codable {
    case cigarettes = "cigarettes"
    case electronic = "electronic"
    case tobacco = "tobacco"
    
    var displayName: String {
        switch self {
        case .cigarettes:
            return NSLocalizedString("smoking.type.cigarettes", comment: "")
        case .electronic:
            return NSLocalizedString("smoking.type.electronic", comment: "")
        case .tobacco:
            return NSLocalizedString("smoking.type.tobacco", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .cigarettes:
            return "lungs.fill"
        case .electronic:
            return "battery.100"
        case .tobacco:
            return "leaf.fill"
        }
    }
}

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var birthDate: Date?
    var weight: Double = 0.0 // in kg
    var smokingTypeRaw: String = SmokingType.cigarettes.rawValue
    var startedSmokingAge: Int = 18
    var notificationsEnabled: Bool = true
    var themePreference: String = "system"
    var lastUpdated: Date = Date()
    
    var quitDate: Date? // Data target per smettere completamente
    var enableGradualReduction: Bool = true // Se abilitare la riduzione graduale
    
    // New properties for migration compatibility (using raw values for enums)
    var reductionCurveRaw: String = ReductionCurve.linear.rawValue
    var startingSmokerTypeRaw: String = SmokingType.cigarettes.rawValue
    var healthInsights: String = ""
    var motivationalMessages: String = ""
    var createdAt: Date = Date()
    var dailyAverage: Double = 0.0 // NEW: Media giornaliera personalizzata
    
    // Computed properties for enum access
    var reductionCurve: ReductionCurve {
        get {
            return ReductionCurve(rawValue: reductionCurveRaw) ?? .linear
        }
        set {
            reductionCurveRaw = newValue.rawValue
        }
    }
    
    var startingSmokerType: SmokingType {
        get {
            return SmokingType(rawValue: startingSmokerTypeRaw) ?? .cigarettes
        }
        set {
            startingSmokerTypeRaw = newValue.rawValue
        }
    }
    
    // Computed property for smokingType that handles nil/invalid values gracefully
    var smokingType: SmokingType {
        get {
            return SmokingType(rawValue: smokingTypeRaw) ?? .cigarettes
        }
        set {
            smokingTypeRaw = newValue.rawValue
        }
    }
    
    // Computed property for age
    var age: Int {
        guard let birthDate = birthDate else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    // Computed property for years smoking
    var yearsSmokingSince: Int {
        max(0, age - startedSmokingAge)
    }
    
    func calculateDailyAverage(from cigarettes: [Any]) -> Double {
        // Questo sarà chiamato dal contesto che ha accesso ai dati
        // Per ora ritorna un valore di default, verrà sovrascritto
        return 15.0
    }
    
    func todayTarget(dailyAverage: Double) -> Int {
        guard enableGradualReduction, let quitDate = quitDate else {
            return Int(dailyAverage) // Se non c'è piano, usa la media attuale
        }
        
        return improvedTodayTarget(dailyAverage: dailyAverage, quitDate: quitDate)
    }
    
    // MARK: - Enhanced Quit Plan Algorithm
    private func improvedTodayTarget(dailyAverage: Double, quitDate: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Se abbiamo già superato la data target, il target è 0
        if today >= quitDate {
            return 0
        }
        
        let daysRemaining = calendar.dateComponents([.day], from: today, to: quitDate).day ?? 1
        let totalDays = calendar.dateComponents([.day], from: Date(), to: quitDate).day ?? 1
        
        if totalDays <= 0 || daysRemaining <= 0 {
            return 0
        }
        
        // Calcola il livello di dipendenza basato sulla media giornaliera
        let dependencyLevel = calculateDependencyLevel(dailyAverage: dailyAverage)
        
        // Scegli la curva di riduzione basata sulla dipendenza
        let reductionCurve = selectReductionCurve(dependencyLevel: dependencyLevel, totalDays: totalDays)
        
        // Calcola il target personalizzato
        let targetToday = calculatePersonalizedTarget(
            dailyAverage: dailyAverage,
            daysRemaining: daysRemaining,
            totalDays: totalDays,
            curve: reductionCurve
        )
        
        return max(0, Int(ceil(targetToday)))
    }
    
    private func calculateDependencyLevel(dailyAverage: Double) -> DependencyLevel {
        switch dailyAverage {
        case 0..<5:
            return .low
        case 5..<10:
            return .moderate
        case 10..<20:
            return .high
        default:
            return .severe
        }
    }
    
    private func selectReductionCurve(dependencyLevel: DependencyLevel, totalDays: Int) -> ReductionCurve {
        switch dependencyLevel {
        case .low:
            return totalDays >= 14 ? .linear : .gentle
        case .moderate:
            return totalDays >= 21 ? .exponential : .linear
        case .high:
            return totalDays >= 30 ? .logarithmic : .exponential
        case .severe:
            return totalDays >= 45 ? .stepped : .logarithmic
        }
    }
    
    private func calculatePersonalizedTarget(
        dailyAverage: Double,
        daysRemaining: Int,
        totalDays: Int,
        curve: ReductionCurve
    ) -> Double {
        let progress = Double(totalDays - daysRemaining) / Double(totalDays)
        
        switch curve {
        case .linear:
            // Riduzione lineare standard
            return dailyAverage * (1.0 - progress)
            
        case .exponential:
            // Riduzione più rapida all'inizio, poi rallenta
            let exponentialProgress = pow(progress, 0.7)
            return dailyAverage * (1.0 - exponentialProgress)
            
        case .logarithmic:
            // Riduzione lenta all'inizio, poi accelera
            let logProgress = progress == 0 ? 0 : log(1 + progress * 9) / log(10)
            return dailyAverage * (1.0 - logProgress)
            
        case .stepped:
            // Riduzione a gradini per alta dipendenza
            let stepSize = totalDays / 5 // 5 steps
            let currentStep = min(4, (totalDays - daysRemaining) / stepSize)
            let reduction = Double(currentStep) / 4.0 * 0.8 // Max 80% reduction in steps
            return dailyAverage * (1.0 - reduction)
            
        case .gentle:
            // Riduzione molto graduale per bassa dipendenza
            let gentleProgress = pow(progress, 1.3)
            return dailyAverage * (1.0 - gentleProgress)
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        birthDate: Date? = nil,
        weight: Double = 0.0,
        smokingType: SmokingType = .cigarettes,
        startedSmokingAge: Int = 18,
        notificationsEnabled: Bool = true,
        themePreference: String = "system",
        quitDate: Date? = nil,
        enableGradualReduction: Bool = true,
        reductionCurve: ReductionCurve = .linear,
        startingSmokerType: SmokingType = .cigarettes,
        healthInsights: String = "",
        motivationalMessages: String = "",
        createdAt: Date = Date(),
        dailyAverage: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.weight = weight
        self.smokingTypeRaw = smokingType.rawValue
        self.startedSmokingAge = startedSmokingAge
        self.notificationsEnabled = notificationsEnabled
        self.themePreference = themePreference
        self.quitDate = quitDate
        self.enableGradualReduction = enableGradualReduction
        self.reductionCurveRaw = reductionCurve.rawValue
        self.startingSmokerTypeRaw = startingSmokerType.rawValue
        self.healthInsights = healthInsights
        self.motivationalMessages = motivationalMessages
        self.createdAt = createdAt
        self.dailyAverage = dailyAverage
        self.lastUpdated = Date()
    }
}