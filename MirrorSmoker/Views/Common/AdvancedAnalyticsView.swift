//
//  AdvancedAnalyticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData
#if canImport(Charts)
import Charts
#endif

struct AdvancedAnalyticsView: View {
    let cigarettes: [Cigarette]
    let allTags: [Tag]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tag usage chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("advanced.analytics.tag.usage", comment: ""))
                            .font(.headline)
                        
                        #if canImport(Charts)
                        if #available(iOS 16.0, macOS 13.0, *) {
                            Chart(tagUsageData, id: \.tag) { item in
                                BarMark(
                                    x: .value("Count", item.count),
                                    y: .value("Tag", item.tag)
                                )
                                .foregroundStyle(by: .value("Tag", item.tag))
                            }
                            .frame(height: 200)
                        } else {
                            Text(NSLocalizedString("advanced.analytics.charts.not.available", comment: ""))
                                .foregroundColor(.secondary)
                        }
                        #else
                        Text(NSLocalizedString("advanced.analytics.charts.not.available.platform", comment: ""))
                            .foregroundColor(.secondary)
                        #endif
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Time distribution
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("advanced.analytics.time.distribution", comment: ""))
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(timeDistributionData, id: \.hour) { item in
                                VStack {
                                    Text("\(item.hour):00")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(item.count)")
                                        .font(.headline)
                                        .foregroundColor(item.count > 5 ? .red : .primary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Weekly pattern
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("statistics.weekly.pattern", comment: ""))
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            ForEach(weeklyPatternData, id: \.day) { item in
                                VStack {
                                    Text(item.day)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(item.count)")
                                        .font(.headline)
                                        .foregroundColor(item.count > 10 ? .red : .primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("analytics.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var tagUsageData: [TagUsageItem] {
        var tagCounts: [String: Int] = [:]
        
        for cigarette in cigarettes {
            // Safely unwrap optional tags
            if let tags = cigarette.tags {
                for tag in tags {
                    tagCounts[tag.name, default: 0] += 1
                }
            }
        }
        
        return tagCounts.map { TagUsageItem(tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(10)
            .map { $0 }
    }
    
    private var timeDistributionData: [TimeDistributionItem] {
        var hourCounts = Array(repeating: 0, count: 24)
        
        for cigarette in cigarettes {
            let hour = Calendar.current.component(.hour, from: cigarette.timestamp)
            hourCounts[hour] += 1
        }
        
        return hourCounts.enumerated().map { TimeDistributionItem(hour: $0.offset, count: $0.element) }
    }
    
    private var weeklyPatternData: [WeeklyPatternItem] {
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var dayCounts = Array(repeating: 0, count: 7)
        
        for cigarette in cigarettes {
            let weekday = Calendar.current.component(.weekday, from: cigarette.timestamp)
            // Convert from Sunday = 1 to Monday = 0
            let adjustedWeekday = (weekday + 5) % 7
            dayCounts[adjustedWeekday] += 1
        }
        
        return zip(weekdays, dayCounts).map { WeeklyPatternItem(day: $0.0, count: $0.1) }
    }
}

// MARK: - Data Models

struct TagUsageItem {
    let tag: String
    let count: Int
}

struct TimeDistributionItem {
    let hour: Int
    let count: Int
}

struct WeeklyPatternItem {
    let day: String
    let count: Int
}

#Preview {
    AdvancedAnalyticsView(
        cigarettes: [],
        allTags: []
    )
}