#if os(iOS)
import SwiftUI
import SwiftData
import WidgetKit
import os.log

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    @Query private var allTags: [Tag]
    @Query private var allPurchases: [Purchase] // Add this query
    
    @State private var showingSettings = false
    @State private var showingTagSelection = false
    @State private var showingCigaretteSavedNotification = false
    @State private var showingPurchaseSheet = false // Add this state
    @State private var lastSavedCigaretteTagCount = 0
    @State private var selectedCigaretteForTags: Cigarette? = nil
    @State private var insightsViewModel = InsightsViewModel()
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "ContentView")
    
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
            return "no.cigarettes.placeholder".local()
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
        case 5..<12: return "greeting.morning".local()
        case 12..<17: return "greeting.afternoon".local()
        case 17..<22: return "greeting.evening".local()
        default: return "greeting.night".local()
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
        if hours > 0 { return String(format: "time.ago.hours.minutes".local(), hours, minutes) }
        else if minutes > 0 { return String(format: "time.ago.minutes".local(), minutes) }
        else { return "time.just.now".local() }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: DS.Space.lg) {
                    heroSection
                    coachMessageSection
                    quickStatsSection
                    todaysInsightSection
                    todayCigarettesSection
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Colors.background)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingTagSelection) {
                TagSelectionSheet { selectedTags in
                    if let cigarette = selectedCigaretteForTags {
                        // Adding tags to existing cigarette
                        cigarette.tags = selectedTags
                        do {
                            try modelContext.save()
                            Self.logger.info("Tags added to existing cigarette")
                        } catch {
                            Self.logger.error("Error adding tags to cigarette: \(error.localizedDescription)")
                        }
                        selectedCigaretteForTags = nil
                    } else {
                        // Creating new cigarette with tags
                        addCigaretteWithTags(selectedTags)
                    }
                }
            }
            .sheet(isPresented: $showingPurchaseSheet) { // Add this sheet
                PurchaseLoggingSheet()
            }
            
            AdvancedFloatingActionButton(
                quickAction: {
                    Self.logger.debug("FAB quick action triggered")
                    addCigaretteQuickly()
                },
                longPressAction: {
                    Self.logger.debug("FAB long press action triggered")
                    showTagSelection()
                },
                logPurchaseAction: { // Add this action
                    Self.logger.debug("FAB log purchase action triggered")
                    showingPurchaseSheet = true
                }
            )
            .padding(.bottom, 90) // Increased padding to clear tab bar
            .padding(.trailing, DS.Space.lg)
            .zIndex(1000) // Ensure it's on top
            .allowsHitTesting(true)
            
            CigaretteSavedNotification(
                tagCount: lastSavedCigaretteTagCount,
                isShowing: $showingCigaretteSavedNotification
            )
            .padding(.top, 60)
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private var heroSection: some View {
        TodayHeroSection(
            todayCount: todayCount,
            todayTarget: todayTarget,
            dailyAverage: dailyAverageForPlan,
            userProfile: currentProfile,
            colorForTodayCount: colorForTodayCount,
            progressPercentage: progressPercentage,
            timeAgoString: timeAgoString
        )
    }
    
    private var coachMessageSection: some View {
        CoachMessageCard(
            todayCount: todayCount,
            todayTarget: todayTarget,
            dailyAverage: dailyAverageForPlan,
            timeAgoString: timeAgoString
        )
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(greeting)
                    .font(DS.Text.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DS.Colors.textPrimary)
                
                Text(currentProfile?.name ?? "app.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            Spacer()
            DSProgressRing(
                progress: progressPercentage,
                size: 60,
                lineWidth: 6,
                color: colorForTodayCount
            )
            .accessibilityLabel(String(format: "a11y.progress.ring".local(), "\(todayCount)", "\(todayTarget)"))
            .accessibilityValue(Text("\(Int(progressPercentage * 100))%"))
        }
    }
    
    private var todayStatsSection: some View {
        HStack(spacing: DS.Space.xl) {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("statistics.today".local())
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                    Text("\(todayCount)")
                        .font(DS.Text.display)
                        .fontWeight(.bold)
                        .foregroundStyle(colorForTodayCount)
                    
                    Text("/ \(todayTarget)")
                        .font(DS.Text.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: "a11y.today.count.and.target".local(), todayCount, todayTarget))
                
                Text(todayCount == 1 ? "cigarette.singular".local() : "cigarette.plural".local())
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            
            Spacer()
            
            if todayCount > 0 {
                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                    Text("last.one".local())
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    
                    Text(lastCigaretteTime)
                        .font(DS.Text.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .accessibilityLabel(String(format: "a11y.cigarette.time".local(), lastCigaretteTime))
                    
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
                        Text(String(format: "daily.average.format.personal".local(), dailyAverageForPlan))
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        
                        if let quitDate = currentProfile?.quitDate {
                            Text(String(format: "quit.goal.format.personal".local(), quitDate.formatted(date: .abbreviated, time: .omitted)))
                                .font(DS.Text.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(DS.Colors.primary)
                            
                            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
                            if daysRemaining > 0 {
                                Text(String(format: "days.to.goal.format.personal".local(), daysRemaining))
                                    .font(DS.Text.caption)
                                    .foregroundColor(DS.Colors.textTertiary)
                            } else if daysRemaining == 0 {
                                Text("today.is.quit.day.personal".local())
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
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("quick.stats".local())
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                ], spacing: DS.Space.md) {
                    quickStatCard(
                        title: "stats.this.week".local(),
                        value: "\(weeklyCount)",
                        subtitle: "days.7".local(),
                        color: DS.Colors.primary
                    )
                    quickStatCard(
                        title: "stats.this.month".local(),
                        value: "\(monthlyCount)",
                        subtitle: String(format: "stats.per.day.format".local(), String(format: "%.1f", Double(monthlyCount) / 30.0)),
                        color: DS.Colors.warning
                    )
                    quickStatCard(
                        title: "stats.total".local(),
                        value: "\(allTimeCount)",
                        subtitle: "all.time".local(),
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
        .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
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
    
    private var todayCigarettesSection: some View {
        TodayCigarettesList(
            todayCigarettes: todaysCigarettes,
            onDelete: { cigarette in
                deleteCigarette(cigarette)
            },
            onAddTags: { cigarette in
                selectedCigaretteForTags = cigarette
                showingTagSelection = true
            }
        )
    }
    
    // MARK: - Actions
    
    private func addCigaretteQuickly() {
        addCigarette(tags: nil, tagCount: 0)
        Self.logger.info("Quick cigarette added without tags")
    }
    
    private func showTagSelection() {
        showingTagSelection = true
        Self.logger.info("Opening tag selection for cigarette")
    }
    
    private func addCigarette(tags: [Tag]? = nil, tagCount: Int) {
        let newCigarette = Cigarette(timestamp: Date(), note: "", tags: tags)
        modelContext.insert(newCigarette)
        
        do { 
            try modelContext.save()
            
            // Update widget
            WidgetCenter.shared.reloadAllTimelines()
            
            // Show success notification
            lastSavedCigaretteTagCount = tagCount
            showingCigaretteSavedNotification = true
            
            Self.logger.info("Cigarette saved with \(tagCount) tags")
            
        } catch { 
            Self.logger.error("Error saving cigarette: \(error.localizedDescription)")
        }
    }
    
    private func addCigaretteWithTags(_ tags: [Tag]) {
        addCigarette(tags: tags.isEmpty ? nil : tags, tagCount: tags.count)
    }
    
    private func deleteCigarette(_ cigarette: Cigarette) {
        modelContext.delete(cigarette)
        do { 
            try modelContext.save() 
            
            // Update widget
            WidgetCenter.shared.reloadAllTimelines()
            
            Self.logger.info("Cigarette deleted")
            
        } catch { 
            Self.logger.error("Error deleting cigarette: \(error.localizedDescription)") 
        }
    }
    
    private var statusMessageWithCorrectLogic: some View {
        Group {
            let target = todayTarget
            if todayCount == 0 {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("perfect.no.cigarettes.personal".local()).font(DS.Text.headline).foregroundColor(DS.Colors.success)
                    Text("no.cigarettes.today.personal".local()).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.5) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("excellent.under.half.personal".local()).font(DS.Text.headline).foregroundColor(DS.Colors.success)
                    Text("under.half.goal.personal".local()).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < Int(Double(target) * 0.8) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("good.following.plan.personal".local()).font(DS.Text.headline).foregroundColor(DS.Colors.warning)
                    Text("following.plan.personal".local()).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount < target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("attention.near.limit.personal".local()).font(DS.Text.headline).foregroundColor(Color.orange)
                    Text("near.plan.limit.personal".local()).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else if todayCount == target {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("limit.reached.personal".local()).font(DS.Text.headline).foregroundColor(DS.Colors.danger)
                    Text("daily.goal.reached.personal".local()).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("over.plan.personal".local()).font(DS.Text.headline).foregroundColor(DS.Colors.cigarette)
                    Text(String(format: "exceeded.by.format.personal".local(), todayCount - target)).font(DS.Text.caption).foregroundColor(DS.Colors.textSecondary)
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

// MARK: - Purchase Logging Sheet
struct PurchaseLoggingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var productName = ""
    @State private var amountString = ""
    @State private var currencyCode = "USD"
    @State private var quantity = 1
    @State private var errorMessage: String?
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    LegacyDSCard {
                        VStack(spacing: DS.Space.md) {
                            DSSectionHeader(
                                "Log Purchase",
                                subtitle: "Record your tobacco product purchase"
                            )
                            
                            VStack(spacing: DS.Space.md) {
                                // Product Name
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Product Name")
                                        .font(DS.Text.body)
                                        .foregroundColor(DS.Colors.textPrimary)
                                    
                                    TextField("e.g. Marlboro Red", text: $productName)
                                        .textFieldStyle(DSTextFieldStyle())
                                        .autocapitalization(.words)
                                }
                                
                                // Amount
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Amount")
                                        .font(DS.Text.body)
                                        .foregroundColor(DS.Colors.textPrimary)
                                    
                                    TextField("0.00", text: $amountString)
                                        .textFieldStyle(DSTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                }
                                
                                // Currency
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Currency")
                                        .font(DS.Text.body)
                                        .foregroundColor(DS.Colors.textPrimary)
                                    
                                    TextField("USD", text: $currencyCode)
                                        .textFieldStyle(DSTextFieldStyle())
                                        .autocapitalization(.allCharacters)
                                        .onChange(of: currencyCode) { _, newValue in
                                            currencyCode = newValue.uppercased()
                                        }
                                }
                                
                                // Quantity
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text("Quantity")
                                        .font(DS.Text.body)
                                        .foregroundColor(DS.Colors.textPrimary)
                                    
                                    HStack {
                                        Button(action: {
                                            quantity = max(1, quantity - 1)
                                        }) {
                                            Image(systemName: "minus")
                                                .font(.title2)
                                                .foregroundColor(DS.Colors.primary)
                                                .frame(width: 44, height: 44)
                                                .background(DS.Colors.glassSecondary)
                                                .clipShape(Circle())
                                        }
                                        
                                        Text("\(quantity)")
                                            .font(DS.Text.title2)
                                            .fontWeight(.semibold)
                                            .frame(minWidth: 40, alignment: .center)
                                        
                                        Button(action: {
                                            quantity = min(99, quantity + 1)
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundColor(DS.Colors.primary)
                                                .frame(width: 44, height: 44)
                                                .background(DS.Colors.glassSecondary)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(DS.Colors.danger)
                            Text(errorMessage)
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.danger)
                            Spacer()
                        }
                        .padding()
                        .background(DS.Colors.danger.opacity(0.1))
                        .cornerRadius(DS.Size.cardRadiusSmall)
                    }
                }
                .padding(DS.Space.lg)
            }
            .navigationTitle("Log Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePurchase()
                    }
                    .disabled(productName.isEmpty || amountString.isEmpty || isSaving)
                }
            }
        }
    }
    
    private func savePurchase() {
        guard !productName.isEmpty, !amountString.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard let amount = Double(amountString) else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        guard amount > 0 else {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let purchase = Purchase()
        purchase.timestamp = Date()
        purchase.productName = productName
        purchase.setAmountFromCurrency(amount)
        purchase.currencyCode = currencyCode.uppercased()
        purchase.quantity = quantity
        
        modelContext.insert(purchase)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save purchase: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}
#endif