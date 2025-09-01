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
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    QuickStatsFooter(
                        weeklyCount: weeklyCount,
                        monthlyCount: monthlyCount,
                        allTimeCount: allTimeCount
                    )
                    
                    DailyStatsHeader(
                        todayCount: todayCount,
                        onQuickAdd: {
                            addCigarette()
                        },
                        onAddWithTags: {
                            showingTagPicker = true
                        }
                    )
                    
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
                    
                    HistorySection(
                        dailyStats: weeklyStats,
                        cigarettes: allCigarettes
                    )
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