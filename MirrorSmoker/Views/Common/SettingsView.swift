//
//  SettingsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfile: [UserProfile]
    
    @State private var username: String = ""
    @State private var dailyGoal: Int = 20
    @State private var notificationsEnabled: Bool = true
    @State private var themePreference: String = "system"
    
    var body: some View {
        Form {
            Section("User Profile") {
                TextField("Username", text: $username)
                
                Stepper("Daily Goal: \(dailyGoal) cigarettes", value: $dailyGoal, in: 1...100)
                
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                Picker("Theme", selection: $themePreference) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
            }
            
            Section("Data Management") {
                Button("Export Data") {
                    // TODO: Implement data export
                }
                
                Button("Import Data") {
                    // TODO: Implement data import
                }
                
                Button("Reset All Data") {
                    // TODO: Implement data reset with confirmation
                }
                .foregroundColor(.red)
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            loadUserProfile()
        }
        .onChange(of: username) { saveUserProfile() }
        .onChange(of: dailyGoal) { saveUserProfile() }
        .onChange(of: notificationsEnabled) { saveUserProfile() }
        .onChange(of: themePreference) { saveUserProfile() }
    }
    
    private func loadUserProfile() {
        if let profile = userProfile.first {
            username = profile.username
            dailyGoal = profile.dailyGoal
            notificationsEnabled = profile.notificationsEnabled
            themePreference = profile.themePreference
        }
    }
    
    private func saveUserProfile() {
        if let profile = userProfile.first {
            profile.username = username
            profile.dailyGoal = dailyGoal
            profile.notificationsEnabled = notificationsEnabled
            profile.themePreference = themePreference
            profile.lastUpdated = Date()
        } else {
            let newProfile = UserProfile(
                username: username,
                dailyGoal: dailyGoal,
                notificationsEnabled: notificationsEnabled,
                themePreference: themePreference
            )
            modelContext.insert(newProfile)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
