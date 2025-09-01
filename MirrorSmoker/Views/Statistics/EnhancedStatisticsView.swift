//
//  EnhancedStatisticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct EnhancedStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cigarettes: [Cigarette]
    @Query private var allTags: [Tag]
    
    @State private var selectedTimeFrame: TimeFrame = .today
    @State private var selectedHourRange: HourRange?
    @State private var showingTagSelector = false
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case yesterday = "Yesterday" 
        case thisWeek = "This Week"
        case lastWeek = "Last Week"
        case thisMonth = "This Month"
        
        var localizedDescription: String {
            switch self {
            case .today:
                return NSLocalizedString("statistics.today", comment: "")
            case .yesterday:
                return NSLocalizedString("statistics.yesterday", comment: "")
            case .thisWeek:
                return NSLocalizedString("statistics.this.week", comment: "")
            case .lastWeek:
                return NSLocalizedString("statistics.last.week", comment: "")
            case .thisMonth:
                return NSLocalizedString("statistics.this.month", comment: "")
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
                
                // Interactive Hourly Chart
                if !filteredCigarettes.isEmpty {
                    hourlyAnalysisSection
                }
                
                // Tag Analysis
                if !tagAnalysisData.isEmpty {
                    tagAnalysisSection
                }
                
                // Peak Hours Analysis
                peakHoursSection
                
                // Weekly Pattern
                if selectedTimeFrame == .thisWeek || selectedTimeFrame == .lastWeek {
                    weeklyPatternSection
                }
                
                // Detailed Statistics
                detailedStatsSection
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("statistics.title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingTagSelector) {
            if let hourRange = selectedHourRange {
                TagSelectorForTimeSheet(
                    hourRange: hourRange,
                    selectedDate: currentSelectedDate,
                    onTagSelected: { tag in
                        addTagToTimeRange(tag: tag, hourRange: hourRange)
                    }
                )
            }
        }
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
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    // MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            StatCard(
                title: NSLocalizedString("statistics.total", comment: ""),
                value: "\(filteredCigarettes.count)",
                subtitle: NSLocalizedString("cigarettes", comment: ""),
                color: .blue
            )
            
            StatCard(
                title: NSLocalizedString("statistics.average", comment: ""),
                value: String(format: "%.1f", averagePerPeriod),
                subtitle: averageUnit,
                color: .orange
            )
            
            StatCard(
                title: NSLocalizedString("statistics.peak.hour", comment: ""),
                value: peakHour,
                subtitle: NSLocalizedString("statistics.most.active", comment: ""),
                color: .red
            )
            
            StatCard(
                title: NSLocalizedString("statistics.most.used.tag", comment: ""),
                value: mostUsedTag.isEmpty ? NSLocalizedString("statistics.none", comment: "") : mostUsedTag,
                subtitle: NSLocalizedString("statistics.category", comment: ""),
                color: .green
            )
        }
    }
    
    // MARK: - Hourly Analysis Section
    
    private var hourlyAnalysisSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("statistics.hourly.distribution", comment: ""))
                    .font(.headline)
                
                Spacer()
                
                Text(NSLocalizedString("statistics.tap.bars", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            InteractiveHourlyChart(
                data: hourlyDistributionData,
                selectedDate: currentSelectedDate,
                onHourSelected: { hour in
                    let startHour = hour
                    let endHour = (hour + 1) % 24
                    selectedHourRange = HourRange(start: startHour, end: endHour)
                    showingTagSelector = true
                }
            )
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    // MARK: - Tag Analysis Section
    
    private var tagAnalysisSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("statistics.tag.analysis", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(tagAnalysisData.prefix(5), id: \.tag.id) { item in
                HStack {
                    Circle()
                        .fill(item.tag.color)
                        .frame(width: 12, height: 12)
                    
                    Text(item.tag.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(item.count)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(item.percentage, specifier: "%.0f")%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress bar
                    ProgressView(value: Double(item.count), total: Double(filteredCigarettes.count))
                        .frame(width: 60)
                        .tint(item.tag.color)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(AppColors.systemGray6)
        .clipped()
        .cornerRadius(12)
    }
    
    // MARK: - Peak Hours Section
    
    private var peakHoursSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("statistics.peak.hours.analysis", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(topPeakHours.prefix(3), id: \.hour) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(item.hour):00 - \(item.hour + 1):00")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(timeLabel(for: item.hour))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(item.count)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(colorForHourIntensity(item.count))
                            
                            Text(NSLocalizedString("cigarettes", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    // MARK: - Weekly Pattern Section
    
    private var weeklyPatternSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("statistics.weekly.pattern", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach(weeklyPatternData, id: \.day) { item in
                    VStack(spacing: 8) {
                        Text(item.dayAbbr)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(colorForDayIntensity(item.count))
                            .frame(height: max(CGFloat(item.count) * 4, 4))
                            .frame(maxHeight: 80)
                            .cornerRadius(4)
                        
                        Text("\(item.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    // MARK: - Detailed Stats Section
    
    private var detailedStatsSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("statistics.detailed.statistics", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
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
                
                if !filteredCigarettes.isEmpty {
                    DetailStatRow(
                        title: NSLocalizedString("statistics.with.tags", comment: ""),
                        value: "\(cigarettesWithTags) of \(filteredCigarettes.count)",
                        icon: "tag",
                        color: .indigo
                    )
                }
            }
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var currentSelectedDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .today:
            return now
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        case .thisWeek:
            return now
        case .lastWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .thisMonth:
            return now
        }
    }
    
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
    
    private var hourlyDistributionData: [HourlyData] {
        var hourCounts = Array(repeating: 0, count: 24)
        
        for cigarette in filteredCigarettes {
            let hour = Calendar.current.component(.hour, from: cigarette.timestamp)
            hourCounts[hour] += 1
        }
        
        return hourCounts.enumerated().map { 
            HourlyData(hour: $0.offset, count: $0.element)
        }
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
    
    private var topPeakHours: [HourlyData] {
        hourlyDistributionData
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }
    
    private var weeklyPatternData: [WeeklyData] {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let weekdayAbbr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var dayCounts = Array(repeating: 0, count: 7)
        
        for cigarette in filteredCigarettes {
            let weekday = Calendar.current.component(.weekday, from: cigarette.timestamp)
            let adjustedWeekday = (weekday + 5) % 7 // Convert Sunday=1 to Monday=0
            dayCounts[adjustedWeekday] += 1
        }
        
        return zip(zip(weekdays, weekdayAbbr), dayCounts).map { dayData, count in
            WeeklyData(day: dayData.0, dayAbbr: dayData.1, count: count)
        }
    }
    
    private var averagePerPeriod: Double {
        let count = filteredCigarettes.count
        switch selectedTimeFrame {
        case .today, .yesterday:
            return Double(count)
        case .thisWeek, .lastWeek:
            return Double(count) / 7.0
        case .thisMonth:
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: currentSelectedDate)?.count ?? 30
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
        guard let peak = topPeakHours.first else { return NSLocalizedString("statistics.none", comment: "") }
        return "\(peak.hour):00"
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
    
    private func timeLabel(for hour: Int) -> String {
        switch hour {
        case 6..<12:
            return NSLocalizedString("statistics.morning", comment: "")
        case 12..<17:
            return NSLocalizedString("statistics.afternoon", comment: "")
        case 17..<21:
            return NSLocalizedString("statistics.evening", comment: "")
        default:
            return NSLocalizedString("statistics.night", comment: "")
        }
    }
    
    private func colorForHourIntensity(_ count: Int) -> Color {
        switch count {
        case 0:
            return .gray
        case 1...2:
            return .green
        case 3...5:
            return .orange
        default:
            return .red
        }
    }
    
    private func colorForDayIntensity(_ count: Int) -> Color {
        switch count {
        case 0:
            return .gray.opacity(0.3)
        case 1...5:
            return .green
        case 6...10:
            return .orange
        default:
            return .red
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func addTagToTimeRange(tag: Tag, hourRange: HourRange) {
        // Find cigarettes in the specified hour range for the selected date
        let calendar = Calendar.current
        let startOfSelectedDay = calendar.startOfDay(for: currentSelectedDate)
        
        let startTime = calendar.date(byAdding: .hour, value: hourRange.start, to: startOfSelectedDay)!
        let endTime = calendar.date(byAdding: .hour, value: hourRange.end, to: startOfSelectedDay)!
        
        let cigarettesInRange = cigarettes.filter { cigarette in
            cigarette.timestamp >= startTime && cigarette.timestamp < endTime
        }
        
        // Add the tag to all cigarettes in this time range that don't already have it
        for cigarette in cigarettesInRange {
            var currentTags = cigarette.tags ?? []
            if !currentTags.contains(where: { $0.id == tag.id }) {
                currentTags.append(tag)
                cigarette.tags = currentTags
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving tag updates: \(error)")
        }
    }
}

// MARK: - Data Models

struct HourlyData {
    let hour: Int
    let count: Int
}

struct TagAnalysisItem {
    let tag: Tag
    let count: Int
    let percentage: Double
}

struct WeeklyData {
    let day: String
    let dayAbbr: String
    let count: Int
}

struct DetailStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
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