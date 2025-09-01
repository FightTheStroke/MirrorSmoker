//
//  EnhancedStatisticsView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI
import SwiftData

struct EnhancedStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    @Query private var allTags: [Tag]
    
    @State private var selectedTimeFrame: TimeFrame = .today
    @State private var showingDetailedView = false
    
    enum TimeFrame: String, CaseIterable {
        case today, yesterday, thisWeek, lastWeek, thisMonth
        
        var localizedDescription: String {
            switch self {
            case .today: return NSLocalizedString("statistics.today", comment: "")
            case .yesterday: return NSLocalizedString("statistics.yesterday", comment: "")
            case .thisWeek: return NSLocalizedString("statistics.this.week", comment: "")
            case .lastWeek: return NSLocalizedString("statistics.last.week", comment: "")
            case .thisMonth: return NSLocalizedString("statistics.this.month", comment: "")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                // Header with insights
                DSCard {
                    VStack(spacing: DS.Space.lg) {
                        HStack {
                            VStack(alignment: .leading, spacing: DS.Space.xs) {
                                Text(NSLocalizedString("statistics.title", comment: ""))
                                    .font(DS.Text.title2)
                                    .fontWeight(.bold)
                                
                                Text(selectedTimeFrame.localizedDescription)
                                    .font(DS.Text.caption)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if weeklyTrend != 0 {
                                TrendIndicator(trend: weeklyTrend, label: NSLocalizedString("statistics.vs.last.week", comment: ""))
                            }
                        }
                        
                        // Time frame picker
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { frame in
                                Text(frame.localizedDescription).tag(frame)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Key metrics with circular progress
                DSCard {
                    VStack(spacing: DS.Space.lg) {
                        DSSectionHeader(NSLocalizedString("statistics.overview.today", comment: ""))
                        
                        HStack(spacing: DS.Space.xl) {
                            CircularProgressView(
                                progress: todayProgress,
                                color: DS.Colors.primary,
                                label: NSLocalizedString("statistics.progress.today", comment: ""),
                                value: "\(todaysCount)"
                            )
                            
                            CircularProgressView(
                                progress: weekProgress,
                                color: DS.Colors.success,
                                label: NSLocalizedString("statistics.week.goal", comment: ""),
                                value: "\(Int(weekProgress * 100))%"
                            )
                            
                            CircularProgressView(
                                progress: averageProgress,
                                color: DS.Colors.warning,
                                label: NSLocalizedString("statistics.vs.average", comment: ""),
                                value: String(format: "%.0f%%", averageProgress * 100)
                            )
                        }
                    }
                }

                // Enhanced statistics grid
                DSCard {
                    VStack(spacing: DS.Space.lg) {
                        DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DS.Space.md) {
                            DSHealthCard(
                                title: NSLocalizedString("statistics.total", comment: ""),
                                value: "\(filteredCigarettes.count)",
                                subtitle: NSLocalizedString("cigarettes", comment: ""),
                                icon: "chart.bar.fill",
                                color: DS.Colors.primary,
                                trend: getTrendForTotal()
                            )
                            
                            DSHealthCard(
                                title: NSLocalizedString("statistics.average", comment: ""),
                                value: String(format: "%.1f", averagePerPeriod),
                                subtitle: averageUnit,
                                icon: "chart.line.uptrend.xyaxis",
                                color: DS.Colors.warning,
                                trend: getTrendForAverage()
                            )
                            
                            DSHealthCard(
                                title: NSLocalizedString("statistics.peak.hour", comment: ""),
                                value: peakHour,
                                subtitle: NSLocalizedString("statistics.most.active", comment: ""),
                                icon: "clock.fill",
                                color: DS.Colors.danger,
                                trend: nil
                            )
                            
                            DSHealthCard(
                                title: NSLocalizedString("statistics.most.used.tag", comment: ""),
                                value: mostUsedTag.isEmpty ? NSLocalizedString("statistics.none", comment: "") : mostUsedTag,
                                subtitle: NSLocalizedString("statistics.category", comment: ""),
                                icon: "tag.fill",
                                color: DS.Colors.info,
                                trend: nil
                            )
                        }
                    }
                }

                // Enhanced weekly chart
                if selectedTimeFrame == .thisWeek || selectedTimeFrame == .lastWeek {
                    DSCard {
                        VStack(spacing: DS.Space.lg) {
                            DSSectionHeader(NSLocalizedString("weekly.chart.title", comment: ""))
                            EnhancedWeeklyChart(data: weeklyChartData)
                        }
                    }
                }
                
                // Analisi tag (solo se ci sono)
                if !tagAnalysisData.isEmpty {
                    DSCard {
                        VStack(spacing: DS.Space.sm) {
                            DSSectionHeader(NSLocalizedString("statistics.tag.analysis", comment: ""))
                            ForEach(tagAnalysisData.prefix(6), id: \.tag.id) { item in
                                CleanTagAnalysisRow(item: item)
                            }
                        }
                    }
                }

                // Dettaglio statistiche
                DSCard {
                    VStack(spacing: DS.Space.sm) {
                        DSSectionHeader(NSLocalizedString("statistics.detailed.statistics", comment: ""))
                        
                        if !filteredCigarettes.isEmpty {
                            CleanDetailStatRow(
                                title: NSLocalizedString("statistics.first.cigarette", comment: ""),
                                value: firstCigaretteTime,
                                icon: "sunrise.fill",
                                color: DS.Colors.warning
                            )
                            CleanDetailStatRow(
                                title: NSLocalizedString("statistics.last.cigarette", comment: ""), 
                                value: lastCigaretteTime,
                                icon: "sunset.fill",
                                color: Color.purple
                            )
                            if filteredCigarettes.count > 1 {
                                CleanDetailStatRow(
                                    title: NSLocalizedString("statistics.longest.break", comment: ""),
                                    value: longestBreak,
                                    icon: "timer",
                                    color: DS.Colors.success
                                )
                                CleanDetailStatRow(
                                    title: NSLocalizedString("statistics.average.interval", comment: ""),
                                    value: averageInterval,
                                    icon: "clock",
                                    color: DS.Colors.primary
                                )
                            }
                            CleanDetailStatRow(
                                title: NSLocalizedString("statistics.with.tags", comment: ""),
                                value: "\(cigarettesWithTags) / \(filteredCigarettes.count)",
                                icon: "tag",
                                color: Color.indigo
                            )
                        } else {
                            CleanEmptyStateView()
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.top, DS.Space.md)
        }
        .background(DS.Colors.background)
    }
    
    // MARK: - Computed Properties

    private var filteredCigarettes: [Cigarette] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return cigarettes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let startOfYesterday = calendar.startOfDay(for: yesterday)
            let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
            return cigarettes.filter { $0.timestamp >= startOfYesterday && $0.timestamp < endOfYesterday }
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return cigarettes.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }
        case .lastWeek:
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            let startOfLastWeek = calendar.dateInterval(of: .weekOfYear, for: lastWeek)?.start ?? lastWeek
            let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfLastWeek)!
            return cigarettes.filter { $0.timestamp >= startOfLastWeek && $0.timestamp < endOfLastWeek }
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return cigarettes.filter { $0.timestamp >= startOfMonth && $0.timestamp < endOfMonth }
        }
    }
    
    private var weeklyChartData: [(Date, Int)] {
        let calendar = Calendar.current
        let now = Date()
        var chartData: [(Date, Int)] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let count = cigarettes.filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }.count
            chartData.append((dayStart, count))
        }
        return chartData.reversed()
    }
    
    private var tagAnalysisData: [TagAnalysisItem] {
        var tagCounts: [Tag: Int] = [:]
        for cigarette in filteredCigarettes {
            if let tags = cigarette.tags {
                for tag in tags {
                    tagCounts[tag, default: 0] += 1
                }
            }
        }
        let total = filteredCigarettes.count
        return tagCounts.map { tag, count in
            TagAnalysisItem(
                tag: tag,
                count: count,
                percentage: total > 0 ? (Double(count) / Double(total)) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
    }
    
    private var averagePerPeriod: Double {
        let count = filteredCigarettes.count
        switch selectedTimeFrame {
        case .today, .yesterday: return Double(count)
        case .thisWeek, .lastWeek: return Double(count) / 7.0
        case .thisMonth:
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
            return Double(count) / Double(daysInMonth)
        }
    }
    private var averageUnit: String {
        switch selectedTimeFrame {
        case .today, .yesterday: return NSLocalizedString("statistics.today", comment: "").lowercased()
        case .thisWeek, .lastWeek, .thisMonth: return NSLocalizedString("statistics.per.day", comment: "")
        }
    }
    private var peakHour: String {
        var hourCounts = Array(repeating: 0, count: 24)
        for cigarette in filteredCigarettes {
            let hour = Calendar.current.component(.hour, from: cigarette.timestamp)
            hourCounts[hour] += 1
        }
        guard let maxIndex = hourCounts.enumerated().max(by: { $0.element < $1.element })?.offset,
              hourCounts[maxIndex] > 0 else { return NSLocalizedString("statistics.none", comment: "") }
        return "\(maxIndex):00"
    }
    private var mostUsedTag: String { tagAnalysisData.first?.tag.name ?? "" }
    private var firstCigaretteTime: String {
        guard let first = filteredCigarettes.min(by: { $0.timestamp < $1.timestamp }) else {
            return NSLocalizedString("statistics.none", comment: "")
        }
        return DateFormatter.timeOnly.string(from: first.timestamp)
    }
    private var lastCigaretteTime: String {
        guard let last = filteredCigarettes.max(by: { $0.timestamp < $1.timestamp }) else {
            return NSLocalizedString("statistics.none", comment: "")
        }
        return DateFormatter.timeOnly.string(from: last.timestamp)
    }
    private var longestBreak: String {
        guard filteredCigarettes.count > 1 else { return "N/A" }
        let sortedCigarettes = filteredCigarettes.sorted { $0.timestamp < $1.timestamp }
        var maxInterval: TimeInterval = 0
        for i in 1..<sortedCigarettes.count {
            let interval = sortedCigarettes[i].timestamp.timeIntervalSince(sortedCigarettes[i-1].timestamp)
            maxInterval = max(maxInterval, interval)
        }
        return formatTimeInterval(maxInterval)
    }
    private var averageInterval: String {
        guard filteredCigarettes.count > 1 else { return "N/A" }
        let sortedCigarettes = filteredCigarettes.sorted { $0.timestamp < $1.timestamp }
        var totalInterval: TimeInterval = 0
        for i in 1..<sortedCigarettes.count {
            let interval = sortedCigarettes[i].timestamp.timeIntervalSince(sortedCigarettes[i-1].timestamp)
            totalInterval += interval
        }
        let averageInterval = totalInterval / Double(sortedCigarettes.count - 1)
        return formatTimeInterval(averageInterval)
    }
    private var cigarettesWithTags: Int {
        filteredCigarettes.filter { cigarette in
            cigarette.tags?.isEmpty == false
        }.count
    }
    
    // MARK: - New Progress Properties
    
    private var todaysCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }.count
    }
    
    private var todayProgress: Double {
        let count = Double(todaysCount)
        let maxExpected = 20.0 // Adjust based on user profile or average
        return min(1.0, count / maxExpected)
    }
    
    private var weekProgress: Double {
        let weeklyGoal = 50.0 // This should come from user settings
        let currentWeekCount = Double(thisWeekCount)
        return min(1.0, currentWeekCount / weeklyGoal)
    }
    
    private var thisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
        
        return cigarettes.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }.count
    }
    
    private var averageProgress: Double {
        guard !cigarettes.isEmpty else { return 0.0 }
        
        let totalDays = 30.0 // Calculate over last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCigarettes = cigarettes.filter { $0.timestamp >= thirtyDaysAgo }
        
        let dailyAverage = Double(recentCigarettes.count) / totalDays
        let todayCount = Double(todaysCount)
        
        guard dailyAverage > 0 else { return todayCount > 0 ? 1.0 : 0.0 }
        return min(2.0, todayCount / dailyAverage) / 2.0
    }
    
    private var weeklyTrend: Double {
        let thisWeek = Double(thisWeekCount)
        let lastWeek = Double(lastWeekCount)
        
        guard lastWeek > 0 else { return 0.0 }
        return (thisWeek - lastWeek) / lastWeek
    }
    
    private var lastWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let startOfLastWeek = calendar.dateInterval(of: .weekOfYear, for: lastWeek)?.start ?? lastWeek
        let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfLastWeek)!
        
        return cigarettes.filter { $0.timestamp >= startOfLastWeek && $0.timestamp < endOfLastWeek }.count
    }
    
    private func getTrendForTotal() -> DSHealthCard.TrendDirection? {
        let trend = weeklyTrend
        if trend > 0.1 { return .up }
        if trend < -0.1 { return .down }
        return .stable
    }
    
    private func getTrendForAverage() -> DSHealthCard.TrendDirection? {
        return getTrendForTotal()
    }
    
    // MARK: - Helper Functions
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TagAnalysisItem {
    let tag: Tag
    let count: Int
    let percentage: Double
}

// MARK: - Minified views coerenti

struct CleanTagAnalysisRow: View {
    let item: TagAnalysisItem
    var body: some View {
        HStack(spacing: DS.Space.md) {
            Circle()
                .fill(item.tag.color)
                .frame(width: 16, height: 16)
            Text(item.tag.name)
                .font(DS.Text.body)
                .fontWeight(.medium)
            Spacer()
            Text("\(item.count)").font(DS.Text.caption).fontWeight(.semibold)
            Text("\(item.percentage, specifier: "%.0f")%")
                .fontWeight(.semibold)
        }
        .padding(.vertical, DS.Space.xs)
    }
}

struct CleanDetailStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.system(size: DS.Size.iconSize))
                .foregroundStyle(color)
                .frame(width: 28, alignment: .center)
            Text(title)
                .font(DS.Text.body)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(DS.Text.body)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .padding(.vertical, DS.Space.sm)
        .padding(.horizontal, DS.Space.md)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(DS.Size.buttonRadius)
    }
}

struct CleanEmptyStateView: View {
    var body: some View {
        VStack(spacing: DS.Space.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(DS.Colors.textSecondary)
            Text(NSLocalizedString("statistics.none", comment: ""))
                .font(DS.Text.body)
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .padding(.vertical, DS.Space.xl)
    }
}

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    NavigationView {
        EnhancedStatisticsView()
            .modelContainer(for: [Cigarette.self, Tag.self], inMemory: true)
    }
}
