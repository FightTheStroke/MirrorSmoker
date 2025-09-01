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
            return "Sigarette"
        case .electronic:
            return "Sigarette Elettroniche"
        case .tobacco:
            return "Tabacco"
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
    var smokingType: SmokingType = SmokingType.cigarettes
    var startedSmokingAge: Int = 18
    var notificationsEnabled: Bool = true
    var themePreference: String = "system"
    var lastUpdated: Date = Date()
    
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
    
    init(
        id: UUID = UUID(),
        name: String = "",
        birthDate: Date? = nil,
        weight: Double = 0.0,
        smokingType: SmokingType = .cigarettes,
        startedSmokingAge: Int = 18,
        notificationsEnabled: Bool = true,
        themePreference: String = "system"
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.weight = weight
        self.smokingType = smokingType
        self.startedSmokingAge = startedSmokingAge
        self.notificationsEnabled = notificationsEnabled
        self.themePreference = themePreference
        self.lastUpdated = Date()
    }
}