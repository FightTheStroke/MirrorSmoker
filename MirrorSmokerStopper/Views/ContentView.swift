#if os(iOS)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    @Query private var allTags: [Tag]
    
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingTagPicker = false
    @State private var selectedTags: [Tag] = []
    @State private var lastAddedCigarette: Cigarette?
    @State private var insightsViewModel = InsightsViewModel()
    
    // Computed properties for today's data
    private var todaysCigarettes: [Cigarette] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return allCigarettes.filter { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }
    }
    
    private var todayCount: Int {
        todaysCigarettes.count
    }
    
    private var lastCigaretteTime: String {
        guard let lastCigarette = todaysCigarettes.first else {
            return "--:--"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: lastCigarette.timestamp)
    }
    
    private var weeklyCount: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        return allCigarettes.filter { cigarette in
            cigarette.timestamp >= weekAgo
        }.count
    }
    
    private var monthlyCount: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        return allCigarettes.filter { cigarette in
            cigarette.timestamp >= monthAgo
        }.count
    }
    
    private var allTimeCount: Int {
        allCigarettes.count
    }
    
    // Settings computed properties
    private var currentProfile: UserProfile? {
        userProfiles.first
    }
    
    private var askForTagAfterAdding: Bool {
        // Default behavior - could be made configurable in settings
        false
    }
    
    // MARK: - New Computed Properties for Enhanced UI basate sui veri obiettivi
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return NSLocalizedString("greeting.morning", comment: "")
        case 12..<17:
            return NSLocalizedString("greeting.afternoon", comment: "")
        case 17..<22:
            return NSLocalizedString("greeting.evening", comment: "")
        default:
            return NSLocalizedString("greeting.night", comment: "")
        }
    }
    
    private var dailyAverage: Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = allCigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        return recentCigarettes.isEmpty ? 0.0 : Double(recentCigarettes.count) / 30.0
    }
    
    private var todayTarget: Int {
        guard let profile = currentProfile, let quitDate = profile.quitDate else { 
            return max(1, Int(dailyAverage))
        }
        
        let daysToQuit = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 1
        if daysToQuit <= 0 { return 0 }
        
        let dailyReduction = dailyAverage / Double(daysToQuit)
        let targetToday = dailyAverage - dailyReduction
        return max(0, Int(ceil(targetToday)))
    }
    
    private var colorForTodayCount: Color {
        let target = todayTarget

        if todayCount == 0 {
            return DS.Colors.success // Verde - perfetto!
        }
        
        if target <= 0 { // Should have quit
            return DS.Colors.cigarette // Any cigarette is over target
        }
        
        let percentage = Double(todayCount) / Double(target)
        
        if percentage < 0.5 {
            return DS.Colors.success // Verde - sotto metà obiettivo
        } else if percentage < 0.8 {
            return DS.Colors.warning // Giallo - vicino all'obiettivo
        } else if percentage < 1.0 {
            return Color.orange // Arancione - molto vicino al limite
        } else if todayCount == target { // percentage == 1.0
            return DS.Colors.danger // Rosso - ha raggiunto il limite
        } else { // percentage > 1.0
            return DS.Colors.cigarette // Rosso scuro - ha superato l'obiettivo
        }
    }
    
    private var progressPercentage: Double {
        guard todayTarget > 0 else {
            return todayCount > 0 ? 1.0 : 0.0
        }
        return min(1.0, Double(todayCount) / Double(todayTarget))
    }
    
    private var timeAgoString: String {
        guard let lastCigarette = todaysCigarettes.first else { return "" }
        
        let interval = Date().timeIntervalSince(lastCigarette.timestamp)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        mainContentView
    }
    
    private var mainContentView: some View {
        ZStack(alignment: .bottomTrailing) {
            scrollContent
            floatingActionButton
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                todayOverviewSection
                todaysInsightSection
                heroSection
                quickStatsSection
                todaysCigarettesSection
            }
            .padding(DS.Space.lg)
        }
        .background(DS.Colors.background)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showingTagPicker) {
            NavigationView {
                TagPickerView(selectedTags: $selectedTags)
                    .navigationTitle(NSLocalizedString("select.tags", comment: ""))
                    .navigationBarTitleDisplayMode(.inline)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(NSLocalizedString("done", comment: "")) {
                                if let cigarette = lastAddedCigarette {
                                    updateCigaretteTags(cigarette, tags: selectedTags)
                                } else {
                                    addCigaretteWithTags(selectedTags)
                                }
                                showingTagPicker = false
                                selectedTags.removeAll()
                                lastAddedCigarette = nil
                            }
                            .fontWeight(.semibold)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(NSLocalizedString("cancel", comment: "")) {
                                showingTagPicker = false
                                selectedTags.removeAll()
                                lastAddedCigarette = nil
                            }
                        }
                    }
            }
            .presentationBackground(.regularMaterial)
        }
    }
    
    private var heroSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                headerSection
                todayStatsSection
                actionButtonsSection
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(greeting)
                    .font(DS.Text.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DS.Colors.textPrimary)
                
                Text(currentProfile?.name ?? NSLocalizedString("app.subtitle", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            
            Spacer()
            
            if todayCount > 0 {
                DSProgressRing(
                    progress: progressPercentage,
                    size: 50,
                    lineWidth: 4,
                    color: colorForTodayCount
                )
            }
        }
    }
    
    private var todayStatsSection: some View {
        HStack(spacing: DS.Space.xl) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(NSLocalizedString("statistics.today", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                    Text("\(todayCount)")
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(colorForTodayCount)
                    
                    Text("/ \(todayTarget)")
                        .font(DS.Text.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                
                Text(todayCount == 1 ? NSLocalizedString("cigarette.singular", comment: "") : NSLocalizedString("cigarette.plural", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            
            Spacer()
            
            if todayCount > 0 {
                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("last.one", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    
                    Text(lastCigaretteTime)
                        .font(DS.Text.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    Text(timeAgoString)
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: DS.Space.md) {
            DSButton(
                NSLocalizedString("button.smoked.one", comment: ""),
                icon: "plus.circle.fill",
                style: .primary
            ) {
                addCigarette()
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
            
            DSButton(
                NSLocalizedString("button.add.with.tags", comment: ""),
                icon: "tag.circle.fill",
                style: .secondary
            ) {
                showingTagPicker = true
            }
        }
    }
    
    private var todaysCigarettesSection: some View {
        Group {
            if !todaysCigarettes.isEmpty {
                DSCard {
                    VStack(spacing: DS.Space.lg) {
                        DSSectionHeader(NSLocalizedString("todays.cigarettes", comment: ""))
                        TodayCigarettesList(
                            todayCigarettes: todaysCigarettes,
                            onDelete: { cigarette in
                                deleteCigarette(cigarette)
                            },
                            onAddTags: { cigarette in
                                lastAddedCigarette = cigarette
                                showingTagPicker = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var floatingActionButton: some View {
        DSFloatingActionButton {
            addCigarette()
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            if askForTagAfterAdding {
                lastAddedCigarette = todaysCigarettes.first
                showingTagPicker = true
            }
        }
        .padding(.bottom, 100)
        .padding(.trailing, DS.Space.lg)
    }
    
    // MARK: - View Sections
    
    private var todayOverviewSection: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader("Panoramica di Oggi")
                
                HStack(spacing: DS.Space.lg) {
                    // Progress circle
                    VStack(spacing: DS.Space.sm) {
                        ZStack {
                            DSProgressRing(
                                progress: progressPercentage,
                                size: 80,
                                lineWidth: 8,
                                color: colorForTodayCount
                            )
                            
                            VStack(spacing: DS.Space.xxs) {
                                Text("\(todayCount)")
                                    .font(DS.Text.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorForTodayCount)
                                Text("/ \(todayTarget)")
                                    .font(DS.Text.caption)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                        }
                        
                        Text("Oggi")
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    // Status message e info piano
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        statusMessageWithCorrectLogic
                        
                        // Mostra la media e il piano se esistono
                        if dailyAverage > 0 {
                            VStack(alignment: .leading, spacing: DS.Space.xs) {
                                Text("La tua media: \(String(format: "%.1f", dailyAverage))/giorno")
                                    .font(DS.Text.caption)
                                    .foregroundColor(DS.Colors.textSecondary)
                                
                                if let quitDate = currentProfile?.quitDate {
                                    Text("Obiettivo: \(quitDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(DS.Text.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(DS.Colors.primary)
                                    
                                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
                                    if daysRemaining > 0 {
                                        Text("\(daysRemaining) giorni al traguardo")
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.textTertiary)
                                    } else if daysRemaining == 0 {
                                        Text("🎯 Oggi è il grande giorno!")
                                            .font(DS.Text.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DS.Colors.success)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var statusMessageWithCorrectLogic: some View {
        Group {
            let target = todayTarget
            
            if todayCount == 0 {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("🎉 Perfetto!")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.success)
                    Text("Giornata senza sigarette")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.5) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("💚 Ottimo!")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.success)
                    Text("Sotto metà dell'obiettivo")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.8) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("💛 Bene")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.warning)
                    Text("Stai rispettando il piano")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("🧡 Attenzione")
                        .font(DS.Text.headline)
                        .foregroundColor(Color.orange)
                    Text("Vicino al limite del piano")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount == target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("🔴 Limite raggiunto")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.danger)
                    Text("Hai raggiunto l'obiettivo di oggi")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("🚨 Fuori piano")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.cigarette)
                    Text("Hai superato di \(todayCount - target)")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DS.Space.md) {
                    quickStatCard(
                        title: NSLocalizedString("stats.this.week", comment: ""),
                        value: "\(weeklyCount)",
                        subtitle: NSLocalizedString("days.7", comment: ""),
                        color: DS.Colors.primary
                    )
                    
                    quickStatCard(
                        title: NSLocalizedString("stats.this.month", comment: ""),
                        value: "\(monthlyCount)",
                        subtitle: String(format: "%.1f %@", Double(monthlyCount) / 30.0, NSLocalizedString("per.day", comment: "")),
                        color: DS.Colors.warning
                    )
                    
                    quickStatCard(
                        title: NSLocalizedString("stats.total", comment: ""),
                        value: "\(allTimeCount)",
                        subtitle: NSLocalizedString("all.time", comment: ""),
                        color: DS.Colors.info
                    )
                }
            }
        }
    }
    
    private func quickStatCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
                .lineLimit(2)
            
            Text(value)
                .font(DS.Text.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(DS.Text.caption2)
                .foregroundColor(DS.Colors.textTertiary)
                .lineLimit(2)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(DS.Space.sm)
        .background(DS.Colors.backgroundSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    // MARK: - Private Methods
    
    private func addCigarette(tags: [Tag]? = nil) {
        let newCigarette = Cigarette(
            timestamp: Date(),
            note: "",
            tags: tags
        )
        
        modelContext.insert(newCigarette)
        
        do {
            try modelContext.save()
            // TODO: Implement widget sync
            // syncWidgetData()
        } catch {
            print("Error saving cigarette: \(error)")
        }
    }
    
    private func addCigaretteWithTags(_ tags: [Tag]) {
        addCigarette(tags: tags.isEmpty ? nil : tags)
    }
    
    private func updateCigaretteTags(_ cigarette: Cigarette, tags: [Tag]) {
        cigarette.tags = tags.isEmpty ? nil : tags
        
        do {
            try modelContext.save()
        } catch {
            print("Error updating cigarette tags: \(error)")
        }
    }
    
    private func deleteCigarette(_ cigarette: Cigarette) {
        modelContext.delete(cigarette)
        
        do {
            try modelContext.save()
            // TODO: Implement widget sync
            // syncWidgetData()
        } catch {
            print("Error deleting cigarette: \(error)")
        }
    }
    
    // MARK: - Insights System
    
    private var todaysInsightSection: some View {
        Group {
            if let todayInsight = insightsViewModel.getTodayInsight() {
                InsightCard(
                    insight: todayInsight,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            insightsViewModel.dismissInsight(todayInsight)
                        }
                    },
                    onActionTaken: {
                        insightsViewModel.markInsightAsShown(todayInsight)
                        // TODO: Track action taken in analytics
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
    
    private func generateInsightsIfNeeded() {
        guard let currentProfile = currentProfile else { return }
        
        // Generate insights based on current data
        insightsViewModel.generateInsights(
            cigarettes: allCigarettes,
            profile: currentProfile,
            tags: allTags
        )
    }
}

// MARK: - Supporting Views

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    
    private var dailyStats: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allCigarettes) { cigarette in
            calendar.startOfDay(for: cigarette.timestamp)
        }
        
        return grouped.map { (date, cigarettes) in
            (date: date, count: cigarettes.count)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dailyStats.prefix(30), id: \.date) { stat in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stat.date, format: .dateTime.weekday(.wide).month().day())
                                .font(.headline)
                            
                            Text(stat.date, format: .dateTime.year())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(stat.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colorForCount(stat.count))
                            
                            Text(stat.count == 1 ? NSLocalizedString("cigarette.singular", comment: "") : NSLocalizedString("cigarette.plural", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(NSLocalizedString("history.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return .green
        case 1...3: return .blue
        case 4...7: return .orange
        case 8...12: return .red
        default: return .purple
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self], inMemory: true)
    }
}

#endif