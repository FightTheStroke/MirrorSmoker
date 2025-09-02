import SwiftUI
import SwiftData

struct EnhancedStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    
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
                return NSLocalizedString("time.range.today", comment: "")
            case .yesterday:
                return NSLocalizedString("time.range.yesterday", comment: "")
            case .week:
                return NSLocalizedString("time.range.week", comment: "")
            case .month:
                return NSLocalizedString("time.range.month", comment: "")
            case .all:
                return NSLocalizedString("time.range.all", comment: "")
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                todayOverviewSection
                statisticsSection
                chartsSection
                detailedStatsSection
            }
            .padding(DS.Space.lg)
        }
        .background(DS.Colors.background)
        .navigationTitle(NSLocalizedString("statistics.title.main", comment: ""))
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var todayOverviewSection: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader(NSLocalizedString("statistics.todays.overview", comment: ""))
                
                HStack(spacing: DS.Space.xl) {
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text(NSLocalizedString("statistics.today.label", comment: ""))
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                            Text("\(todayCount)")
                                .font(DS.Text.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(colorForTodayCount)
                            
                            Text("/ \(todayTarget)")
                                .font(DS.Text.title3)
                                .fontWeight(.medium)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                        
                        Text(todayCount == 1 ? NSLocalizedString("statistics.today.single", comment: "") : NSLocalizedString("statistics.today.plural", comment: ""))
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(DS.Colors.backgroundSecondary, lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0.0, to: min(1.0, Double(todayCount) / Double(max(1, todayTarget))))
                            .stroke(colorForTodayCount, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
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
                Text(NSLocalizedString("statistics.no.cigarettes.today.full", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.success)
            } else if todayCount <= target {
                Text(NSLocalizedString("statistics.following.plan.full", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.warning)
            } else {
                Text(NSLocalizedString("statistics.exceeded.goal.full", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.danger)
            }
        }
    }
    
    private var statisticsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                HStack {
                    DSSectionHeader(NSLocalizedString("statistics.title", comment: ""))
                    Spacer()
                    timeRangePicker
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DS.Space.md) {
                    statCard(
                        title: NSLocalizedString("statistics.total", comment: ""),
                        value: "\(cigarettesForSelectedRange.count)",
                        subtitle: NSLocalizedString("statistics.cigarettes.unit", comment: ""),
                        color: DS.Colors.primary,
                        icon: "lungs.fill"
                    )
                    
                    statCard(
                        title: NSLocalizedString("statistics.average.per.day", comment: ""),
                        value: String(format: "%.1f", averagePerDaySelectedRange),
                        subtitle: NSLocalizedString("statistics.cigarettes.unit", comment: ""),
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
            .background(DS.Colors.backgroundSecondary)
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
        .background(DS.Colors.backgroundSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    private var chartsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("statistics.trend", comment: ""))
                barChartView
                trendLineView
            }
        }
    }
    
    private var barChartView: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(NSLocalizedString("statistics.daily.distribution.full", comment: ""))
                .font(DS.Text.body)
                .fontWeight(.semibold)
            
            if groupedCigarettesByDay.isEmpty {
                StatisticsEmptyStateView(
                    title: NSLocalizedString("statistics.no.data", comment: ""),
                    subtitle: NSLocalizedString("statistics.no.data.subtitle", comment: ""),
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
                                    .fill(DS.Colors.cigarette)
                                    .frame(
                                        width: barWidth,
                                        height: max(2, CGFloat(item.count) / CGFloat(maxCount) * 100)
                                    )
                                Text(item.date, format: .dateTime.day())
                                    .font(DS.Text.caption2)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                        }
                    }
                    .frame(height: 120)
                }
                .frame(height: 150)
            }
        }
    }
    
    private var trendLineView: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(NSLocalizedString("statistics.weekly.trend.full", comment: ""))
                .font(DS.Text.body)
                .fontWeight(.semibold)
            
            if groupedCigarettesByDay.count < 2 {
                StatisticsEmptyStateView(
                    title: NSLocalizedString("statistics.insufficient.data", comment: ""),
                    subtitle: NSLocalizedString("statistics.insufficient.data.subtitle", comment: ""),
                    icon: "chart.line.uptrend.xyaxis"
                )
            } else {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
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
                    .stroke(DS.Colors.primary, lineWidth: 3)
                    
                    ForEach(Array(groupedCigarettesByDay.prefix(7).enumerated()), id: \.element.date) { index, point in
                        let maxCount = groupedCigarettesByDay.prefix(7).map { $0.count }.max() ?? 1
                        let x = CGFloat(index) * (width / CGFloat(max(1, groupedCigarettesByDay.prefix(7).count - 1)))
                        let y = height - CGFloat(point.count) / CGFloat(maxCount) * (height - 20)
                        
                        Circle()
                            .fill(DS.Colors.primary)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: 150)
            }
        }
    }
    
    private var detailedStatsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("statistics.detailed.statistics", comment: ""))
                VStack(spacing: DS.Space.md) {
                    detailStatRow(
                        title: NSLocalizedString("statistics.best.day", comment: ""),
                        value: highestDay != nil ? "\(highestDay!.count) \(NSLocalizedString("statistics.cigarettes.unit", comment: ""))" : "N/A",
                        date: highestDay?.date,
                        color: DS.Colors.success
                    )
                    detailStatRow(
                        title: NSLocalizedString("statistics.worst.day", comment: ""),
                        value: lowestDay != nil ? "\(lowestDay!.count) \(NSLocalizedString("statistics.cigarettes.unit", comment: ""))" : "N/A",
                        date: lowestDay?.date,
                        color: DS.Colors.danger
                    )
                    detailStatRow(
                        title: NSLocalizedString("statistics.analyzed.period", comment: ""),
                        value: String(format: NSLocalizedString("statistics.days.count", comment: ""), groupedCigarettesByDay.count),
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
            Text(title)
                .font(DS.Text.body)
                .fontWeight(.semibold)
                .foregroundColor(DS.Colors.textPrimary)
            Text(subtitle)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
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