//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by Roberto D'Angelo on 02/09/25.
//

import WidgetKit
import SwiftUI
import SwiftData
import Foundation

// MARK: - Widget App Group Manager
struct WidgetAppGroupManager {
    static let groupIdentifier = "group.com.mirror-labs.mirrorsmoker"
    
    static var sharedContainer: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }
}

// MARK: - Widget Models (Simplified)
@Model
class WidgetCigarette {
    var timestamp: Date
    var note: String
    
    init(timestamp: Date = Date(), note: String = "") {
        self.timestamp = timestamp
        self.note = note
    }
}

// MARK: - Widget Today Stats
struct WidgetTodayStats {
    let todayCount: Int
    let dailyAverage: Double
    let lastCigaretteTime: Date?
    
    static let fallback = WidgetTodayStats(
        todayCount: 0,
        dailyAverage: 0.0,
        lastCigaretteTime: nil
    )
    
    // Status color based on count vs average
    var statusColor: String {
        if todayCount == 0 {
            return "#28A745" // Green
        } else if Double(todayCount) <= dailyAverage * 0.8 {
            return "#007AFF" // Blue - below average
        } else if Double(todayCount) <= dailyAverage {
            return "#FFC107" // Yellow - at average
        } else {
            return "#DC3545" // Red - above average
        }
    }
    
    // Formatted string for last cigarette time
    var lastCigaretteFormatted: String {
        guard let lastTime = lastCigaretteTime else {
            return NSLocalizedString("widget.no.cigarettes.today", comment: "")
        }
        
        let now = Date()
        let interval = now.timeIntervalSince(lastTime)
        
        if interval < 3600 { // Less than 1 hour
            let minutes = Int(interval / 60)
            if minutes < 1 {
                return NSLocalizedString("widget.just.now", comment: "")
            }
            return String(format: NSLocalizedString("widget.minutes.ago", comment: ""), minutes)
        } else if interval < 86400 { // Less than 1 day
            let hours = Int(interval / 3600)
            return String(format: NSLocalizedString("widget.hours.ago", comment: ""), hours)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: lastTime)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Widget Entry
struct CigaretteEntry: TimelineEntry {
    let date: Date
    let todayStats: WidgetTodayStats
}

// MARK: - Widget Provider
struct CigaretteProvider: TimelineProvider {
    
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
            let stats = getTodayStats()
            let entry = CigaretteEntry(date: Date(), todayStats: stats)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CigaretteEntry>) -> Void) {
        Task {
            let stats = getTodayStats()
            let entry = CigaretteEntry(date: Date(), todayStats: stats)
            
            // Refresh every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    // MARK: - Data Access
    private func getTodayStats() -> WidgetTodayStats {
        guard let url = WidgetAppGroupManager.sharedContainer else {
            return WidgetTodayStats.fallback
        }
        
        let storeURL = url.appendingPathComponent("MirrorSmoker.sqlite")
        
        do {
            let schema = Schema([WidgetCigarette.self])
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .automatic)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)
            
            // Get today's cigarettes
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            let todayDescriptor = FetchDescriptor<WidgetCigarette>(
                predicate: #Predicate<WidgetCigarette> { cigarette in
                    cigarette.timestamp >= today && cigarette.timestamp < tomorrow
                }
            )
            
            let todayCigarettes = try context.fetch(todayDescriptor)
            
            // Get last cigarette
            let lastCigaretteTime = todayCigarettes.last?.timestamp
            
            // Calculate 30-day average
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            let recentDescriptor = FetchDescriptor<WidgetCigarette>(
                predicate: #Predicate<WidgetCigarette> { cigarette in
                    cigarette.timestamp >= thirtyDaysAgo
                }
            )
            
            let recentCigarettes = try context.fetch(recentDescriptor)
            let dailyAverage = Double(recentCigarettes.count) / 30.0
            
            return WidgetTodayStats(
                todayCount: todayCigarettes.count,
                dailyAverage: dailyAverage,
                lastCigaretteTime: lastCigaretteTime
            )
            
        } catch {
            print("❌ Widget failed to fetch data: \(error)")
            return WidgetTodayStats.fallback
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
                // Today count with accessibility
                VStack(spacing: 2) {
                    Text("\(entry.todayStats.todayCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(entry.todayStats.statusColor))
                        .accessibilityLabel(Text(String(format: NSLocalizedString("widget.a11y.today.count", comment: ""), entry.todayStats.todayCount)))
                    
                    Text(NSLocalizedString("widget.today", comment: ""))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: NSLocalizedString("widget.a11y.today.cigarettes", comment: ""), entry.todayStats.todayCount))
                .accessibilityValue(entry.todayStats.todayCount == 0 ? NSLocalizedString("widget.a11y.great.job", comment: "") : "")
                
                Spacer()
                
                // Add button with accessibility
                Button(intent: AddCigaretteIntent()) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color("#007AFF"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(NSLocalizedString("widget.a11y.add.cigarette", comment: ""))
                .accessibilityHint(NSLocalizedString("widget.a11y.add.cigarette.hint", comment: ""))
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
                    // Today count with accessibility
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(entry.todayStats.todayCount)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(entry.todayStats.statusColor))
                                .accessibilityLabel(Text(String(format: NSLocalizedString("widget.a11y.today.count", comment: ""), entry.todayStats.todayCount)))
                            
                            Text(NSLocalizedString("widget.today", comment: ""))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(String(format: NSLocalizedString("widget.a11y.today.cigarettes", comment: ""), entry.todayStats.todayCount))
                        
                        // Last cigarette time with accessibility
                        Text(entry.todayStats.lastCigaretteFormatted)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .accessibilityLabel(entry.todayStats.lastCigaretteTime == nil ? 
                                NSLocalizedString("widget.a11y.no.cigarettes.today", comment: "") : 
                                String(format: NSLocalizedString("widget.a11y.last.cigarette.time", comment: ""), entry.todayStats.lastCigaretteFormatted))
                    }
                    
                    Spacer()
                    
                    // Daily average with accessibility
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", entry.todayStats.dailyAverage))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(NSLocalizedString("widget.daily.avg", comment: ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(format: NSLocalizedString("widget.a11y.daily.average", comment: ""), entry.todayStats.dailyAverage))
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
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(NSLocalizedString("widget.a11y.add.cigarette", comment: ""))
                    .accessibilityHint(NSLocalizedString("widget.a11y.add.cigarette.hint", comment: ""))
                    
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