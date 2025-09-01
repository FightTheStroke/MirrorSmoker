//
//  EnhancedStatisticsView.swift
//  MirrorSmokerStopper
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct EnhancedStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    @Query private var allTags: [Tag]
    
    @State private var selectedTimeFrame: TimeFrame = .today
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case yesterday = "Yesterday" 
        case thisWeek = "This Week"
        case lastWeek = "Last Week"
        case thisMonth = "This Month"
        
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
            VStack(spacing: 24) {
                // Time Frame Picker
                timeFramePicker
                
                // Quick Stats Overview
                quickStatsGrid
                
                // Weekly Chart (only for weekly views)
                if selectedTimeFrame == .thisWeek || selectedTimeFrame == .lastWeek {
                    WeeklyChart(weeklyStats: weeklyChartData)
                }
                
                // Tag Analysis (only if there are tagged cigarettes)
                if !tagAnalysisData.isEmpty {
                    tagAnalysisSection
                }
                
                // Detailed Statistics
                detailedStatsSection
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("statistics.title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Time Frame Picker
    
    private var timeFramePicker: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("statistics.analyze.period", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { frame in
                    Text(frame.localizedDescription).tag(frame)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: NSLocalizedString("statistics.total", comment: ""),
                value: "\(filteredCigarettes.count)",
                subtitle: NSLocalizedString("cigarettes", comment: ""),
                color: .blue,
                icon: "cigarette"
            )
            
            StatCard(
                title: NSLocalizedString("statistics.average", comment: ""),
                value: String(format: "%.1f", averagePerPeriod),
                subtitle: averageUnit,
                color: .orange,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            StatCard(
                title: NSLocalizedString("statistics.peak.hour", comment: ""),
                value: peakHour,
                subtitle: NSLocalizedString("statistics.most.active", comment: ""),
                color: .red,
                icon: "clock"
            )
            
            StatCard(
                title: NSLocalizedString("statistics.most.used.tag", comment: ""),
                value: mostUsedTag.isEmpty ? NSLocalizedString("statistics.none", comment: "") : mostUsedTag,
                subtitle: NSLocalizedString("statistics.category", comment: ""),
                color: .green,
                icon: "tag"
            )
        }
    }
    
    // MARK: - Tag Analysis Section
    
    private var tagAnalysisSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("statistics.tag.analysis", comment: ""))
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(tagAnalysisData.prefix(5), id: \.tag.id) { item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(item.tag.color)
                            .frame(width: 16, height: 16)
                        
                        Text(item.tag.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(item.count)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("\(item.percentage, specifier: "%.0f")%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Progress indicator
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.tag.color.opacity(0.3))
                            .frame(width: 40, height: 8)
                            .overlay(
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(item.tag.color)
                                        .frame(width: geometry.size.width * (item.percentage / 100))
                                }
                            )
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Detailed Stats Section
    
    private var detailedStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("statistics.detailed.statistics", comment: ""))
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if !filteredCigarettes.isEmpty {
                    DetailStatRow(
                        title: NSLocalizedString("statistics.first.cigarette", comment: ""),
                        value: firstCigaretteTime,
                        icon: "sunrise.fill",
                        color: .orange
                    )
                    
                    DetailStatRow(
                        title: NSLocalizedString("statistics.last.cigarette", comment: ""), 
                        value: lastCigaretteTime,
                        icon: "sunset.fill",
                        color: .purple
                    )
                    
                    if filteredCigarettes.count > 1 {
                        DetailStatRow(
                            title: NSLocalizedString("statistics.longest.break", comment: ""),
                            value: longestBreak,
                            icon: "timer",
                            color: .green
                        )
                        
                        DetailStatRow(
                            title: NSLocalizedString("statistics.average.interval", comment: ""),
                            value: averageInterval,
                            icon: "clock",
                            color: .blue
                        )
                    }
                    
                    DetailStatRow(
                        title: NSLocalizedString("statistics.with.tags", comment: ""),
                        value: "\(cigarettesWithTags) / \(filteredCigarettes.count)",
                        icon: "tag",
                        color: .indigo
                    )
                } else {
                    Text(NSLocalizedString("statistics.none", comment: ""))
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
            
            let count = cigarettes.filter { cigarette in
                cigarette.timestamp >= dayStart && cigarette.timestamp < dayEnd
            }.count
            
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
        case .today, .yesterday:
            return Double(count)
        case .thisWeek, .lastWeek:
            return Double(count) / 7.0
        case .thisMonth:
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
            return Double(count) / Double(daysInMonth)
        }
    }
    
    private var averageUnit: String {
        switch selectedTimeFrame {
        case .today, .yesterday:
            return NSLocalizedString("statistics.today", comment: "").lowercased()
        case .thisWeek, .lastWeek:
            return NSLocalizedString("statistics.per.day", comment: "")
        case .thisMonth:
            return NSLocalizedString("statistics.per.day", comment: "")
        }
    }
    
    private var peakHour: String {
        var hourCounts = Array(repeating: 0, count: 24)
        
        for cigarette in filteredCigarettes {
            let hour = Calendar.current.component(.hour, from: cigarette.timestamp)
            hourCounts[hour] += 1
        }
        
        guard let maxIndex = hourCounts.enumerated().max(by: { $0.element < $1.element })?.offset,
              hourCounts[maxIndex] > 0 else {
            return NSLocalizedString("statistics.none", comment: "")
        }
        
        return "\(maxIndex):00"
    }
    
    private var mostUsedTag: String {
        tagAnalysisData.first?.tag.name ?? ""
    }
    
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

// MARK: - StatCard with Icon

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Data Models

struct TagAnalysisItem {
    let tag: Tag
    let count: Int
    let percentage: Double
}

struct DetailStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Extensions

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