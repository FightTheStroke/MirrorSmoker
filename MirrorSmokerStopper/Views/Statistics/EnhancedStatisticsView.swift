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
                // Titolo grande coerente con Apple style
                HStack {
                    Text(NSLocalizedString("statistics.title", comment: ""))
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 6)
                    Spacer()
                }

                // Selettore periodo
                DSCard {
                    VStack(spacing: DS.Space.sm) {
                        DSSectionHeader(NSLocalizedString("statistics.analyze.period", comment: ""))
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { frame in
                                Text(frame.localizedDescription).tag(frame)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Griglia statistiche rapide
                DSCard {
                    VStack(spacing: DS.Space.sm) {
                        DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DS.Space.md) {
                            DSStatCard(
                                title: NSLocalizedString("statistics.total", comment: ""),
                                value: "\(filteredCigarettes.count)",
                                subtitle: NSLocalizedString("cigarettes", comment: ""),
                                color: DS.Colors.primary,
                                icon: "chart.bar.fill"
                            )
                            
                            DSStatCard(
                                title: NSLocalizedString("statistics.average", comment: ""),
                                value: String(format: "%.1f", averagePerPeriod),
                                subtitle: averageUnit,
                                color: DS.Colors.warning,
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            
                            DSStatCard(
                                title: NSLocalizedString("statistics.peak.hour", comment: ""),
                                value: peakHour,
                                subtitle: NSLocalizedString("statistics.most.active", comment: ""),
                                color: DS.Colors.danger,
                                icon: "clock.fill"
                            )
                            
                            DSStatCard(
                                title: NSLocalizedString("statistics.most.used.tag", comment: ""),
                                value: mostUsedTag.isEmpty ? NSLocalizedString("statistics.none", comment: "") : mostUsedTag,
                                subtitle: NSLocalizedString("statistics.category", comment: ""),
                                color: DS.Colors.success,
                                icon: "tag.fill"
                            )
                        }
                    }
                }

                // Grafico settimanale, solo per vista settimanale
                if selectedTimeFrame == .thisWeek || selectedTimeFrame == .lastWeek {
                    DSCard {
                        VStack(spacing: DS.Space.sm) {
                            DSSectionHeader(NSLocalizedString("weekly.chart.title", comment: ""))
                            WeeklyChart(weeklyStats: weeklyChartData)
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
