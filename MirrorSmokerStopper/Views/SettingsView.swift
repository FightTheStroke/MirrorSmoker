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
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette] // NEED: Per calcolare la media
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var showDatePicker = false
    @State private var weight = ""
    @State private var smokingType = SmokingType.cigarettes
    @State private var startedSmokingAge = 18
    @State private var showingSaveConfirmation = false
    @State private var hasLoadedProfile = false
    @State private var showDebugPanel = false
    
    @State private var quitDate: Date?
    @State private var showQuitDatePicker = false
    @State private var enableGradualReduction = true
    @State private var dailyAverageInput = "" // NEW: Campo per la media giornaliera
    
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
    
    // Calcola l'obiettivo di oggi basato sul piano
    private var todayTarget: Int {
        guard let profile = profile else { return Int(dailyAverageForPlan) }
        return profile.todayTarget(dailyAverage: dailyAverageForPlan)
    }
    
    // Usa l'input dell'utente o calcola dalla cronologia
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    // Profile Section - uguale a prima
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader("Profilo Personale")
                            
                            VStack(spacing: DS.Space.md) {
                                // Nome
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(DS.Colors.primary)
                                            .frame(width: 24)
                                        Text("Nome")
                                            .font(DS.Text.body)
                                    }
                                    TextField("Il tuo nome", text: $name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textInputAutocapitalization(.words)
                                }
                                
                                // Data di nascita
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        Text("Data di nascita")
                                            .font(DS.Text.body)
                                    }
                                    Button(action: { showDatePicker = true }) {
                                        HStack {
                                            Text(currentAge > 0 ? "\(currentAge) anni" : "Seleziona data")
                                                .foregroundColor(currentAge > 0 ? DS.Colors.textPrimary : DS.Colors.textSecondary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(DS.Colors.textSecondary)
                                        }
                                        .padding()
                                        .background(DS.Colors.backgroundSecondary)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Peso
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "scalemass")
                                            .foregroundColor(DS.Colors.health)
                                            .frame(width: 24)
                                        Text("Peso (kg)")
                                            .font(DS.Text.body)
                                    }
                                    TextField("0", text: $weight)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    
                                    if !isValidWeight && !weight.isEmpty {
                                        Text("Inserisci un peso valido (1-300 kg)")
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Smoking Habits - uguale a prima
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader("Abitudini di Fumo")
                            
                            VStack(spacing: DS.Space.md) {
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: smokingType.icon)
                                            .foregroundColor(DS.Colors.warning)
                                            .frame(width: 24)
                                        Text("Tipo di fumo")
                                            .font(DS.Text.body)
                                    }
                                    Picker("Tipo", selection: $smokingType) {
                                        ForEach(SmokingType.allCases, id: \.self) { type in
                                            Text(type.displayName).tag(type)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "hourglass.tophalf.filled")
                                            .foregroundColor(DS.Colors.cigarette)
                                            .frame(width: 24)
                                        Text("Età quando ho iniziato")
                                            .font(DS.Text.body)
                                    }
                                    TextField("18", value: $startedSmokingAge, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                    
                                    if !isValidAge {
                                        Text("Inserisci un'età valida (10-80 anni)")
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                }
                                
                                // NEW: Campo per la media giornaliera
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        Text("Sigarette al giorno (media)")
                                            .font(DS.Text.body)
                                    }
                                    TextField("Esempio: 15.5", text: $dailyAverageInput)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    
                                    if !isValidDailyAverage && !dailyAverageInput.isEmpty {
                                        Text("Inserisci un valore valido (0-100 sigarette/giorno)")
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.danger)
                                    }
                                    
                                    Text("Lascia vuoto per calcolare automaticamente dagli ultimi 30 giorni (\(String(format: "%.1f", calculatedDailyAverage)) sigarette/giorno)")
                                        .font(DS.Text.caption)
                                        .foregroundColor(DS.Colors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader("Piano di Cessazione", subtitle: "Creeremo automaticamente un piano personalizzato per te")
                            
                            VStack(spacing: DS.Space.md) {
                                // Mostra la media attuale calcolata
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                            .foregroundColor(DS.Colors.info)
                                            .frame(width: 24)
                                        VStack(alignment: .leading) {
                                            Text("La tua media giornaliera")
                                                .font(DS.Text.body)
                                            Text("Calcolata dagli ultimi 30 giorni")
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
                                
                                // Data quando vuole smettere - QUESTO È L'UNICO CAMPO DA INSERIRE
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(DS.Colors.primary)
                                            .frame(width: 24)
                                        Text("Quando vuoi smettere completamente?")
                                            .font(DS.Text.body)
                                    }
                                    Button(action: { showQuitDatePicker = true }) {
                                        HStack {
                                            Text(quitDate?.formatted(date: .complete, time: .omitted) ?? "Seleziona una data")
                                                .foregroundColor(quitDate != nil ? DS.Colors.textPrimary : DS.Colors.textSecondary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(DS.Colors.textSecondary)
                                        }
                                        .padding()
                                        .background(DS.Colors.backgroundSecondary)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Toggle per piano graduale
                                VStack(alignment: .leading, spacing: DS.Space.sm) {
                                    Toggle("Usa riduzione graduale (consigliato)", isOn: $enableGradualReduction)
                                        .toggleStyle(SwitchToggleStyle())
                                    
                                    Text(enableGradualReduction ? 
                                         "Ridurremo gradualmente il numero di sigarette fino ad arrivare a zero" : 
                                         "Stop immediato alla data selezionata")
                                        .font(DS.Text.caption)
                                        .foregroundColor(DS.Colors.textSecondary)
                                }
                                
                                // PREVIEW DEL PIANO se la data è selezionata
                                if let quitDate = quitDate, enableGradualReduction {
                                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
                                    let dailyReduction = dailyAverageForPlan / Double(max(daysRemaining, 1))
                                    
                                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                                        Text("Anteprima del tuo piano:")
                                            .font(DS.Text.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DS.Colors.primary)
                                        
                                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                                            HStack {
                                                Text("• Inizi da:")
                                                Spacer()
                                                Text("\(String(format: "%.1f", dailyAverageForPlan)) sigarette/giorno")
                                                    .fontWeight(.medium)
                                            }
                                            HStack {
                                                Text("• Arrivi a:")
                                                Spacer()
                                                Text("0 sigarette/giorno")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(DS.Colors.success)
                                            }
                                            HStack {
                                                Text("• In:")
                                                Spacer()
                                                Text("\(daysRemaining) giorni")
                                                    .fontWeight(.medium)
                                            }
                                            HStack {
                                                Text("• Riduzione giornaliera:")
                                                Spacer()
                                                Text("-\(String(format: "%.2f", dailyReduction)) sigarette")
                                                    .fontWeight(.medium)
                                                    .foregroundColor(DS.Colors.warning)
                                            }
                                            HStack {
                                                Text("• Obiettivo di oggi:")
                                                Spacer()
                                                Text("\(todayTarget) sigarette")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(DS.Colors.primary)
                                            }
                                        }
                                        .font(DS.Text.caption)
                                        
                                        if daysRemaining <= 0 {
                                            Text("⚠️ La data selezionata è troppo vicina. Seleziona una data più lontana per un piano graduale efficace.")
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.danger)
                                                .padding(DS.Space.sm)
                                                .background(DS.Colors.danger.opacity(0.1))
                                                .cornerRadius(8)
                                        } else if daysRemaining < 7 {
                                            Text("💡 Piano intensivo: riduzione rapida in pochi giorni. Potresti considerare una data più lontana per un piano più graduale.")
                                                .font(DS.Text.caption)
                                                .foregroundColor(DS.Colors.warning)
                                                .padding(DS.Space.sm)
                                                .background(DS.Colors.warning.opacity(0.1))
                                                .cornerRadius(8)
                                        } else {
                                            Text("✅ Piano ben bilanciato! Riduzione graduale sostenibile nel tempo.")
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
                    
                    // Save Button
                    DSButton(
                        "Salva Piano di Cessazione", 
                        icon: "checkmark.circle.fill",
                        style: canSave ? .primary : .secondary
                    ) {
                        Task { await saveProfile() }
                    }
                    .disabled(!canSave)
                    
                    // Health Insights - uguale a prima
                    if currentAge > 0 && !weight.isEmpty && isValidWeight {
                        DSCard {
                            VStack(spacing: DS.Space.lg) {
                                DSSectionHeader("Informazioni sulla Salute")
                                HealthInsightsView(
                                    age: currentAge,
                                    weight: Double(weight) ?? 0,
                                    smokingType: smokingType,
                                    yearsSmokingSince: yearsSmokingCalculated
                                )
                            }
                        }
                    }
                    
                    // App Info - uguale a prima
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader("Informazioni App")
                            HStack {
                                Text("Versione")
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
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if !hasLoadedProfile {
                loadProfileData()
                hasLoadedProfile = true
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $birthDate, isPresented: $showDatePicker, title: "Data di nascita")
        }
        .sheet(isPresented: $showQuitDatePicker) {
            DatePickerView(
                selectedDate: Binding(
                    get: { quitDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() },
                    set: { quitDate = $0 }
                ),
                isPresented: $showQuitDatePicker,
                title: "Quando vuoi smettere?",
                minimumDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            )
        }
        .alert("Piano Salvato", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("Il tuo piano di cessazione è stato salvato con successo")
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
        
        // Carica piano cessazione
        quitDate = profile.quitDate
        enableGradualReduction = profile.enableGradualReduction
        
        // Carica media giornaliera se presente
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
        
        // Salva piano cessazione
        profileToSave.quitDate = quitDate
        profileToSave.enableGradualReduction = enableGradualReduction
        
        // Salva la media giornaliera se fornita
        if let dailyAvg = Double(dailyAverageInput), dailyAvg > 0 {
            profileToSave.dailyAverage = dailyAvg
        } else {
            profileToSave.dailyAverage = calculatedDailyAverage
        }
        
        profileToSave.lastUpdated = Date()
        
        do {
            try modelContext.save()
            showingSaveConfirmation = true
        } catch {
            print("Errore salvataggio profilo: \(error)")
        }
    }
}

// Date picker semplificato
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let title: String
    let minimumDate: Date?
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>, title: String, minimumDate: Date? = nil) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        self.title = title
        self.minimumDate = minimumDate
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    in: (minimumDate ?? Date.distantPast)...Date.distantFuture,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fine") { isPresented = false }
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
        VStack(spacing: DS.Space.md) {
            if weight > 0 {
                DSHealthCard(
                    title: "Informazioni Generali",
                    value: String(format: "%.0f kg", weight),
                    subtitle: "\(age) anni, \(String(format: "%.0f", weight)) kg",
                    icon: "figure.stand",
                    color: DS.Colors.health,
                    trend: nil
                )
            }
            
            DSHealthCard(
                title: "Durata del Fumo",
                value: "\(yearsSmokingSince)",
                subtitle: "anni",
                icon: "exclamationmark.triangle.fill",
                color: DS.Colors.warning,
                trend: .stable
            )
            
            DSHealthCard(
                title: "Ricordati",
                value: smokingType.displayName,
                subtitle: "È sempre un buon momento per smettere",
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