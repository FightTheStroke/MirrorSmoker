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
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var showDatePicker = false
    @State private var weight = ""
    @State private var smokingType = SmokingType.cigarettes
    @State private var startedSmokingAge = 18
    @State private var notificationsEnabled = true
    @State private var themePreference = "system"
    @State private var showingSaveConfirmation = false
    @State private var hasLoadedProfile = false
    
    // Focus states for better UX
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, weight, startedSmokingAge
    }
    
    private var profile: UserProfile? {
        // Safely get the first profile, handling potential data corruption
        do {
            return profiles.first
        } catch {
            print("Error accessing profiles: \(error)")
            return nil
        }
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
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    // Name Field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Il tuo nome", text: $name)
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                    }
                    
                    // Birth Date Field
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Data di nascita")
                                .foregroundColor(.primary)
                            
                            if let profile = profile, profile.birthDate != nil {
                                HStack {
                                    Text(birthDate, style: .date)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Età: \(profile.age)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(6)
                                }
                            } else {
                                Text("Non impostata")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showDatePicker = true
                    }
                    
                    // Weight Field
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("Peso (kg)", text: $weight)
                            .focused($focusedField, equals: .weight)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        
                        if !weight.isEmpty {
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isValidWeight ? .clear : .red)
                            .offset(y: 15)
                    )
                    
                    if !isValidWeight {
                        Text("Inserisci un peso valido (1-300 kg)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                } header: {
                    Text("Profilo Personale")
                } footer: {
                    Text("Queste informazioni aiutano a personalizzare le statistiche e i consigli")
                }
                
                // Smoking Habits Section
                Section {
                    // Smoking Type Picker
                    HStack {
                        Image(systemName: smokingType.icon)
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Tipo di fumo")
                        
                        Spacer()
                        
                        Picker("Tipo", selection: $smokingType) {
                            ForEach(SmokingType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Started Smoking Age
                    HStack {
                        Image(systemName: "hourglass.tophalf.filled")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Età quando ho iniziato")
                        
                        Spacer()
                        
                        TextField("Età", value: $startedSmokingAge, formatter: NumberFormatter())
                            .focused($focusedField, equals: .startedSmokingAge)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                        
                        Text("anni")
                            .foregroundColor(.secondary)
                    }
                    
                    if !isValidAge {
                        Text("Inserisci un'età valida (10-80 anni)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Years smoking display
                    if let profile = profile, profile.birthDate != nil && isValidAge {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Anni di fumo")
                            
                            Spacer()
                            
                            Text("\(max(0, profile.age - startedSmokingAge)) anni")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    
                } header: {
                    Text("Abitudini di Fumo")
                } footer: {
                    Text("Aiutaci a capire meglio il tuo percorso con il fumo")
                }
                
                // Preferences Section
                Section {
                    // Notifications Toggle
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Toggle("Notifiche", isOn: $notificationsEnabled)
                    }
                    
                    // Theme Picker
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Tema")
                        
                        Spacer()
                        
                        Picker("Tema", selection: $themePreference) {
                            Text("Sistema").tag("system")
                            Text("Chiaro").tag("light")
                            Text("Scuro").tag("dark")
                        }
                        .pickerStyle(.menu)
                    }
                    
                } header: {
                    Text("Preferenze")
                }
                
                // Health Insights Section (if profile is complete)
                if let profile = profile, profile.birthDate != nil && !weight.isEmpty && isValidWeight {
                    Section {
                        HealthInsightsView(
                            age: profile.age,
                            weight: Double(weight) ?? 0,
                            smokingType: smokingType,
                            yearsSmokingSince: max(0, profile.age - startedSmokingAge)
                        )
                    } header: {
                        Text("Informazioni sulla Salute")
                    } footer: {
                        Text("Queste sono stime basate su dati generali e non sostituiscono il parere medico")
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
                            Text("Salva Modifiche")
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
                
                // Debug Section - only in debug builds
                #if DEBUG
                Section {
                    Button("Clear All Profiles (Debug)") {
                        clearAllProfiles()
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Debug Tools")
                } footer: {
                    Text("This will delete all profile data - use only for debugging")
                }
                #endif
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
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
                    Button("Fine") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $birthDate, isPresented: $showDatePicker)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .alert("Profilo Salvato", isPresented: $showingSaveConfirmation) {
                Button("OK") { 
                    // Clear any navigation state if needed
                }
            } message: {
                Text("Le tue informazioni sono state salvate con successo")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidWeight &&
        isValidAge
    }
    
    // MARK: - Functions
    
    private func loadProfileData() {
        guard let profile = profile else {
            // Set defaults if no profile exists
            return
        }
        
        name = profile.name
        if let birthDate = profile.birthDate {
            self.birthDate = birthDate
        }
        weight = profile.weight > 0 ? String(format: "%.1f", profile.weight) : ""
        smokingType = profile.smokingType
        startedSmokingAge = profile.startedSmokingAge
        notificationsEnabled = profile.notificationsEnabled
        themePreference = profile.themePreference
    }
    
    private func clearAllProfiles() {
        do {
            // Delete all profiles
            for profile in profiles {
                modelContext.delete(profile)
            }
            try modelContext.save()
            
            // Reset the form
            name = ""
            birthDate = Date()
            weight = ""
            smokingType = .cigarettes
            startedSmokingAge = 18
            notificationsEnabled = true
            themePreference = "system"
            
        } catch {
            print("Error clearing profiles: \(error)")
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
        
        profileToSave.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileToSave.birthDate = birthDate
        profileToSave.weight = Double(weight) ?? 0.0
        profileToSave.smokingType = smokingType
        profileToSave.startedSmokingAge = startedSmokingAge
        profileToSave.notificationsEnabled = notificationsEnabled
        profileToSave.themePreference = themePreference
        profileToSave.lastUpdated = Date()
        
        do {
            try modelContext.save()
            showingSaveConfirmation = true
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
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
            VStack {
                DatePicker(
                    "Data di nascita",
                    selection: $selectedDate,
                    in: Date(timeIntervalSince1970: -2208988800)...Date(), // From 1900 to now
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Data di Nascita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Conferma") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct HealthInsightsView: View {
    let age: Int
    let weight: Double
    let smokingType: SmokingType
    let yearsSmokingSince: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // BMI Info (if weight is available)
            if weight > 0 {
                HStack {
                    Image(systemName: "figure.stand")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Informazioni generali")
                            .font(.subheadline)
                        Text("Età: \(age) anni • Peso: \(weight, specifier: "%.1f") kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Smoking Duration Impact
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading) {
                    Text("Durata del fumo")
                        .font(.subheadline)
                    Text("\(yearsSmokingSince) anni di \(smokingType.displayName.lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Health Reminder
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                
                VStack(alignment: .leading) {
                    Text("Ricorda")
                        .font(.subheadline)
                    Text("È sempre il momento giusto per smettere")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .modelContainer(for: UserProfile.self, inMemory: true)
    }
}