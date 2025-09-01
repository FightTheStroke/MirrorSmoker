//
//  mirrorsmokerwidget.swift
//  mirrorsmokerwidget
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import WidgetKit
import SwiftUI
import AppIntents

struct CigaretteWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CigaretteWidgetEntry {
        CigaretteWidgetEntry(date: Date(), todayCount: 0, lastCigaretteTime: "--:--", hasPending: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (CigaretteWidgetEntry) -> Void) {
        let data = WidgetStore.readSnapshot()
        let pendingCount = WidgetStore.shared.getPendingCount()
        let entry = CigaretteWidgetEntry(
            date: Date(), 
            todayCount: data.todayCount, 
            lastCigaretteTime: data.lastCigaretteTime,
            hasPending: pendingCount > 0
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CigaretteWidgetEntry>) -> Void) {
        // Get real data from shared storage
        let data = WidgetStore.readSnapshot()
        let pendingCount = WidgetStore.shared.getPendingCount()
        
        // Check if widget data seems uninitialized (could be first run)
        let isFirstRun = !WidgetStore.shared.hasBeenInitialized()
        
        let entry = CigaretteWidgetEntry(
            date: Date(),
            todayCount: data.todayCount,
            lastCigaretteTime: data.lastCigaretteTime,
            hasPending: pendingCount > 0
        )
        
        // Refresh strategy based on state
        let refreshMinutes: Int
        if isFirstRun {
            // On first run, refresh very frequently to sync with app quickly
            refreshMinutes = 1
        } else if pendingCount > 0 {
            // If pending items, refresh more frequently
            refreshMinutes = 2
        } else {
            // Normal refresh rate
            refreshMinutes = 15
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct CigaretteWidgetEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let lastCigaretteTime: String
    let hasPending: Bool
}

struct AnimatedAddButton: View {
    let hasPending: Bool
    
    var body: some View {
        Button(intent: AddCigaretteIntent()) {
            ZStack {
                // Background circle with shadow
                Circle()
                    .fill(
                        LinearGradient(
                            colors: hasPending ? [Color.orange, Color.orange.opacity(0.8)] : [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (hasPending ? Color.orange : Color.red).opacity(0.4), radius: 3, x: 0, y: 2)
                
                // Icon based on pending state
                Image(systemName: hasPending ? "clock.fill" : "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(hasPending ? 0.9 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 36, height: 36)
    }
}

struct CigaretteWidgetView: View {
    var entry: CigaretteWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            // Header migliorato
            HStack(spacing: 6) {
                // App icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
                
                Text("Mirror Smoker")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 4) {
                    if entry.hasPending {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                        Text("SYNC")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.orange)
                    } else {
                        Text(statusText(for: entry.todayCount))
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(statusColor(for: entry.todayCount))
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background((entry.hasPending ? Color.orange : statusColor(for: entry.todayCount)).opacity(0.2))
                .cornerRadius(8)
            }
            .padding(.bottom, 12)
            
            // Main display
            HStack(alignment: .top) {
                // Count section
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(entry.todayCount)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(colorForCount(entry.todayCount))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        
                        // Pending indicator
                        if entry.hasPending {
                            Text("•••")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                                .opacity(0.8)
                        }
                    }
                    
                    Text(entry.hasPending ? "syncing..." : "today")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(entry.hasPending ? .orange : .secondary)
                }
                
                Spacer()
                
                // Add button
                AnimatedAddButton(hasPending: entry.hasPending)
            }
            
            Spacer()
            
            // Bottom info bar
            HStack {
                // Last cigarette time
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Last")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(entry.lastCigaretteTime)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(entry.todayCount > index * 2 ? colorForCount(entry.todayCount) : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .containerBackground(for: .widget) {
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: gradientColors(for: entry.todayCount, hasPending: entry.hasPending),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle pattern overlay
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .offset(x: -30, y: -20)
                
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 60, height: 60)
                    .offset(x: 40, y: 30)
            }
        }
    }
    
    private func statusText(for count: Int) -> String {
        switch count {
        case 0:
            return "GOOD"
        case 1...3:
            return "OK"
        case 4...7:
            return "HIGH"
        default:
            return "ALERT"
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0:
            return .green
        case 1...3:
            return .blue
        case 4...7:
            return .orange
        case 8...12:
            return .red
        default:
            return .purple
        }
    }
    
    private func statusColor(for count: Int) -> Color {
        switch count {
        case 0:
            return .green
        case 1...5:
            return .blue
        case 6...10:
            return .orange
        default:
            return .red
        }
    }
    
    private func gradientColors(for count: Int, hasPending: Bool) -> [Color] {
        if hasPending {
            return [
                Color.orange.opacity(0.4),
                Color.yellow.opacity(0.3),
                Color.orange.opacity(0.2)
            ]
        }
        
        switch count {
        case 0:
            return [
                Color.green.opacity(0.4),
                Color.mint.opacity(0.3),
                Color.teal.opacity(0.2)
            ]
        case 1...3:
            return [
                Color.blue.opacity(0.4),
                Color.cyan.opacity(0.3),
                Color.indigo.opacity(0.2)
            ]
        case 4...7:
            return [
                Color.orange.opacity(0.4),
                Color.yellow.opacity(0.3),
                Color.red.opacity(0.2)
            ]
        case 8...12:
            return [
                Color.red.opacity(0.5),
                Color.pink.opacity(0.4),
                Color.purple.opacity(0.3)
            ]
        default:
            return [
                Color.purple.opacity(0.6),
                Color.indigo.opacity(0.5),
                Color.black.opacity(0.4)
            ]
        }
    }
}

struct MirrorSmokerWidget: Widget {
    let kind: String = "MirrorSmokerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CigaretteWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                CigaretteWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CigaretteWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Mirror Smoker")
        .description("Monitor your daily cigarette count with a quick add button. Updates in real-time.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled() // For edge-to-edge content on iOS 17+
    }
}

// MARK: - App Intent for Quick Add

struct AddCigaretteIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Cigarette"
    static var description = IntentDescription("Quickly add a cigarette from the widget")
    
    func perform() async throws -> some IntentResult {
        // Add cigarette via WidgetStore
        await WidgetStore.shared.addCigaretteFromWidget()
        
        return .result()
    }
}

#Preview(as: .systemSmall) {
    MirrorSmokerWidget()
} timeline: {
    CigaretteWidgetEntry(date: .now, todayCount: 0, lastCigaretteTime: "--:--", hasPending: false)
    CigaretteWidgetEntry(date: .now, todayCount: 3, lastCigaretteTime: "14:30", hasPending: false)
    CigaretteWidgetEntry(date: .now, todayCount: 3, lastCigaretteTime: "14:30", hasPending: true)
    CigaretteWidgetEntry(date: .now, todayCount: 8, lastCigaretteTime: "16:45", hasPending: false)
}