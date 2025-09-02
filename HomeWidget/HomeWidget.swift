//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by Roberto D'Angelo on 02/09/25.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct CigaretteEntry: TimelineEntry {
    let date: Date
    let todayStats: WidgetTodayStats
}

// MARK: - Widget Provider
struct CigaretteProvider: TimelineProvider {
    private let dataProvider = WidgetDataProvider()
    
    func placeholder(in context: Context) -> CigaretteEntry {
        CigaretteEntry(
            date: Date(),
            todayStats: WidgetTodayStats(
                todayCount: 3,
                dailyAverage: 8.5,
                lastCigaretteTime: Date().addingTimeInterval(-3600)
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CigaretteEntry) -> Void) {
        Task {
            let stats = await dataProvider.getTodayStats()
            let entry = CigaretteEntry(date: Date(), todayStats: stats)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CigaretteEntry>) -> Void) {
        Task {
            let stats = await dataProvider.getTodayStats()
            let entry = CigaretteEntry(date: Date(), todayStats: stats)
            
            // Refresh every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
}

// MARK: - Small Widget View
struct SmallCigaretteWidgetView: View {
    let entry: CigaretteEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color("#F8F9FA"),
                    Color("#E9ECEF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // Today count
                VStack(spacing: 2) {
                    Text("\(entry.todayStats.todayCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(entry.todayStats.statusColor))
                    
                    Text(NSLocalizedString("widget.today", comment: ""))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                // Add button
                Button(intent: AddCigaretteIntent()) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color("#007AFF"))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color("#F8F9FA"), Color("#E9ECEF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Medium Widget View
struct MediumCigaretteWidgetView: View {
    let entry: CigaretteEntry
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color("#F8F9FA"),
                    Color("#E9ECEF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Left side - Main stats
                VStack(alignment: .leading, spacing: 8) {
                    // Today count
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(entry.todayStats.todayCount)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(entry.todayStats.statusColor))
                            
                            Text(NSLocalizedString("widget.today", comment: ""))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                        }
                        
                        // Last cigarette time
                        Text(entry.todayStats.lastCigaretteFormatted)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Daily average
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", entry.todayStats.dailyAverage))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(NSLocalizedString("widget.daily.avg", comment: ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }
                
                Spacer()
                
                // Right side - Action button
                VStack(spacing: 12) {
                    Button(intent: AddCigaretteIntent()) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(NSLocalizedString("widget.add", comment: ""))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color("#007AFF"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color("#F8F9FA"), Color("#E9ECEF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget Configuration
struct CigaretteWidget: Widget {
    let kind: String = "CigaretteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CigaretteProvider()) { entry in
            CigaretteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("widget.display.name", comment: ""))
        .description(NSLocalizedString("widget.description", comment: ""))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry View
struct CigaretteWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: CigaretteEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallCigaretteWidgetView(entry: entry)
        case .systemMedium:
            MediumCigaretteWidgetView(entry: entry)
        default:
            SmallCigaretteWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    CigaretteWidget()
} timeline: {
    CigaretteEntry(date: Date(), todayStats: WidgetTodayStats(todayCount: 0, dailyAverage: 8.5, lastCigaretteTime: nil))
    CigaretteEntry(date: Date(), todayStats: WidgetTodayStats(todayCount: 3, dailyAverage: 8.5, lastCigaretteTime: Date().addingTimeInterval(-3600)))
    CigaretteEntry(date: Date(), todayStats: WidgetTodayStats(todayCount: 12, dailyAverage: 8.5, lastCigaretteTime: Date().addingTimeInterval(-900)))
}

#Preview(as: .systemMedium) {
    CigaretteWidget()
} timeline: {
    CigaretteEntry(date: Date(), todayStats: WidgetTodayStats(todayCount: 5, dailyAverage: 8.5, lastCigaretteTime: Date().addingTimeInterval(-1800)))
}