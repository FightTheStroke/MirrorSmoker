import SwiftUI
import SwiftData

struct EnhancedStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \Purchase.timestamp, order: .reverse) private var allPurchases: [Purchase] // Add this query
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case today = "today"
        case yesterday = "yesterday" 
        case week = "week"
        case month = "month"
        case all = "all"
        
        var displayName: String {
            switch self {
            case .today:
                return "time.range.today".local()
            case .yesterday:
                return "time.range.yesterday".local()
            case .week:
                return "time.range.week".local()
            case .month:
                return "time.range.month".local()
            case .all:
                return "time.range.all".local()
            }
        }
    }
    
    private var currentProfile: UserProfile? {
        userProfiles.first
    }
    
    private var cigarettesForSelectedRange: [Cigarette] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date? = {
            switch selectedTimeRange {
            case .today:
                return calendar.startOfDay(for: now)
            case .yesterday:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .all:
                return nil
            }
        }()
        
        if let startDate = startDate {
            return allCigarettes.filter { $0.timestamp >= startDate }
        }
        return allCigarettes
    }
    
    private var groupedCigarettesByDay: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: cigarettesForSelectedRange) { cigarette in
            calendar.startOfDay(for: cigarette.timestamp)
        }
        return grouped.map { (date, cigarettes) in
            (date: date, count: cigarettes.count)
        }.sorted { $0.date < $1.date }
    }
    
    private var averagePerDaySelectedRange: Double {
        guard !groupedCigarettesByDay.isEmpty else { return 0 }
        let total = groupedCigarettesByDay.reduce(0) { $0 + $1.count }
        return Double(total) / Double(groupedCigarettesByDay.count)
    }
    
    private var highestDay: (date: Date, count: Int)? {
        groupedCigarettesByDay.max { $0.count < $1.count }
    }
    
    private var lowestDay: (date: Date, count: Int)? {
        groupedCigarettesByDay.min { $0.count < $1.count }
    }
    
    private var todaysCigarettes: [Cigarette] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return allCigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
    }
    
    private var todayCount: Int {
        todaysCigarettes.count
    }
    
    private var dailyAverageLast30Days: Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = allCigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        return recentCigarettes.isEmpty ? 0.0 : Double(recentCigarettes.count) / 30.0
    }
    
    private var dailyAverageForPlan: Double {
        if let avg = currentProfile?.dailyAverage, avg > 0 {
            return avg
        }
        return dailyAverageLast30Days
    }
    
    private var todayTarget: Int {
        guard let profile = currentProfile else { return max(1, Int(dailyAverageForPlan)) }
        return profile.todayTarget(dailyAverage: dailyAverageForPlan)
    }
    
    private var colorForTodayCount: Color {
        let target = todayTarget
        if todayCount == 0 {
            return DS.Colors.success
        }
        if target <= 0 {
            return DS.Colors.cigarette
        }
        let percentage = Double(todayCount) / Double(target)
        if percentage < 0.5 {
            return DS.Colors.success
        } else if percentage < 0.8 {
            return DS.Colors.warning
        } else if percentage < 1.0 {
            return Color.orange
        } else if todayCount == target {
            return DS.Colors.danger
        } else {
            return DS.Colors.cigarette
        }
    }
    
    // Add this computed property for financial savings
    private var totalSpentInSelectedRange: Double {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date? = {
            switch selectedTimeRange {
            case .today:
                return calendar.startOfDay(for: now)
            case .yesterday:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .all:
                return nil
            }
        }()
        
        var filteredPurchases = allPurchases
        if let startDate = startDate {
            filteredPurchases = allPurchases.filter { $0.timestamp >= startDate }
        }
        
        return filteredPurchases.reduce(0) { total, purchase in
            total + (purchase.amountInCurrency * Double(purchase.quantity))
        }
    }
    
    // Add this computed property for potential savings
    private var potentialSavingsInSelectedRange: Double {
        // Calculate potential savings based on cigarettes not smoked
        // This is a simplified calculation - in a real app you might want more sophisticated logic
        let cigarettesPerPack = 20.0
        let averagePricePerPack = 10.0 // This should come from user data or defaults
        
        let cigarettesSaved = max(0, Int(dailyAverageForPlan * Double(groupedCigarettesByDay.count)) - cigarettesForSelectedRange.count)
        let packsSaved = Double(cigarettesSaved) / cigarettesPerPack
        return packsSaved * averagePricePerPack
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                todayOverviewSection
                financialSavingsSection // Add this section
                statisticsSection
                chartsSection
                detailedStatsSection
            }
            .padding(DS.Space.lg)
        }
        .background(DS.Colors.background)
        .navigationTitle("statistics.title.main".local())
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var todayOverviewSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader("statistics.todays.overview".local())
                
                HStack(spacing: DS.Space.xl) {
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text("statistics.today.label".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                            Text("\(todayCount)")
                                .font(DS.Text.display)
                                .fontWeight(.bold)
                                .foregroundColor(colorForTodayCount)
                            
                            Text("/ \(todayTarget)")
                                .font(DS.Text.title2)
                                .fontWeight(.medium)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                        
                        Text(todayCount == 1 ? "statistics.today.single".local() : "statistics.today.plural".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(DS.Colors.glassSecondary, lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0.0, to: min(1.0, Double(todayCount) / Double(max(1, todayTarget))))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [colorForTodayCount.opacity(0.7), colorForTodayCount]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(DS.Animation.glass, value: todayCount)
                        
                        VStack(spacing: DS.Space.xxs) {
                            Text("\(todayCount)")
                                .font(DS.Text.title3)
                                .fontWeight(.bold)
                                .foregroundColor(colorForTodayCount)
                            Text("/ \(todayTarget)")
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                    .frame(width: 60, height: 60)
                }
                
                statusMessageForToday
            }
        }
    }
    
    private var statusMessageForToday: some View {
        Group {
            let target = todayTarget
            if todayCount == 0 {
                Text("statistics.no.cigarettes.today.full".local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.success)
            } else if todayCount <= target {
                Text("statistics.following.plan.full".local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.warning)
            } else {
                Text("statistics.exceeded.goal.full".local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.danger)
            }
        }
    }
    
    private var statisticsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                HStack {
                    DSSectionHeader("statistics.title".local())
                    Spacer()
                    timeRangePicker
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DS.Space.md) {
                    statCard(
                        title: "statistics.total".local(),
                        value: "\(cigarettesForSelectedRange.count)",
                        subtitle: "statistics.cigarettes.unit".local(),
                        color: DS.Colors.primary,
                        icon: "lungs.fill"
                    )
                    
                    statCard(
                        title: "statistics.average.per.day".local(),
                        value: String(format: "%.1f", averagePerDaySelectedRange),
                        subtitle: "statistics.cigarettes.unit".local(),
                        color: DS.Colors.info,
                        icon: "chart.bar.fill"
                    )
                }
            }
        }
    }
    
    private var timeRangePicker: some View {
        Menu {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(range.displayName) {
                    selectedTimeRange = range
                }
            }
        } label: {
            HStack(spacing: DS.Space.xs) {
                Text(selectedTimeRange.displayName)
                    .font(DS.Text.caption)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, DS.Space.sm)
            .padding(.vertical, DS.Space.xs)
            .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
            .cornerRadius(8)
        }
    }
    
    private func statCard(title: String, value: String, subtitle: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            Text(value)
                .font(DS.Text.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(subtitle)
                .font(DS.Text.caption2)
                .foregroundColor(DS.Colors.textTertiary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(DS.Space.sm)
        .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    private var chartsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("statistics.trend".local())
                barChartView
                trendLineView
            }
        }
    }
    
    private var barChartView: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("statistics.daily.distribution.full".local())
                .font(DS.Text.body)
                .fontWeight(.semibold)
            
            if groupedCigarettesByDay.isEmpty {
                StatisticsEmptyStateView(
                    title: "statistics.no.data".local(),
                    subtitle: "statistics.no.data.subtitle".local(),
                    icon: "chart.bar.xaxis"
                )
            } else {
                GeometryReader { geometry in
                    let maxWidth = geometry.size.width
                    let maxCount = groupedCigarettesByDay.map { $0.count }.max() ?? 1
                    let barWidth = max(20.0, min(40.0, maxWidth / Double(groupedCigarettesByDay.count)))
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(groupedCigarettesByDay, id: \.date) { item in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [DS.Colors.cigarette.opacity(0.7), DS.Colors.cigarette]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: barWidth,
                                        height: max(2, CGFloat(item.count) / CGFloat(maxCount) * 100)
                                    )
                                    .animation(DS.Animation.glass, value: item.count)
                                
                                Text(item.date, format: .dateTime.day())
                                    .font(DS.Text.caption2)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                        }
                    }
                    .frame(height: 120)
                }
                .frame(height: 150)
                .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
                .cornerRadius(DS.Size.cardRadiusSmall)
            }
        }
    }
    
    private var trendLineView: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("statistics.weekly.trend.full".local())
                .font(DS.Text.body)
                .fontWeight(.semibold)
            
            if groupedCigarettesByDay.count < 2 {
                StatisticsEmptyStateView(
                    title: "statistics.insufficient.data".local(),
                    subtitle: "statistics.insufficient.data.subtitle".local(),
                    icon: "chart.line.uptrend.xyaxis"
                )
            } else {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                            .fill(DS.Colors.glassSecondary)
                        
                        // Path
                        Path { path in
                            let points = groupedCigarettesByDay.prefix(7)
                            let maxCount = points.map { $0.count }.max() ?? 1
                            for (index, point) in points.enumerated() {
                                let x = CGFloat(index) * (width / CGFloat(max(1, points.count - 1)))
                                let y = height - CGFloat(point.count) / CGFloat(maxCount) * (height - 20)
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [DS.Colors.primary.opacity(0.7), DS.Colors.primary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        
                        ForEach(Array(groupedCigarettesByDay.prefix(7).enumerated()), id: \.element.date) { index, point in
                            let maxCount = groupedCigarettesByDay.prefix(7).map { $0.count }.max() ?? 1
                            let x = CGFloat(index) * (width / CGFloat(max(1, groupedCigarettesByDay.prefix(7).count - 1)))
                            let y = height - CGFloat(point.count) / CGFloat(maxCount) * (height - 20)
                            
                            Circle()
                                .fill(DS.Colors.primary)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                                .animation(DS.Animation.glass, value: point.count)
                        }
                    }
                }
                .frame(height: 150)
            }
        }
    }
    
    private var detailedStatsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("statistics.detailed.statistics".local())
                VStack(spacing: DS.Space.md) {
                    detailStatRow(
                        title: "statistics.best.day".local(),
                        value: highestDay != nil ? "\(highestDay!.count)" : "N/A",
                        date: highestDay?.date,
                        color: DS.Colors.success
                    )
                    detailStatRow(
                        title: "statistics.worst.day".local(),
                        value: lowestDay != nil ? "\(lowestDay!.count)" : "N/A",
                        date: lowestDay?.date,
                        color: DS.Colors.danger
                    )
                    detailStatRow(
                        title: "statistics.analyzed.period".local(),
                        value: "\(groupedCigarettesByDay.count)",
                        color: DS.Colors.info
                    )
                }
            }
        }
    }
    
    private func detailStatRow(title: String, value: String, date: Date? = nil, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(title)
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                if let date = date {
                    Text(date, format: .dateTime.weekday(.wide).day().month())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            Spacer()
            Text(value)
                .font(DS.Text.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, DS.Space.sm)
        .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    // Add this new section
    private var financialSavingsSection: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader("statistics.financial.savings".local())
                
                VStack(spacing: DS.Space.xl) {
                    // Money Spent
                    HStack {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text("statistics.money.spent".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                            
                            Text(formatCurrency(totalSpentInSelectedRange, "USD"))
                                .font(DS.Text.title)
                                .fontWeight(.bold)
                                .foregroundColor(DS.Colors.danger)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DS.Colors.danger)
                    }
                    
                    Divider()
                        .background(DS.Colors.glassQuaternary)
                    
                    // Money Saved
                    HStack {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text("statistics.money.saved".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                            
                            Text(formatCurrency(potentialSavingsInSelectedRange, "USD"))
                                .font(DS.Text.title)
                                .fontWeight(.bold)
                                .foregroundColor(DS.Colors.success)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DS.Colors.success)
                    }
                }
            }
        }
    }
    
    // Add this helper method
    private func formatCurrency(_ amount: Double, _ currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(String(format: "%.2f", amount)) \(currencyCode)"
    }
}

struct StatisticsEmptyStateView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(DS.Colors.textSecondary)
            Text(title.local())
                .font(DS.Text.body)
                .fontWeight(.semibold)
                .foregroundColor(DS.Colors.textPrimary)
            Text(subtitle.local())
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
}

struct EnhancedStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnhancedStatisticsView()
                .modelContainer(for: [Cigarette.self, UserProfile.self], inMemory: true)
        }
    }
}