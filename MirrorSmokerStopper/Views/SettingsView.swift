//
//  SettingsView.swift
//  MirrorSmokerStopper
//
//  Created by Roberto D'Angelo on 01/09/25.
//

import SwiftUI
import SwiftData

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
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    // Profile Section
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.profile", comment: ""))
                            
                            VStack(spacing: DS.Space.md) {
                                DSListRow(
                                    icon: "person.fill",
                                    iconColor: DS.Colors.primary,
                                    title: NSLocalizedString("settings.name", comment: ""),
                                    accessory: AnyView(
                                        TextField("", text: $name)
                                            .focused($focusedField, equals: .name)
                                            .textInputAutocapitalization(.words)
                                            .submitLabel(.next)
                                            .multilineTextAlignment(.trailing)
                                            .autocorrectionDisabled()
                                    )
                                )
                                
                                Divider()
                                
                                DSListRow(
                                    icon: "calendar",
                                    iconColor: DS.Colors.accent,
                                    title: NSLocalizedString("settings.birth.date", comment: ""),
                                    value: profile?.birthDate != nil && currentAge > 0 ? String(format: NSLocalizedString("settings.age", comment: ""), currentAge) : nil,
                                    action: {
                                        showDatePicker = true
                                    }
                                )
                                
                                Divider()
                                
                                DSListRow(
                                    icon: "scalemass",
                                    iconColor: DS.Colors.health,
                                    title: NSLocalizedString("settings.weight", comment: ""),
                                    accessory: AnyView(
                                        HStack(spacing: DS.Space.xs) {
                                            TextField("", text: $weight)
                                                .focused($focusedField, equals: .weight)
                                                .keyboardType(.decimalPad)
                                                .submitLabel(.next)
                                                .multilineTextAlignment(.trailing)
                                                .autocorrectionDisabled()
                                                .frame(width: 60)
                                            
                                            if !weight.isEmpty {
                                                Text("kg")
                                                    .font(DS.Text.caption)
                                                    .foregroundStyle(DS.Colors.textSecondary)
                                            }
                                        }
                                    )
                                )
                                
                                if !isValidWeight && !weight.isEmpty {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(DS.Colors.danger)
                                        Text(NSLocalizedString("settings.weight.validation", comment: ""))
                                            .font(DS.Text.caption)
                                            .foregroundStyle(DS.Colors.danger)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Smoking Habits Section
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.smoking.habits", comment: ""))
                            
                            VStack(spacing: DS.Space.md) {
                                DSListRow(
                                    icon: smokingType.icon,
                                    iconColor: DS.Colors.warning,
                                    title: NSLocalizedString("settings.smoking.type", comment: ""),
                                    accessory: AnyView(
                                        Picker(NSLocalizedString("smoking.type.picker.label", comment: ""), selection: $smokingType) {
                                            ForEach(SmokingType.allCases, id: \.self) { type in
                                                Text(type.displayName).tag(type)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    )
                                )
                                
                                Divider()
                                
                                DSListRow(
                                    icon: "hourglass.tophalf.filled",
                                    iconColor: DS.Colors.cigarette,
                                    title: NSLocalizedString("settings.started.age", comment: ""),
                                    accessory: AnyView(
                                        HStack(spacing: DS.Space.xs) {
                                            TextField(NSLocalizedString("age.placeholder", comment: ""), value: $startedSmokingAge, formatter: NumberFormatter())
                                                .focused($focusedField, equals: .startedSmokingAge)
                                                .keyboardType(.numberPad)
                                                .frame(width: 60)
                                                .multilineTextAlignment(.trailing)
                                                .autocorrectionDisabled()
                                            
                                            Text(NSLocalizedString("years.unit", comment: ""))
                                                .font(DS.Text.caption)
                                                .foregroundStyle(DS.Colors.textSecondary)
                                        }
                                    )
                                )
                                
                                if !isValidAge {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(DS.Colors.danger)
                                        Text(NSLocalizedString("settings.started.age.validation", comment: ""))
                                            .font(DS.Text.caption)
                                            .foregroundStyle(DS.Colors.danger)
                                        Spacer()
                                    }
                                }
                                
                                // Summary when valid
                                if currentAge > 0 && isValidAge {
                                    Divider()
                                        .padding(.top, DS.Space.md)
                                    
                                    VStack(spacing: DS.Space.sm) {
                                        DSListRow(
                                            icon: "person.circle",
                                            iconColor: DS.Colors.primary,
                                            title: NSLocalizedString("settings.current.age", comment: ""),
                                            value: "\(currentAge) \(NSLocalizedString("years.unit", comment: ""))"
                                        )
                                        
                                        DSListRow(
                                            icon: "clock.fill",
                                            iconColor: DS.Colors.danger,
                                            title: NSLocalizedString("settings.smoking.years", comment: ""),
                                            value: "\(yearsSmokingCalculated) \(NSLocalizedString("years.unit", comment: ""))"
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Health Insights Section
                    if profile?.birthDate != nil && !weight.isEmpty && isValidWeight && currentAge > 0 {
                        DSCard {
                            VStack(spacing: DS.Space.lg) {
                                DSSectionHeader(
                                    NSLocalizedString("settings.health.insights", comment: ""),
                                    subtitle: NSLocalizedString("settings.health.insights.footer", comment: "")
                                )
                                
                                HealthInsightsView(
                                    age: currentAge,
                                    weight: Double(weight) ?? 0,
                                    smokingType: smokingType,
                                    yearsSmokingSince: yearsSmokingCalculated
                                )
                            }
                        }
                    }
                    
                    // Save Button
                    DSButton(
                        NSLocalizedString("settings.save.changes", comment: ""), 
                        icon: "checkmark.circle.fill",
                        style: canSave ? .primary : .secondary
                    ) {
                        focusedField = nil
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(!canSave)
                    
                    // App Information
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.info.title", comment: ""))
                            
                            VStack(spacing: DS.Space.sm) {
                                DSListRow(
                                    icon: "info.circle",
                                    iconColor: DS.Colors.info,
                                    title: NSLocalizedString("settings.version", comment: ""),
                                    value: appVersion
                                )
                                
                                Divider()
                                    .padding(.vertical, DS.Space.md)
                                
                                VStack(spacing: DS.Space.sm) {
                                    Text(NSLocalizedString("settings.copyright", comment: ""))
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Link(NSLocalizedString("settings.website", comment: ""), 
                                         destination: URL(string: "https://www.fightthestroke.org")!)
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.primary)
                                    
                                    Link(NSLocalizedString("settings.email", comment: ""), 
                                         destination: URL(string: "mailto:info@fightthestroke.org")!)
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.primary)
                                }
                            }
                        }
                    }
                    
                    // Debug Panel
                    #if DEBUG
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.debug", comment: ""))
                            
                            DSListRow(
                                icon: "wrench.and.screwdriver",
                                iconColor: DS.Colors.secondary,
                                title: NSLocalizedString("debug.toggle.panel", comment: ""),
                                action: {
                                    showDebugPanel.toggle()
                                }
                            )
                            
                            if showDebugPanel {
                                DebugPanelView()
                            }
                        }
                    }
                    #endif
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
        }
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
                .foregroundStyle(DS.Colors.primary)
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
            
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
            
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
        NavigationStack {
            VStack(spacing: DS.Space.xl) {
                DatePicker(
                    NSLocalizedString("settings.birth.date", comment: ""),
                    selection: $selectedDate,
                    in: Date(timeIntervalSince1970: -2208988800)...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding(DS.Space.lg)
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("settings.birth.date", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        isPresented = false
                    }
                    .foregroundStyle(DS.Colors.danger)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("confirm", comment: "")) {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.primary)
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
        VStack(spacing: DS.Space.md) {
            if weight > 0 {
                DSHealthCard(
                    title: NSLocalizedString("health.insights.general.info", comment: ""),
                    value: String(format: "%.0f kg", weight),
                    subtitle: String(format: NSLocalizedString("health.insights.age.weight.format", comment: ""), age, weight),
                    icon: "figure.stand",
                    color: DS.Colors.health,
                    trend: nil
                )
            }
            
            DSHealthCard(
                title: NSLocalizedString("health.insights.smoking.duration", comment: ""),
                value: "\(yearsSmokingSince)",
                subtitle: NSLocalizedString("years.unit", comment: ""),
                icon: "exclamationmark.triangle.fill",
                color: DS.Colors.warning,
                trend: .stable
            )
            
            DSHealthCard(
                title: NSLocalizedString("health.insights.reminder", comment: ""),
                value: smokingType.displayName,
                subtitle: NSLocalizedString("health.insights.quit.message", comment: ""),
                icon: "heart.fill",
                color: DS.Colors.danger,
                trend: nil
            )
        }
    }
}

struct DebugPanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("Widget Debug Tools")
                .font(DS.Text.caption)
                .foregroundStyle(DS.Colors.textSecondary)
            
            // Placeholder for debug tools
            Text("Debug tools will be implemented here")
                .font(DS.Text.caption2)
                .foregroundStyle(DS.Colors.textTertiary)
        }
        .padding(DS.Space.md)
        .background(DS.Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall))
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .modelContainer(for: UserProfile.self, inMemory: true)
    }
}