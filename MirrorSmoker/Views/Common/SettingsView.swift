//
//  SettingsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var username = ""
    @State private var dailyGoal = 20
    @State private var weeklyGoal = 140
    @State private var monthlyGoal = 600
    @State private var notificationsEnabled = true
    @State private var themePreference = "light"
    
    private var profile: UserProfile {
        profiles.first ?? UserProfile()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                TextField("Username", text: $username)
                TextField("Daily Goal", value: $dailyGoal, formatter: NumberFormatter())
                TextField("Weekly Goal", value: $weeklyGoal, formatter: NumberFormatter())
                TextField("Monthly Goal", value: $monthlyGoal, formatter: NumberFormatter())
            }
            
            Section(header: Text("Preferences")) {
                Toggle("Notifications", isOn: $notificationsEnabled)
                
                Picker("Theme", selection: $themePreference) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadProfileData()
        }
    }
    
    private func loadProfileData() {
        username = profile.username
        dailyGoal = profile.dailyGoal
        weeklyGoal = profile.weeklyGoal
        monthlyGoal = profile.monthlyGoal
        notificationsEnabled = profile.notificationsEnabled
        themePreference = profile.themePreference
    }
    
    private func saveChanges() {
        let profileToSave: UserProfile
        
        if let existingProfile = profiles.first {
            profileToSave = existingProfile
        } else {
            profileToSave = UserProfile()
            modelContext.insert(profileToSave)
        }
        
        profileToSave.username = username
        profileToSave.dailyGoal = dailyGoal
        profileToSave.weeklyGoal = weeklyGoal
        profileToSave.monthlyGoal = monthlyGoal
        profileToSave.notificationsEnabled = notificationsEnabled
        profileToSave.themePreference = themePreference
        profileToSave.lastUpdated = Date()
        
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}