//
//  WeeklyStatsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct WeeklyStatsView: View {
    @Environment(\.dismiss) private var dismiss
    let cigarettes: [Cigarette]
    
    private var weeklyData: [(weekStart: Date, total: Int, daily: [Int])] {
        let calendar = Calendar.current
        let now = Date()
        
        var weeks: [(weekStart: Date, total: Int, daily: [Int])] = []
        
        for weekOffset in 0..<4 {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now)!)?.start ?? now
            
            var dailyCount: [Int] = []
            var weekTotal = 0
            
            for dayOffset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: day)!
                
                let count = cigarettes.filter { cigarette in
                    cigarette.timestamp >= day && cigarette.timestamp < dayEnd
                }.count
                
                dailyCount.append(count)
                weekTotal += count
            }
            
            weeks.append((weekStart: weekStart, total: weekTotal, daily: dailyCount))
        }
        
        return weeks.reversed()
    }
    
    private var maxDailyCount: Int {
        let maxCount = weeklyData.flatMap { $0.daily }.max() ?? 0
        return max(maxCount, 1) // Ensure it's never 0 to prevent division by zero
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section with summary cards
                    headerSection
                    
                    // Weekly charts
                    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, week in
                        weeklyChartSection(week: week, index: index)
                    }
                    
                    // Trend analysis
                    if weeklyData.count >= 2 {
                        trendAnalysisSection
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("weekly.stats.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("weekly.stats.last.4.weeks", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                let totalLast4Weeks = weeklyData.reduce(0) { $0 + $1.total }
                let averagePerWeek = totalLast4Weeks / 4
                
                WeeklyStatCard(
                    title: NSLocalizedString("weekly.stats.total.4.weeks", comment: ""),
                    value: "\(totalLast4Weeks)",
                    subtitle: NSLocalizedString("cigarettes", comment: ""),
                    color: .red
                )
                
                WeeklyStatCard(
                    title: NSLocalizedString("weekly.stats.average.weekly", comment: ""),
                    value: "\(averagePerWeek)",
                    subtitle: NSLocalizedString("weekly.stats.per.week", comment: ""),
                    color: .blue
                )
            }
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(16)
    }
    
    private func weeklyChartSection(week: (weekStart: Date, total: Int, daily: [Int]), index: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(weekTitle(for: week.weekStart, index: index))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(String(format: NSLocalizedString("weekly.stats.total.cigarettes", comment: ""), week.total))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(String(format: NSLocalizedString("weekly.stats.average.format", comment: ""), week.total / 7))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    let count = week.daily[dayIndex]
                    let dayDate = Calendar.current.date(byAdding: .day, value: dayIndex, to: week.weekStart)!
                    
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(barColor(for: count))
                            .frame(height: max(min(CGFloat(count) * 60.0 / CGFloat(maxDailyCount), 60), count > 0 ? 4 : 2))
                            .cornerRadius(2)
                        
                        Text(dayDate, format: .dateTime.weekday(.abbreviated))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .frame(height: 100)
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(12)
    }
    
    private var trendAnalysisSection: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("weekly.stats.trend.analysis", comment: ""))
                .font(.headline)
                .fontWeight(.semibold)
            
            let thisWeek = weeklyData.last?.total ?? 0
            let lastWeek = weeklyData.dropLast().last?.total ?? 0
            let difference = thisWeek - lastWeek
            
            HStack {
                Image(systemName: difference < 0 ? "arrow.down.circle.fill" : difference > 0 ? "arrow.up.circle.fill" : "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(difference < 0 ? .green : difference > 0 ? .red : .blue)
                
                VStack(alignment: .leading) {
                    Text(difference == 0 ? NSLocalizedString("weekly.stats.no.change", comment: "") : difference < 0 ? NSLocalizedString("weekly.stats.improvement", comment: "") : NSLocalizedString("weekly.stats.worsening", comment: ""))
                        .font(.headline)
                        .foregroundColor(difference < 0 ? .green : difference > 0 ? .red : .blue)
                    
                    Text(difference == 0 ? 
                         NSLocalizedString("weekly.stats.same.as.last.week", comment: "") : 
                         String(format: NSLocalizedString("weekly.stats.difference.format", comment: ""), abs(difference), difference < 0 ? NSLocalizedString("weekly.stats.less", comment: "") : NSLocalizedString("weekly.stats.more", comment: "")))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .padding()
        .background(AppColors.systemGray6)
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func weekTitle(for date: Date, index: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        switch index {
        case 3: return NSLocalizedString("weekly.stats.this.week", comment: "")
        case 2: return NSLocalizedString("weekly.stats.last.week", comment: "")
        default:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }
    
    private func barColor(for count: Int) -> Color {
        if count == 0 { return .gray.opacity(0.3) }
        else if count <= 5 { return .green }
        else if count <= 10 { return .orange }
        else { return .red }
    }
}

struct WeeklyStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    WeeklyStatsView(cigarettes: [])
}