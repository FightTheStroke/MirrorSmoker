//
//  UserProfile.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var email: String = ""
    var username: String = ""
    var dailyGoal: Int = 20
    var weeklyGoal: Int = 140
    var monthlyGoal: Int = 600
    var notificationsEnabled: Bool = true
    var themePreference: String = "light"
    var lastUpdated: Date = Date()
    
    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        username: String = "",
        dailyGoal: Int = 20,
        weeklyGoal: Int = 140,
        monthlyGoal: Int = 600,
        notificationsEnabled: Bool = true,
        themePreference: String = "light",
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username
        self.dailyGoal = dailyGoal
        self.weeklyGoal = weeklyGoal
        self.monthlyGoal = monthlyGoal
        self.notificationsEnabled = notificationsEnabled
        self.themePreference = themePreference
        self.lastUpdated = lastUpdated
    }
}