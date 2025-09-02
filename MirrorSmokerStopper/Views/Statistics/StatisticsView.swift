//
//  StatisticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @Query private var userProfiles: [UserProfile]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingHistory = false
    
    // Optimized queries with predicates
    private var todayPredicate: Predicate<Cigarette> {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }
    }
    
    private var last30DaysPredicate: Predicate<Cigarette> {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= thirtyDaysAgo
        }
    }
    
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
    
    // MARK: - Computed Properties for Selected Time Range
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
                return nil // No filter
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
    
    private var averagePerDay: Double {
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
    
    // MARK: - Today's Overview Data (optimized with predicate)
    private var todaysCigarettes: [Cigarette] {
        DateQueryHelpers.fetchCigarettesSafely(
            with: DateQueryHelpers.todayPredicate(),
            from: modelContext,
            fallback: allCigarettes.filter { cigarette in
                let today = DateQueryHelpers.startOfDay()
                let tomorrow = DateQueryHelpers.endOfDay()
                return cigarette.timestamp >= today && cigarette.timestamp < tomorrow
            }
        )
    }
    
    private var todayCount: Int {
        todaysCigarettes.count
    }
    
    private var dailyAverage: Double {
        let recentCigarettes = DateQueryHelpers.fetchCigarettesSafely(
            with: DateQueryHelpers.last30DaysPredicate(),
            from: modelContext,
            fallback: allCigarettes.filter { $0.timestamp >= DateQueryHelpers.thirtyDaysAgo() }
        )
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
                // Today's Overview Section (moved to top)
                todayOverviewSection
                
                // Statistics Section (renamed from Quick Stats)
                statisticsSection
                
                // Charts Section
                chartsSection
                
                // Detailed Stats Section
                detailedStatsSection
            }
            .padding(DS.Space.lg)
        }
        .background(DS.Colors.background)
        .navigationTitle(NSLocalizedString("statistics.title.main", comment: ""))
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Today's Overview Section (moved to top)
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
                    
                    // Progress visualization
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
                
                // Status message
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
    
    // MARK: - Statistics Section (renamed from Quick Stats)
    private var statisticsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                // Integrated time range filters in the header
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
                        value: String(format: "%.1f", averagePerDay),
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
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("statistics.trend", comment: ""))
                
                // Bar Chart
                barChartView
                
                // Trend Line
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
                EmptyStateView(
                    title: NSLocalizedString("statistics.no.data", comment: ""),
                    subtitle: NSLocalizedString("statistics.no.data.subtitle", comment: ""),
                    icon: "chart.bar.xaxis"
                )
            } else {
                // Simple bar chart implementation
                GeometryReader { geometry in
                    let maxWidth = geometry.size.width
                    let maxCount = groupedCigarettesByDay.map { $0.count }.max() ?? 1
                    let barWidth = max(20.0, min(40.0, maxWidth / Double(groupedCigarettesByDay.count)))
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(groupedCigarettesByDay, id: \.date) { item in
                            VStack(spacing: 4) {
                                // Bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(DS.Colors.cigarette)
                                    .frame(
                                        width: barWidth,
                                        height: max(2, CGFloat(item.count) / CGFloat(maxCount) * 100)
                                    )
                                
                                // Date label
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
                EmptyStateView(
                    title: NSLocalizedString("statistics.insufficient.data", comment: ""),
                    subtitle: NSLocalizedString("statistics.insufficient.data.subtitle", comment: ""),
                    icon: "chart.line.uptrend.xyaxis"
                )
            } else {
                // Simple trend visualization
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    Path { path in
                        let points = groupedCigarettesByDay.prefix(7) // Last 7 days
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
                    
                    // Data points
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
    
    // MARK: - Detailed Stats Section
    private var detailedStatsSection: some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                DSSectionHeader(NSLocalizedString("statistics.detailed.statistics", comment: ""))
                
                VStack(spacing: DS.Space.md) {
                    detailStatRow(
                        title: NSLocalizedString("statistics.best.day", comment: ""),
                        value: highestDay != nil ? String(format: NSLocalizedString("statistics.cigarettes.count", comment: ""), highestDay!.count) : "N/A",
                        date: highestDay?.date,
                        color: DS.Colors.success
                    )
                    
                    detailStatRow(
                        title: NSLocalizedString("statistics.worst.day", comment: ""),
                        value: lowestDay != nil ? String(format: NSLocalizedString("statistics.cigarettes.count", comment: ""), lowestDay!.count) : "N/A",
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

// MARK: - Supporting Views
struct EmptyStateView: View {
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

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatisticsView()
                .modelContainer(for: [Cigarette.self, UserProfile.self], inMemory: true)
        }
    }
}
