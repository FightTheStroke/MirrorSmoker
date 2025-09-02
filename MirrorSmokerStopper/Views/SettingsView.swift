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
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette] // For calculating the average
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var weight = ""
    @State private var smokingType = SmokingType.cigarettes
    @State private var startedSmokingAge = 18
    @State private var showingSaveConfirmation = false
    @State private var hasLoadedProfile = false
    @State private var showDebugPanel = false
    @State private var hasUnsavedChanges = false
    
    @State private var quitDate: Date?
    @State private var enableGradualReduction = true
    @State private var dailyAverageInput = "" // Field for daily average input
    
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
    
    // Calculate today's target based on the plan
    private var todayTarget: Int {
        guard let profile = profile else { return Int(dailyAverageForPlan) }
        return profile.todayTarget(dailyAverage: dailyAverageForPlan)
    }
    
    // Use user input or calculate from history
    private var dailyAverageForPlan: Double {
        if let input = Double(dailyAverageInput), input > 0 {
            return input
        }
        return calculatedDailyAverage
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
    
    private var isValidDailyAverage: Bool {
        if let avg = Double(dailyAverageInput), avg >= 0 && avg <= 100 {
            return true
        }
        return dailyAverageInput.isEmpty
    }
    
    private var currentAge: Int {
        profile?.age ?? 0
    }
    
    private var yearsSmokingCalculated: Int {
        max(0, currentAge - startedSmokingAge)
    }
    
    private var ageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        formatter.minimum = 10
        formatter.maximum = 100
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    // Quit Plan Section - moved to top
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.quit.plan.section", comment: ""), subtitle: NSLocalizedString("settings.quit.plan.subtitle", comment: ""))
                            
                            VStack(spacing: DS.Space.md) {
                                // Daily average field - moved from smoking habits
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.daily.cigarettes.label", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    TextField(NSLocalizedString("settings.daily.cigarettes.example", comment: ""), text: $dailyAverageInput)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                        .onChange(of: dailyAverageInput) { hasUnsavedChanges = true }
                                    
                                    if !isValidDailyAverage && !dailyAverageInput.isEmpty {
                                        Text(NSLocalizedString("settings.daily.cigarettes.invalid", comment: ""))
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                    
                                    Text(String(format: NSLocalizedString("settings.auto.calculate.footer", comment: ""), String(format: "%.1f", calculatedDailyAverage)))
                                        .font(DS.Text.caption)
                                        .foregroundColor(DS.Colors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                // Show current calculated average
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        VStack(alignment: .leading) {
                                            Text(NSLocalizedString("settings.daily.average.title", comment: ""))
                                                .font(DS.Text.body)
                                            Text(NSLocalizedString("settings.daily.average.subtitle", comment: ""))
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Text(String(format: "%.1f", calculatedDailyAverage))
                                            .font(DS.Text.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(DS.Colors.primary)
                                    }
                                    .padding()
                                    .background(DS.Colors.info.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Quit date
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(DS.Colors.primary)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.when.quit.question", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    DatePicker(
                                        NSLocalizedString("settings.when.quit.question", comment: ""),
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
                                
                                // Gradual plan toggle
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    Toggle(NSLocalizedString("settings.gradual.reduction.toggle", comment: ""), isOn: $enableGradualReduction)
                                        .toggleStyle(SwitchToggleStyle())
                                        .onChange(of: enableGradualReduction) { hasUnsavedChanges = true }
                                    
                                    Text(enableGradualReduction ? 
                                         NSLocalizedString("settings.gradual.reduction.description", comment: "") : 
                                         NSLocalizedString("settings.immediate.stop.description", comment: ""))
                                        .font(DS.Text.caption)
                                        .foregroundColor(DS.Colors.textSecondary)
                                }
                                
                                // Plan preview if date is selected
                                if let quitDate = quitDate, enableGradualReduction {
                                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
                                    let dailyReduction = dailyAverageForPlan / Double(max(daysRemaining, 1))
                                    
                                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                                        Text(NSLocalizedString("settings.plan.preview", comment: ""))
                                            .font(DS.Text.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DS.Colors.primary)
                                        
                                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                                            HStack {
                                                Text(NSLocalizedString("settings.plan.starting.from", comment: ""))
                                                Spacer()
                                                Text("\(String(format: "%.1f", dailyAverageForPlan)) sigarette/giorno")
                                                    .fontWeight(.medium)
                                            }
                                            HStack {
                                                Text(NSLocalizedString("settings.plan.reaching", comment: ""))
                                                Spacer()
                                                Text(NSLocalizedString("settings.plan.zero.cigarettes", comment: ""))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(DS.Colors.success)
                                            }
                                            HStack {
                                                Text(NSLocalizedString("settings.plan.in.days", comment: ""))
                                                Spacer()
                                                Text(String(format: NSLocalizedString("settings.plan.days.count", comment: ""), daysRemaining))
                                                    .fontWeight(.medium)
                                            }
                                            HStack {
                                                Text(NSLocalizedString("settings.plan.daily.reduction", comment: ""))
                                                Spacer()
                                                Text(String(format: NSLocalizedString("settings.plan.reduction.amount", comment: ""), String(format: "%.2f", dailyReduction)))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(DS.Colors.warning)
                                            }
                                            HStack {
                                                Text(NSLocalizedString("settings.plan.todays.goal", comment: ""))
                                                Spacer()
                                                Text(String(format: NSLocalizedString("settings.plan.cigarettes.count", comment: ""), todayTarget))
                                                    .fontWeight(.bold)
                                                    .foregroundColor(DS.Colors.primary)
                                            }
                                        }
                                        .font(DS.Text.caption)
                                        
                                        if daysRemaining <= 0 {
                                            Text(NSLocalizedString("settings.plan.date.too.close", comment: ""))
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.danger)
                                                .padding(DS.Space.sm)
                                                .background(DS.Colors.danger.opacity(0.1))
                                                .cornerRadius(8)
                                        } else if daysRemaining < 7 {
                                            Text(NSLocalizedString("settings.plan.intensive", comment: ""))
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.warning)
                                                .padding(DS.Space.sm)
                                                .background(DS.Colors.warning.opacity(0.1))
                                                .cornerRadius(8)
                                        } else {
                                            Text(NSLocalizedString("settings.plan.balanced", comment: ""))
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.success)
                                                .padding(DS.Space.sm)
                                                .background(DS.Colors.success.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding()
                                    .background(DS.Colors.backgroundSecondary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Profile Section
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.personal.profile", comment: ""))
                            
                            VStack(spacing: DS.Space.md) {
                                // Name
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(DS.Colors.primary)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.name.label", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    TextField(NSLocalizedString("settings.name.placeholder", comment: ""), text: $name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textInputAutocapitalization(.words)
                                        .onChange(of: name) { hasUnsavedChanges = true }
                                }
                                
                                // Birth date - standard DatePicker
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.birth.date.label", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    DatePicker(
                                        NSLocalizedString("settings.birth.date.label", comment: ""),
                                        selection: $birthDate,
                                        in: Date.distantPast...Date(),
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .onChange(of: birthDate) { hasUnsavedChanges = true }
                                }
                                
                                // Weight
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "scalemass")
                                            .foregroundColor(DS.Colors.health)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.weight.label", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    TextField("0", text: $weight)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                        .onChange(of: weight) { hasUnsavedChanges = true }
                                        .toolbar {
                                            if #available(iOS 15.0, *) {
                                                ToolbarItemGroup(placement: .keyboard) {
                                                    Spacer()
                                                    Button(NSLocalizedString("done", comment: "")) {
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                    }
                                                }
                                            }
                                        }
                                        .onReceive(weight.publisher) { _ in
                                            // Format weight input with proper locale
                                            if let value = Double(weight), value > 0 {
                                                let formatter = NumberFormatter()
                                                formatter.numberStyle = .decimal
                                                formatter.maximumFractionDigits = 1
                                                formatter.locale = Locale.current
                                                if let formatted = formatter.string(from: NSNumber(value: value)) {
                                                    if formatted != weight {
                                                        weight = formatted
                                                    }
                                                }
                                            }
                                        }
                                    
                                    if !isValidWeight && !weight.isEmpty {
                                        Text(NSLocalizedString("settings.weight.invalid.message", comment: ""))
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Smoking Habits
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.smoking.habits.section", comment: ""))
                            
                            VStack(spacing: DS.Space.md) {
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: smokingType.icon)
                                            .foregroundColor(DS.Colors.warning)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.smoking.type.label", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    Picker(NSLocalizedString("smoking.type.picker.label", comment: ""), selection: $smokingType) {
                                        ForEach(SmokingType.allCases, id: \.self) { type in
                                            Text(type.displayName).tag(type)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .onChange(of: smokingType) { hasUnsavedChanges = true }
                                }
                                
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "hourglass.tophalf.filled")
                                            .foregroundColor(DS.Colors.cigarette)
                                            .frame(width: 24)
                                        Text(NSLocalizedString("settings.started.smoking.age", comment: ""))
                                            .font(DS.Text.body)
                                    }
                                    TextField("18", value: $startedSmokingAge, formatter: ageFormatter)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .onChange(of: startedSmokingAge) { hasUnsavedChanges = true }
                                        .toolbar {
                                            if #available(iOS 15.0, *) {
                                                ToolbarItemGroup(placement: .keyboard) {
                                                    Spacer()
                                                    Button(NSLocalizedString("done", comment: "")) {
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                    }
                                                }
                                            }
                                        }
                                    
                                    if !isValidAge {
                                        Text(NSLocalizedString("settings.age.invalid.message", comment: ""))
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    
                    
                    // Health Insights with calculated age
                    if currentAge > 0 || !weight.isEmpty && isValidWeight {
                        DSCard {
                            VStack(spacing: DS.Space.lg) {
                                DSSectionHeader(NSLocalizedString("settings.health.info.section", comment: ""))
                                
                                if currentAge > 0 {
                                    VStack(alignment: .leading, spacing: DS.Space.md) {
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundColor(DS.Colors.info)
                                                .frame(width: 24)
                                            VStack(alignment: .leading) {
                                                Text(NSLocalizedString("settings.calculated.age", comment: ""))
                                                    .font(DS.Text.body)
                                                    .fontWeight(.medium)
                                                Text(String(format: NSLocalizedString("settings.years.old", comment: ""), currentAge))
                                                    .font(DS.Text.caption)
                                                    .foregroundColor(DS.Colors.textSecondary)
                                            }
                                            Spacer()
                                            Text("\(currentAge)")
                                                .font(DS.Text.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(DS.Colors.primary)
                                        }
                                        .padding()
                                        .background(DS.Colors.info.opacity(0.1))
                                        .cornerRadius(8)
                                        
                                        if !weight.isEmpty && isValidWeight {
                                            HealthInsightsView(
                                                age: currentAge,
                                                weight: Double(weight) ?? 0,
                                                smokingType: smokingType,
                                                yearsSmokingSince: yearsSmokingCalculated
                                            )
                                        }
                                    }
                                } else if !weight.isEmpty && isValidWeight {
                                    HealthInsightsView(
                                        age: currentAge,
                                        weight: Double(weight) ?? 0,
                                        smokingType: smokingType,
                                        yearsSmokingSince: yearsSmokingCalculated
                                    )
                                }
                            }
                        }
                    }
                    
                    // App Info - uguale a prima
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("settings.app.info.section", comment: ""))
                            HStack {
                                Text(NSLocalizedString("settings.version.label", comment: ""))
                                Spacer()
                                Text(appVersion)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                        }
                    }
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await saveProfile()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }) {
                        HStack(spacing: 4) {
                            if hasUnsavedChanges {
                                Circle()
                                    .fill(DS.Colors.warning)
                                    .frame(width: 6, height: 6)
                            }
                            Text(NSLocalizedString("save", comment: ""))
                        }
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if !hasLoadedProfile {
                loadProfileData()
                hasLoadedProfile = true
            }
        }
        .alert(NSLocalizedString("plan.saved.title", comment: ""), isPresented: $showingSaveConfirmation) {
            Button("OK") { 
                dismiss()
            }
        } message: {
            Text(NSLocalizedString("plan.saved.message", comment: ""))
        }
        .onAppear {
            // Reset unsaved changes when view appears
            hasUnsavedChanges = false
        }
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidWeight &&
        isValidAge &&
        isValidDailyAverage
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
        
        // Load quit plan
        quitDate = profile.quitDate
        enableGradualReduction = profile.enableGradualReduction
        
        // Load daily average if present
        if profile.dailyAverage > 0 {
            dailyAverageInput = String(format: "%.1f", profile.dailyAverage)
        }
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
        
        // Salva dati base
        profileToSave.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileToSave.birthDate = birthDate
        profileToSave.weight = Double(weight) ?? 0.0
        profileToSave.smokingType = smokingType
        profileToSave.startedSmokingAge = startedSmokingAge
        
        // Save quit plan
        profileToSave.quitDate = quitDate
        profileToSave.enableGradualReduction = enableGradualReduction
        
        // Save daily average if provided
        if let dailyAvg = Double(dailyAverageInput), dailyAvg > 0 {
            profileToSave.dailyAverage = dailyAvg
        } else {
            profileToSave.dailyAverage = calculatedDailyAverage
        }
        
        profileToSave.lastUpdated = Date()
        
        do {
            try modelContext.save()
            hasUnsavedChanges = false
            showingSaveConfirmation = true
        } catch {
            print(NSLocalizedString("error.saving.profile", comment: ""), error)
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
                    title: NSLocalizedString("health.general.info", comment: ""),
                    value: String(format: "%.0f kg", weight),
                    subtitle: String(format: NSLocalizedString("settings.health.insights.age.weight.format", comment: ""), age, weight),
                    icon: "figure.stand",
                    color: DS.Colors.health,
                    trend: nil
                )
            }
            
            DSHealthCard(
                title: NSLocalizedString("health.smoking.duration", comment: ""),
                value: "\(yearsSmokingSince)",
                subtitle: NSLocalizedString("health.smoking.duration.years", comment: ""),
                icon: "exclamationmark.triangle.fill",
                color: DS.Colors.warning,
                trend: .stable
            )
            
            DSHealthCard(
                title: NSLocalizedString("health.remember", comment: ""),
                value: smokingType.displayName,
                subtitle: NSLocalizedString("health.good.time.to.quit", comment: ""),
                icon: "heart.fill",
                color: DS.Colors.danger,
                trend: nil
            )
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
