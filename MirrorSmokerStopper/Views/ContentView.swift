#if os(iOS)
import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    @Query private var allTags: [Tag]
    
    @State private var showingSettings = false
    @State private var showingTagPicker = false
    @State private var selectedTags: [Tag] = []
    @State private var lastAddedCigarette: Cigarette?
    @State private var insightsViewModel = InsightsViewModel()
    
    private var todaysCigarettes: [Cigarette] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return allCigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
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
        return allCigarettes.filter { $0.timestamp >= weekAgo }.count
    }
    
    private var monthlyCount: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return allCigarettes.filter { $0.timestamp >= monthAgo }.count
    }
    
    private var allTimeCount: Int {
        allCigarettes.count
    }
    
    private var currentProfile: UserProfile? {
        userProfiles.first
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return NSLocalizedString("greeting.morning", comment: "")
        case 12..<17: return NSLocalizedString("greeting.afternoon", comment: "")
        case 17..<22: return NSLocalizedString("greeting.evening", comment: "")
        default: return NSLocalizedString("greeting.night", comment: "")
        }
    }
    
    private var dailyAverageRaw: Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = allCigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        return recent.isEmpty ? 0.0 : Double(recent.count) / 30.0
    }
    
    private var dailyAverageForPlan: Double {
        if let avg = currentProfile?.dailyAverage, avg > 0 {
            return avg
        }
        return dailyAverageRaw
    }
    
    private var todayTarget: Int {
        if let profile = currentProfile {
            return profile.todayTarget(dailyAverage: dailyAverageForPlan)
        } else {
            return max(1, Int(dailyAverageForPlan))
        }
    }
    
    private var colorForTodayCount: Color {
        let target = todayTarget
        if todayCount == 0 { return DS.Colors.success }
        if target <= 0 { return DS.Colors.cigarette }
        let percentage = Double(todayCount) / Double(max(target, 1))
        if percentage < 0.5 { return DS.Colors.success }
        else if percentage < 0.8 { return DS.Colors.warning }
        else if percentage < 1.0 { return Color.orange }
        else if todayCount == target { return DS.Colors.danger }
        else { return DS.Colors.cigarette }
    }
    
    private var progressPercentage: Double {
        guard todayTarget > 0 else { return todayCount > 0 ? 1.0 : 0.0 }
        return min(1.0, Double(todayCount) / Double(todayTarget))
    }
    
    private var timeAgoString: String {
        guard let lastCigarette = todaysCigarettes.first else { return "" }
        let interval = Date().timeIntervalSince(lastCigarette.timestamp)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m ago" }
        else if minutes > 0 { return "\(minutes)m ago" }
        else { return NSLocalizedString("time.just.now", comment: "") }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                Section {
                    VStack(spacing: DS.Space.lg) {
                        heroSection
                        quickStatsSection
                        todaysInsightSection
                    }
                    .listRowBackground(Color.clear)
                }
                
                TodayCigarettesList(
                    todayCigarettes: todaysCigarettes,
                    onDelete: { cigarette in
                        deleteCigarette(cigarette)
                    },
                    onAddTags: { cigarette in
                        lastAddedCigarette = cigarette
                        selectedTags.removeAll()
                        showingTagPicker = true
                    }
                )
            }
            .listStyle(.plain)
            .background(DS.Colors.background)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
            
            DSFloatingActionButton(
                action: {
                    addCigarette()
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                },
                onLongPress: {
                    lastAddedCigarette = nil
                    selectedTags.removeAll()
                    showingTagPicker = true
                }
            )
            .padding(.bottom, 60)
            .padding(.trailing, DS.Space.lg)
        }
    }
    
    private var heroSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                headerSection
                todayStatsSection
                todayOverviewContent
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
                .accessibilityLabel(String(format: NSLocalizedString("a11y.progress.ring", comment: ""), "\(todayCount)", "\(todayTarget)"))
                .accessibilityValue(Text("\(Int(progressPercentage * 100))%"))
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: NSLocalizedString("a11y.today.count.and.target", comment: ""), todayCount, todayTarget))
                
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
                        .accessibilityLabel(String(format: NSLocalizedString("a11y.cigarette.time", comment: ""), lastCigaretteTime))
                    
                    Text(timeAgoString)
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .accessibilityLabel(timeAgoString)
                }
            }
        }
    }
    
    private var todayOverviewContent: some View {
        Group {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                statusMessageWithCorrectLogic
                if dailyAverageForPlan > 0 {
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text(String(format: NSLocalizedString("daily.average.format.personal", comment: ""), dailyAverageForPlan))
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        
                        if let quitDate = currentProfile?.quitDate {
                            Text(String(format: NSLocalizedString("quit.goal.format.personal", comment: ""), quitDate.formatted(date: .abbreviated, time: .omitted)))
                                .font(DS.Text.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(DS.Colors.primary)
                            
                            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
                            if daysRemaining > 0 {
                                Text(String(format: NSLocalizedString("days.to.goal.format.personal", comment: ""), daysRemaining))
                                    .font(DS.Text.caption)
                                    .foregroundColor(DS.Colors.textTertiary)
                            } else if daysRemaining == 0 {
                                Text(NSLocalizedString("today.is.quit.day.personal", comment: ""))
                                    .font(DS.Text.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DS.Colors.success)
                            }
                        }
                    }
                }
            }
            .padding(.top, DS.Space.md)
        }
    }
    
    private var quickStatsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
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
                .minimumScaleFactor(0.8)
            Text(value)
                .font(DS.Text.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(DS.Text.caption2)
                .foregroundColor(DS.Colors.textTertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(DS.Space.sm)
        .background(DS.Colors.backgroundSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(subtitle)")
        .accessibilityAddTraits(.isStaticText)
    }
    
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
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
    
    private func addCigarette(tags: [Tag]? = nil) {
        let newCigarette = Cigarette(timestamp: Date(), note: "", tags: tags)
        modelContext.insert(newCigarette)
        do { 
            try modelContext.save()
            // Update widget
            WidgetCenter.shared.reloadAllTimelines()
        } catch { 
            print("Error saving cigarette: \(error)") 
        }
    }
    
    private func addCigaretteWithTags(_ tags: [Tag]) {
        addCigarette(tags: tags.isEmpty ? nil : tags)
    }
    
    private func updateCigaretteTags(_ cigarette: Cigarette, tags: [Tag]) {
        cigarette.tags = tags.isEmpty ? nil : tags
        do { try modelContext.save() } catch { print("Error updating cigarette tags: \(error)") }
    }
    
    private func deleteCigarette(_ cigarette: Cigarette) {
        modelContext.delete(cigarette)
        do { try modelContext.save() } catch { print("Error deleting cigarette: \(error)") }
    }
    
    private var statusMessageWithCorrectLogic: some View {
        Group {
            let target = todayTarget
            if todayCount == 0 {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("perfect.no.cigarettes.personal", comment: "")).font(DS.Text.headline).foregroundColor(DS.Colors.success)
                    Text(NSLocalizedString("no.cigarettes.today.personal", comment: "")).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.5) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("excellent.under.half.personal", comment: "")).font(DS.Text.headline).foregroundColor(DS.Colors.success)
                    Text(NSLocalizedString("under.half.goal.personal", comment: "")).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.8) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("good.following.plan.personal", comment: "")).font(DS.Text.headline).foregroundColor(DS.Colors.warning)
                    Text(NSLocalizedString("following.plan.personal", comment: "")).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("attention.near.limit.personal", comment: "")).font(DS.Text.headline).foregroundColor(Color.orange)
                    Text(NSLocalizedString("near.plan.limit.personal", comment: "")).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount == target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("limit.reached.personal", comment: "")).font(DS.Text.headline).foregroundColor(DS.Colors.danger)
                    Text(NSLocalizedString("daily.goal.reached.personal", comment: "")).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("over.plan.personal", comment: "")).font(DS.Text.headline).foregroundColor(DS.Colors.cigarette)
                    Text(String(format: NSLocalizedString("exceeded.by.format.personal", comment: ""), todayCount - target)).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
                .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self], inMemory: true)
        }
    }
}
#endif
