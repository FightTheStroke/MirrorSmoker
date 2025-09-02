//
//  UserProfile.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

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
        
        let calendar = Calendar.current
        let today = Date()
        
        // Se abbiamo già superato la data target, il target è 0
        if today >= quitDate {
            return 0
        }
        
        // Calcola i giorni totali del piano e quelli rimanenti
        let startDate = Date() // Il piano inizia da oggi
        let totalDays = calendar.dateComponents([.day], from: startDate, to: quitDate).day ?? 1
        let daysRemaining = calendar.dateComponents([.day], from: today, to: quitDate).day ?? 1
        
        if totalDays <= 0 || daysRemaining <= 0 {
            return 0
        }
        
        // Decrescita lineare: da dailyAverage a 0 in totalDays giorni
        let dailyReduction = dailyAverage / Double(totalDays)
        let targetToday = dailyAverage - (dailyReduction * Double(totalDays - daysRemaining))
        
        return max(0, Int(ceil(targetToday)))
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
        enableGradualReduction: Bool = true
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
        self.lastUpdated = Date()
    }
}