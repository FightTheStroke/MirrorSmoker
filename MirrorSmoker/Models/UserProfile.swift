//
//  UserProfile.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import Foundation
import SwiftData

@Model
final class UserProfile: Identifiable {
    var id: UUID = UUID()
    var username: String
    var dailyGoal: Int // Target cigarettes per day
    var quitDate: Date?
    var notificationsEnabled: Bool
    var themePreference: String // "light", "dark", "system"
    var createdAt: Date
    var lastUpdated: Date
    
    init(username: String = "User", 
         dailyGoal: Int = 20, 
         notificationsEnabled: Bool = true, 
         themePreference: String = "system") {
        self.id = UUID()
        self.username = username
        self.dailyGoal = dailyGoal
        self.quitDate = nil
        self.notificationsEnabled = notificationsEnabled
        self.themePreference = themePreference
        self.createdAt = Date()
        self.lastUpdated = Date()
    }
}
