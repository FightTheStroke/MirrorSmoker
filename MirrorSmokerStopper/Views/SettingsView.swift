//
//  SettingsViewFixed.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI
import SwiftData
import os.log

struct SettingsViewFixed: View {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "SettingsView")
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    
    // Profile state
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var weight = ""
    @State private var smokingType = SmokingType.cigarettes
    @State private var startedSmokingAge = 18
    @State private var dailyAverageInput = ""
    
    // Quit plan state
    @State private var quitDate: Date?
    @State private var enableGradualReduction = true
    
    // UI state
    @State private var hasUnsavedChanges = false
    @State private var isLoading = false
    @State private var showingSaveAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingHelpView = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var calculatedDailyAverage: Double {
        guard !allCigarettes.isEmpty else { return 0.0 }
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = allCigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        
        let daysWithData = Set(recentCigarettes.map { 
            Calendar.current.startOfDay(for: $0.timestamp) 
        }).count
        
        let totalDays = max(daysWithData, 1)
        return Double(recentCigarettes.count) / Double(totalDays)
    }
    
    private var dailyAverageForPlan: Double {
        if let input = Double(dailyAverageInput), input > 0 {
            return input
        }
        return calculatedDailyAverage
    }
    
    private var todayTarget: Int {
        guard let profile = profile else { return Int(dailyAverageForPlan) }
        return profile.todayTarget(dailyAverage: dailyAverageForPlan)
    }
    
    // Validation computed properties
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isWeightValid: Bool {
        if weight.isEmpty { return true }
        guard let weightValue = Double(weight) else { return false }
        return weightValue > 0 && weightValue <= 300
    }
    
    private var isAgeValid: Bool {
        startedSmokingAge >= 10 && startedSmokingAge <= 80
    }
    
    private var isDailyAverageValid: Bool {
        if dailyAverageInput.isEmpty { return true }
        guard let avg = Double(dailyAverageInput) else { return false }
        return avg >= 0 && avg <= 100
    }
    
    private var canSave: Bool {
        isNameValid && isWeightValid && isAgeValid && isDailyAverageValid && !isLoading
    }
    
    private var currentAge: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    private var yearsSmokingCalculated: Int {
        max(0, currentAge - startedSmokingAge)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: DS.Space.md) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("loading".local())
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: DS.Space.lg) {
                            personalProfileSection
                            myWhySection
                            smokingHabitsSection
                            visualQuitPlanSection
                            if shouldShowHealthInfo {
                                healthInsightsSection
                            }
                            appInfoSection
                            dataManagementSection
                        }
                        .padding(DS.Space.lg)
                    }
                    .refreshable {
                        await loadProfileData()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings.title".local())
                        .font(DS.Text.title)
                        .foregroundColor(DS.Colors.textPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingHelpView = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                    }
                }
                
                if hasUnsavedChanges {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("cancel".local()) {
                            resetForm()
                        }
                        .disabled(isLoading)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task {
                                await saveProfile()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(canSave ? DS.Colors.success : DS.Colors.textSecondary)
                                    Text("save".local())
                                }
                            }
                        }
                        .disabled(!canSave || isLoading)
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingHelpView) {
                HelpView()
            }
            .alert("settings.profile.saved".local(), isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("settings.profile.saved.message".local())
            }
            .alert("settings.are.you.sure".local(), isPresented: $showingDeleteAlert) {
                Button("settings.delete.all.data".local(), role: .destructive) {
                    Self.logger.info("Delete confirmation - executing delete all data")
                    Task {
                        await deleteAllData()
                    }
                }
                Button("cancel".local(), role: .cancel) {
                    Self.logger.info("Delete confirmation - cancelled")
                }
            } message: {
                Text("settings.delete.warning".local())
            }
            .alert("error".local(), isPresented: $showingError) {
                Button("OK") { }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            Task {
                await loadProfileData()
            }
        }
    }
    
    // MARK: - View Sections
    
    private var personalProfileSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(
                    "settings.personal.profile".local(),
                    subtitle: "settings.profile.footer".local()
                )
                
                VStack(spacing: DS.Space.md) {
                    // Name field
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.name.label".local(),
                            icon: "person.fill",
                            isRequired: true
                        )
                        
                        TextField(
                            "settings.name.placeholder".local(),
                            text: $name
                        )
                        .textFieldStyle(DSTextFieldStyle())
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .onChange(of: name) { _, _ in
                            hasUnsavedChanges = true
                        }
                        
                        if !isNameValid && hasUnsavedChanges {
                            DSErrorText("settings.name.placeholder.hint".local())
                        }
                    }
                    
                    // Birth date field
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.birth.date.label".local(),
                            icon: "calendar",
                            isRequired: false
                        )
                        
                        DatePicker(
                            "settings.birth.date.label".local(),
                            selection: $birthDate,
                            in: Date.distantPast...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .onChange(of: birthDate) { _, _ in
                            hasUnsavedChanges = true
                        }
                        
                        if currentAge > 0 {
                            DSInfoText(String(format: "settings.age.years.format".local(), currentAge))
                        }
                    }
                    
                    // Weight field
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.weight.label".local(),
                            icon: "scalemass",
                            isRequired: false
                        )
                        
                        TextField(
                            "settings.weight.placeholder".local(),
                            text: $weight
                        )
                        .textFieldStyle(DSTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: weight) { _, _ in
                            hasUnsavedChanges = true
                        }
                        
                        if !isWeightValid && !weight.isEmpty {
                            DSErrorText("settings.weight.invalid.message".local())
                        }
                    }
                }
            }
        }
    }
    
    private var smokingHabitsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(
                    "settings.smoking.habits.section".local(),
                    subtitle: "settings.smoking.habits.footer".local()
                )
                
                VStack(spacing: DS.Space.md) {
                    // Smoking type
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.smoking.type.label".local(),
                            icon: smokingType.icon,
                            isRequired: true
                        )
                        
                        Picker(
                            "settings.smoking.type.label".local(),
                            selection: $smokingType
                        ) {
                            ForEach(SmokingType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: smokingType) { _, _ in
                            hasUnsavedChanges = true
                        }
                    }
                    
                    // Started smoking age
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.started.smoking.age".local(),
                            icon: "hourglass.tophalf.filled",
                            isRequired: true
                        )
                        
                        HStack {
                            Stepper(
                                value: $startedSmokingAge,
                                in: 10...80
                            ) {
                                Text("\(startedSmokingAge) " + "settings.age.years".local())
                                    .font(DS.Text.body)
                                    .foregroundColor(DS.Colors.textPrimary)
                            }
                            .onChange(of: startedSmokingAge) { _, _ in
                                hasUnsavedChanges = true
                            }
                        }
                        
                        if !isAgeValid {
                            DSErrorText("settings.age.invalid.message".local())
                        }
                        
                        if yearsSmokingCalculated > 0 {
                            DSInfoText(String(format: "settings.smoking.years.info".local(), yearsSmokingCalculated))
                        }
                    }
                    
                    // Daily average
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.daily.cigarettes.label".local(),
                            icon: "chart.bar.fill",
                            isRequired: false
                        )
                        
                        TextField(
                            "settings.daily.cigarettes.example".local(),
                            text: $dailyAverageInput
                        )
                        .textFieldStyle(DSTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: dailyAverageInput) { _, _ in
                            hasUnsavedChanges = true
                        }
                        
                        if !isDailyAverageValid && !dailyAverageInput.isEmpty {
                            DSErrorText("settings.daily.cigarettes.invalid".local())
                        }
                        
                        if calculatedDailyAverage > 0 {
                            DSInfoText(String(format: "settings.auto.calculate.footer".local(), String(format: "%.1f", calculatedDailyAverage)))
                        }
                    }
                }
            }
        }
    }
    
    private var quitPlanSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(
                    "settings.quit.plan.section".local(),
                    subtitle: "settings.quit.plan.subtitle".local()
                )
                
                VStack(spacing: DS.Space.md) {
                    // Quit date picker
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSFormLabel(
                            text: "settings.when.quit.question".local(),
                            icon: "calendar.badge.clock",
                            isRequired: false
                        )
                        
                        DatePicker(
                            "settings.when.quit.question".local(),
                            selection: Binding(
                                get: { quitDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() },
                                set: { quitDate = $0; hasUnsavedChanges = true }
                            ),
                            in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...Date.distantFuture,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    
                    // Gradual reduction toggle
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Toggle(
                            "settings.gradual.reduction.toggle".local(),
                            isOn: $enableGradualReduction
                        )
                        .toggleStyle(SwitchToggleStyle(tint: DS.Colors.primary))
                        .onChange(of: enableGradualReduction) { _, _ in
                            hasUnsavedChanges = true
                        }
                        
                        DSInfoText(enableGradualReduction ? 
                                   "settings.gradual.reduction.description".local() : 
                                   "settings.immediate.stop.description".local())
                    }
                    
                    // Plan preview
                    if let quitDate = quitDate, enableGradualReduction, dailyAverageForPlan > 0 {
                        quitPlanPreview(quitDate: quitDate)
                    }
                }
            }
        }
    }
    
    private var shouldShowHealthInfo: Bool {
        currentAge > 0 || (!weight.isEmpty && isWeightValid)
    }
    
    private var healthInsightsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(
                    "settings.health.info.section".local(),
                    subtitle: "settings.health.insights.footer".local()
                )
                
                if currentAge > 0, let weightValue = Double(weight), isWeightValid {
                    HealthInsightsView(
                        age: currentAge,
                        weight: weightValue,
                        smokingType: smokingType,
                        yearsSmokingSince: yearsSmokingCalculated
                    )
                } else if currentAge > 0 {
                    DSInfoCard(
                        title: "settings.calculated.age".local(),
                        value: String(format: "settings.years.old".local(), currentAge),
                        icon: "person.circle.fill",
                        color: DS.Colors.info
                    )
                }
            }
        }
    }
    
    private var appInfoSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("settings.app.info.section".local())
                
                HStack {
                    Text("settings.version.label".local())
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                    Spacer()
                    Text(appVersion)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
    }
    
    private var dataManagementSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("settings.data.management".local())
                
                Button(action: {
                    Self.logger.info("Delete all data button tapped")
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(DS.Colors.danger)
                            .frame(width: 24)
                        Text("settings.delete.all.data".local())
                            .foregroundColor(DS.Colors.danger)
                            .font(DS.Text.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(DS.Colors.textSecondary)
                            .font(.caption)
                    }
                    .padding(.vertical, DS.Space.sm)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
                .accessibilityIdentifier("deleteAllDataButton")
                .accessibilityLabel("settings.delete.all.data".local())
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func quitPlanPreview(quitDate: Date) -> some View {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
        let dailyReduction = dailyAverageForPlan / Double(max(daysRemaining, 1))
        
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("settings.plan.preview".local())
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.primary)
            
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                HStack {
                    Text("settings.plan.starting.from".local())
                    Spacer()
                    Text(String(format: "settings.plan.cigarettes.per.day.format".local(), dailyAverageForPlan))
                        .fontWeight(.medium)
                }
                HStack {
                    Text("settings.plan.reaching".local())
                    Spacer()
                    Text("settings.plan.zero.cigarettes".local())
                        .fontWeight(.medium)
                        .foregroundColor(DS.Colors.success)
                }
                HStack {
                    Text("settings.plan.in.days".local())
                    Spacer()
                    Text(String(format: "settings.plan.days.count".local(), daysRemaining))
                        .fontWeight(.medium)
                }
                HStack {
                    Text("settings.plan.daily.reduction".local())
                    Spacer()
                    Text(String(format: "settings.plan.reduction.amount".local(), String(format: "%.2f", dailyReduction)))
                        .fontWeight(.medium)
                        .foregroundColor(DS.Colors.warning)
                }
                HStack {
                    Text("settings.plan.todays.goal".local())
                    Spacer()
                    Text(String(format: "settings.plan.cigarettes.count".local(), todayTarget))
                        .fontWeight(.bold)
                        .foregroundColor(DS.Colors.primary)
                }
            }
            .font(DS.Text.caption)
            
            // Plan feedback
            if daysRemaining <= 0 {
                DSWarningCard("settings.plan.date.too.close".local())
            } else if daysRemaining < 7 {
                DSWarningCard("settings.plan.intensive".local())
            } else {
                DSSuccessCard("settings.plan.balanced".local())
            }
        }
        .padding()
        .background(DS.Colors.backgroundSecondary)
        .cornerRadius(DS.Size.cardRadius)
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    // MARK: - Data Methods
    
    @MainActor
    private func loadProfileData() async {
        guard let profile = profile else { 
            // Set default values
            birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
            return 
        }
        
        name = profile.name
        if let profileBirthDate = profile.birthDate {
            birthDate = profileBirthDate
        }
        weight = profile.weight > 0 ? String(format: "%.1f", profile.weight) : ""
        smokingType = profile.smokingType
        startedSmokingAge = profile.startedSmokingAge
        quitDate = profile.quitDate
        enableGradualReduction = profile.enableGradualReduction
        
        if profile.dailyAverage > 0 {
            dailyAverageInput = String(format: "%.1f", profile.dailyAverage)
        }
        
        hasUnsavedChanges = false
    }
    
    @MainActor
    private func saveProfile() async {
        guard canSave else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let profileToSave: UserProfile
            
            if let existingProfile = profile {
                profileToSave = existingProfile
            } else {
                profileToSave = UserProfile()
                modelContext.insert(profileToSave)
            }
            
            // Save basic data
            profileToSave.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            profileToSave.birthDate = birthDate
            profileToSave.weight = Double(weight) ?? 0.0
            profileToSave.smokingType = smokingType
            profileToSave.startedSmokingAge = startedSmokingAge
            
            // Save quit plan
            profileToSave.quitDate = quitDate
            profileToSave.enableGradualReduction = enableGradualReduction
            
            // Save daily average
            if let dailyAvg = Double(dailyAverageInput), dailyAvg > 0 {
                profileToSave.dailyAverage = dailyAvg
            } else {
                profileToSave.dailyAverage = calculatedDailyAverage
            }
            
            profileToSave.lastUpdated = Date()
            
            try modelContext.save()
            
            hasUnsavedChanges = false
            showingSaveAlert = true
            
            Self.logger.info("Profile saved successfully")
            
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            Self.logger.error("Failed to save profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    @MainActor
    private func deleteAllData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete all cigarettes
            let cigaretteDescriptor = FetchDescriptor<Cigarette>()
            let cigarettes = try modelContext.fetch(cigaretteDescriptor)
            for cigarette in cigarettes {
                modelContext.delete(cigarette)
            }
            
            // Delete all tags
            let tagDescriptor = FetchDescriptor<Tag>()
            let tags = try modelContext.fetch(tagDescriptor)
            for tag in tags {
                modelContext.delete(tag)
            }
            
            // Delete all user profiles
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profiles = try modelContext.fetch(profileDescriptor)
            for profile in profiles {
                modelContext.delete(profile)
            }
            
            // Delete all products
            let productDescriptor = FetchDescriptor<Product>()
            let products = try modelContext.fetch(productDescriptor)
            for product in products {
                modelContext.delete(product)
            }
            
            // Delete all urge logs
            let urgeLogDescriptor = FetchDescriptor<UrgeLog>()
            let urgeLogs = try modelContext.fetch(urgeLogDescriptor)
            for urgeLog in urgeLogs {
                modelContext.delete(urgeLog)
            }
            
            try modelContext.save()
            
            // Reset ALL form data to initial state
            name = ""
            age = ""
            packPrice = ""
            cigarettesPerPack = "20"
            dailyLimit = ""
            enableNotifications = true
            enableGradualReduction = true
            hasUnsavedChanges = false
            
            Self.logger.info("Form data reset to initial state")
            
            Self.logger.info("All user data deleted successfully")
            
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            Self.logger.error("Failed to delete all data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func resetForm() {
        Task {
            await loadProfileData()
        }
        hasUnsavedChanges = false
    }
    
    // MARK: - Phase 4 Sections
    private var myWhySection: some View {
        MyWhyEditor()
    }
    
    private var visualQuitPlanSection: some View {
        VisualQuitPlan(
            quitDate: .constant(Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()),
            enableGradualReduction: $enableGradualReduction
        )
    }
}

// MARK: - Helper Components

struct DSFormLabel: View {
    let text: String
    let icon: String
    let isRequired: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(DS.Colors.primary)
                .frame(width: 24)
            Text(text + (isRequired ? " *" : ""))
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textPrimary)
        }
    }
}

struct DSTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DS.Space.md)
            .background(DS.Colors.backgroundSecondary)
            .cornerRadius(DS.Size.cardRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                    .stroke(DS.Colors.separator, lineWidth: 1)
            )
    }
}

struct DSErrorText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DS.Colors.danger)
                .font(.caption)
            Text(text)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.danger)
        }
    }
}

struct DSInfoText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(DS.Colors.info)
                .font(.caption)
            Text(text)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
        }
    }
}

struct DSInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(DS.Text.body)
                    .fontWeight(.medium)
                Text(value)
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            Spacer()
            Text(value.components(separatedBy: " ").first ?? "")
                .font(DS.Text.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
}

struct DSWarningCard: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DS.Colors.warning)
            Text(text)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textPrimary)
        }
        .padding(DS.Space.sm)
        .background(DS.Colors.warning.opacity(0.1))
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
}

struct DSSuccessCard: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(DS.Colors.success)
            Text(text)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textPrimary)
        }
        .padding(DS.Space.sm)
        .background(DS.Colors.success.opacity(0.1))
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
}

#Preview {
    SettingsViewFixed()
        .modelContainer(for: UserProfile.self, inMemory: true)
}