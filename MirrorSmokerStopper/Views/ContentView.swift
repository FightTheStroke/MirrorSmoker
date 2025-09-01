#if os(iOS)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingTagPicker = false
    @State private var selectedTags: [Tag] = []
    @State private var lastAddedCigarette: Cigarette?
    
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
    
    private var weeklyStats: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        var stats: [(date: Date, count: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayCount = allCigarettes.filter { cigarette in
                cigarette.timestamp >= dayStart && cigarette.timestamp < dayEnd
            }.count
            
            stats.append((date: dayStart, count: dayCount))
        }
        
        return stats
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
    
    // MARK: - New Computed Properties for Enhanced UI
    
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
    
    private var colorForTodayCount: Color {
        switch todayCount {
        case 0:
            return DS.Colors.success
        case 1...5:
            return DS.Colors.primary
        case 6...10:
            return DS.Colors.warning
        case 11...15:
            return DS.Colors.danger
        default:
            return DS.Colors.cigarette
        }
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
    
    private var weeklyTrendDirection: DSHealthCard.TrendDirection? {
        let previousWeekCount = allCigarettes.filter { cigarette in
            let calendar = Calendar.current
            let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            return cigarette.timestamp >= twoWeeksAgo && cigarette.timestamp < oneWeekAgo
        }.count
        
        let currentWeekCount = weeklyCount
        
        if previousWeekCount == 0 && currentWeekCount == 0 {
            return nil
        } else if previousWeekCount == 0 {
            return .up
        } else if currentWeekCount < previousWeekCount {
            return .down
        } else if currentWeekCount > previousWeekCount {
            return .up
        } else {
            return .stable
        }
    }
    
    private var weeklyTrendText: String {
        guard let trend = weeklyTrendDirection else { return "" }
        
        let previousWeekCount = allCigarettes.filter { cigarette in
            let calendar = Calendar.current
            let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            return cigarette.timestamp >= twoWeeksAgo && cigarette.timestamp < oneWeekAgo
        }.count
        
        let difference = abs(weeklyCount - previousWeekCount)
        
        switch trend {
        case .up:
            return "+\(difference) from last week"
        case .down:
            return "-\(difference) from last week"
        case .stable:
            return "same as last week"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    // Hero section with today's stats
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            // Header
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
                                        progress: Double(todayCount) / 20.0,
                                        size: 50,
                                        lineWidth: 4,
                                        color: colorForTodayCount
                                    )
                                }
                            }
                            
                            // Today's main stats
                            HStack(spacing: DS.Space.xl) {
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text(NSLocalizedString("statistics.today", comment: ""))
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.textSecondary)
                                    
                                    Text("\(todayCount)")
                                        .font(DS.Text.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(colorForTodayCount)
                                    
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
                            
                            // Quick action buttons
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
                    }
                    
                    // Quick stats overview
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: DS.Space.md) {
                                DSHealthCard(
                                    title: NSLocalizedString("stats.this.week", comment: ""),
                                    value: "\(weeklyCount)",
                                    subtitle: weeklyTrendText,
                                    icon: "calendar.badge.clock",
                                    color: DS.Colors.primary,
                                    trend: weeklyTrendDirection
                                )
                                
                                DSHealthCard(
                                    title: NSLocalizedString("stats.this.month", comment: ""),
                                    value: "\(monthlyCount)",
                                    subtitle: String(format: "%.1f/day", Double(monthlyCount) / 30.0),
                                    icon: "chart.bar.xaxis",
                                    color: DS.Colors.warning,
                                    trend: nil
                                )
                                
                                DSHealthCard(
                                    title: NSLocalizedString("stats.total", comment: ""),
                                    value: "\(allTimeCount)",
                                    subtitle: NSLocalizedString("all.time", comment: ""),
                                    icon: "infinity",
                                    color: DS.Colors.info,
                                    trend: nil
                                )
                            }
                        }
                    }
                    
                    // Today's cigarettes list
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
                    
                    // Weekly chart preview
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            HStack {
                                DSSectionHeader(NSLocalizedString("weekly.chart.title", comment: ""))
                                Spacer()
                                
                                NavigationLink(destination: EnhancedStatisticsView()) {
                                    Text(NSLocalizedString("view.all", comment: ""))
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.primary)
                                }
                            }
                            
                            EnhancedWeeklyChart(data: weeklyStats.reversed())
                        }
                    }
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
            }
            
            // Floating Action Button - POSIZIONATO A DESTRA
            DSFloatingActionButton {
                addCigarette()
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                if askForTagAfterAdding {
                    lastAddedCigarette = todaysCigarettes.first
                    showingTagPicker = true
                }
            }
            .padding(.bottom, 100) // Spazio per tab bar
            .padding(.trailing, DS.Space.lg)
        }
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
                            
                            Text(stat.count == 1 ? NSLocalizedString("cigarette.singular", comment: "") : NSLocalizedString("cigarettes.plural", comment: ""))
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