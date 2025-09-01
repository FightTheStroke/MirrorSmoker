//
//  SettingsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var showDatePicker = false
    @State private var weight = ""
    @State private var smokingType = SmokingType.cigarettes
    @State private var startedSmokingAge = 18
    @State private var showingSaveConfirmation = false
    @State private var hasLoadedProfile = false
    @State private var showDebugPanel = false
    
    // Cache the profile to avoid repeated lookups
    @State private var cachedProfile: UserProfile?
    
    // Focus states for better UX
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, weight, startedSmokingAge
    }
    
    private var profile: UserProfile? {
        if let cached = cachedProfile {
            return cached
        }
        
        guard !profiles.isEmpty else { return nil }
        let firstProfile = profiles.first
        
        DispatchQueue.main.async {
            cachedProfile = firstProfile
        }
        
        return firstProfile
    }
    
    private var isValidWeight: Bool {
        if let weightValue = Double(weight), weightValue > 0 && weightValue < 300 {
            return true
        }
        return weight.isEmpty
    }
    
    private var isValidAge: Bool {
        startedSmokingAge >= 10 && startedSmokingAge <= 80
    }
    
    private var currentAge: Int {
        profile?.age ?? 0
    }
    
    private var yearsSmokingCalculated: Int {
        max(0, currentAge - startedSmokingAge)
    }
    
    var body: some View {
        Form {
            // Profile Section
            Section {
                // Name Field
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    TextField(NSLocalizedString("settings.name", comment: ""), text: $name)
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .autocorrectionDisabled()
                }
                
                // Birth Date Field
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("settings.birth.date", comment: ""))
                                .foregroundColor(.primary)
                            
                            Text(birthDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if profile?.birthDate != nil && currentAge > 0 {
                            Text(String(format: NSLocalizedString("settings.age", comment: ""), currentAge))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                
                // Weight Field
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField(NSLocalizedString("settings.weight", comment: ""), text: $weight)
                            .focused($focusedField, equals: .weight)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                            .autocorrectionDisabled()
                        
                        if !weight.isEmpty {
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !isValidWeight && !weight.isEmpty {
                        Text(NSLocalizedString("settings.weight.validation", comment: ""))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
            } header: {
                Text(NSLocalizedString("settings.profile", comment: ""))
            } footer: {
                Text(NSLocalizedString("settings.profile.footer", comment: ""))
            }
            
            // Smoking Habits Section
            Section {
                // Smoking Type Picker
                HStack {
                    Image(systemName: smokingType.icon)
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text(NSLocalizedString("settings.smoking.type", comment: ""))
                    
                    Spacer()
                    
                    Picker(NSLocalizedString("smoking.type.picker.label", comment: ""), selection: $smokingType) {
                        ForEach(SmokingType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Started Smoking Age
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "hourglass.tophalf.filled")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text(NSLocalizedString("settings.started.age", comment: ""))
                        
                        Spacer()
                        
                        TextField(NSLocalizedString("age.placeholder", comment: ""), value: $startedSmokingAge, formatter: NumberFormatter())
                            .focused($focusedField, equals: .startedSmokingAge)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                        
                        Text(NSLocalizedString("years.unit", comment: ""))
                            .foregroundColor(.secondary)
                    }
                    
                    if !isValidAge {
                        Text(NSLocalizedString("settings.started.age.validation", comment: ""))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Age and Years smoking summary
                if currentAge > 0 && isValidAge {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text(NSLocalizedString("settings.current.age", comment: ""))
                            
                            Spacer()
                            
                            Text("\(currentAge) \(NSLocalizedString("years.unit", comment: ""))")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text(NSLocalizedString("settings.smoking.years", comment: ""))
                            
                            Spacer()
                            
                            Text("\(yearsSmokingCalculated) \(NSLocalizedString("years.unit", comment: ""))")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 4)
                }
                
            } header: {
                Text(NSLocalizedString("settings.smoking.habits", comment: ""))
            } footer: {
                Text(NSLocalizedString("settings.smoking.habits.footer", comment: ""))
            }
            
            // Health Insights Section
            if profile?.birthDate != nil && !weight.isEmpty && isValidWeight && currentAge > 0 {
                Section {
                    HealthInsightsView(
                        age: currentAge,
                        weight: Double(weight) ?? 0,
                        smokingType: smokingType,
                        yearsSmokingSince: yearsSmokingCalculated
                    )
                } header: {
                    Text(NSLocalizedString("settings.health.insights", comment: ""))
                } footer: {
                    Text(NSLocalizedString("settings.health.insights.footer", comment: ""))
                }
            }
            
            // Actions Section
            Section {
                Button(action: {
                    focusedField = nil
                    Task {
                        await saveProfile()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(NSLocalizedString("settings.save.changes", comment: ""))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(!canSave)
                .listRowBackground(Color.clear)
            }
            
            // App Info Section
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text(NSLocalizedString("settings.version", comment: ""))
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("settings.copyright", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Link(NSLocalizedString("settings.website", comment: ""), 
                             destination: URL(string: "https://www.fightthestroke.org")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Link(NSLocalizedString("settings.email", comment: ""), 
                             destination: URL(string: "mailto:info@fightthestroke.org")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.info.title", comment: ""))
            }
            
            // Debug Panel
            #if DEBUG
//            Section {
//                Button(NSLocalizedString("debug.toggle.panel", comment: "")) {
//                    showDebugPanel.toggle()
//                }
//                .foregroundColor(.secondary)
//                
//                if showDebugPanel {
//                    DebugPanelView()
//                }
//            } header: {
//                Text(NSLocalizedString("settings.debug", comment: ""))
//            }
            #endif
        }
        .navigationTitle(NSLocalizedString("settings.title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if !hasLoadedProfile {
                loadProfileData()
                hasLoadedProfile = true
            }
        }
        .onChange(of: profiles) { _, _ in
            cachedProfile = profiles.first
            if !hasLoadedProfile {
                loadProfileData()
                hasLoadedProfile = true
            }
        }
        .onSubmit {
            switch focusedField {
            case .name:
                focusedField = .weight
            case .weight:
                focusedField = .startedSmokingAge
            case .startedSmokingAge:
                focusedField = nil
            case .none:
                break
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(NSLocalizedString("done", comment: "")) {
                    focusedField = nil
                }
                .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $birthDate, isPresented: $showDatePicker)
        }
        .alert(NSLocalizedString("settings.profile.saved", comment: ""), isPresented: $showingSaveConfirmation) {
            Button(NSLocalizedString("ok", comment: "")) { }
        } message: {
            Text(NSLocalizedString("settings.profile.saved.message", comment: ""))
        }
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidWeight &&
        isValidAge
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func loadProfileData() {
        guard let profile = profile else { return }
        
        name = profile.name
        if let birthDate = profile.birthDate {
            self.birthDate = birthDate
        }
        weight = profile.weight > 0 ? String(format: "%.1f", profile.weight) : ""
        smokingType = profile.smokingType
        startedSmokingAge = profile.startedSmokingAge
    }
    
    @MainActor
    private func saveProfile() async {
        let profileToSave: UserProfile
        
        if let existingProfile = profile {
            profileToSave = existingProfile
        } else {
            profileToSave = UserProfile()
            modelContext.insert(profileToSave)
        }
        
        profileToSave.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileToSave.birthDate = birthDate
        profileToSave.weight = Double(weight) ?? 0.0
        profileToSave.smokingType = smokingType
        profileToSave.startedSmokingAge = startedSmokingAge
        profileToSave.notificationsEnabled = true
        profileToSave.themePreference = "system"
        profileToSave.lastUpdated = Date()
        
        do {
            try modelContext.save()
            cachedProfile = profileToSave
            showingSaveConfirmation = true
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
        } catch {
            print("Error saving profile: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    NSLocalizedString("settings.birth.date", comment: ""),
                    selection: $selectedDate,
                    in: Date(timeIntervalSince1970: -2208988800)...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .padding()
            .navigationTitle(NSLocalizedString("settings.birth.date", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("confirm", comment: "")) {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct HealthInsightsView: View {
    let age: Int
    let weight: Double
    let smokingType: SmokingType
    let yearsSmokingSince: Int
    
    var body: some View {
        VStack(spacing: 12) {
            if weight > 0 {
                HStack {
                    Image(systemName: "figure.stand")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(NSLocalizedString("health.insights.general.info", comment: ""))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(String(format: NSLocalizedString("health.insights.age.weight.format", comment: ""), age, weight))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("health.insights.smoking.duration", comment: ""))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(String(format: NSLocalizedString("health.insights.smoking.duration.format", comment: ""), yearsSmokingSince, smokingType.displayName.lowercased()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("health.insights.reminder", comment: ""))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(NSLocalizedString("health.insights.quit.message", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct DebugPanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Button(NSLocalizedString("debug.widget.state", comment: "")) {
////                let data = WidgetStore.readSnapshot()
////                let pending = WidgetStore.shared.getPendingCount()
////                let usingAppGroup = WidgetStore.shared.userDefaults != nil
//                print("🔧 Widget Debug:")
//                print("  Using App Group: \(usingAppGroup)")
//                print("  Count: \(data.todayCount)")
//                print("  Last Time: \(data.lastCigaretteTime)")
//                print("  Pending: \(pending)")
//            }
//            .font(.caption)
//            .foregroundColor(.blue)
//            
//            Button(NSLocalizedString("debug.force.sync", comment: "")) {
//                DispatchQueue.main.async {
//                    WidgetCenter.shared.reloadAllTimelines()
//                }
//            }
//            .font(.caption)
//            .foregroundColor(.green)
            
//            Button(NSLocalizedString("debug.reset.data", comment: "")) {
//                WidgetStore.shared.resetWidgetData()
//            }
//            .font(.caption)
//            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .modelContainer(for: UserProfile.self, inMemory: true)
    }
}
