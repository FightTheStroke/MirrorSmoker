//
//  CigaretteWidget.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

#if os(iOS)
import WidgetKit
import SwiftUI
import AppIntents

struct CigaretteWidget: Widget {
    let kind: String = "CigaretteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CigaretteTimelineProvider()) { entry in
            CigaretteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cigarette Tracker")
        .description("Track your daily cigarette consumption")
        .supportedFamilies([.systemSmall])
    }
}

struct CigaretteWidgetEntryView: View {
    let entry: CigaretteTimelineEntry
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "lungs")
                    .foregroundColor(.red)
                Text("Today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                if #available(iOS 17.0, *) {
                    // Try using Button with AppIntent directly instead of AppIntentButton
                    Button(intent: QuickAddFromWidgetIntent()) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Quick add")
                } else {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.red)
                        .accessibilityHidden(true)
                }
            }
            
            Spacer(minLength: 4)
            
            Text("\(entry.todayCount)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(entry.todayCount > 20 ? .red : entry.todayCount > 10 ? .orange : .primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            Text("Last: \(entry.lastCigaretteTime)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(8)
        .applyWidgetBackground()
    }
}

private extension View {
    // iOS 17: containerBackground; iOS 16: fallback neutro
    @ViewBuilder
    func applyWidgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(.fill.tertiary, for: .widget)
        } else {
            self.background(Color.clear)
        }
    }
}

struct CigaretteTimelineEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let lastCigaretteTime: String
}

struct CigaretteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CigaretteTimelineEntry {
        let snap = WidgetStore.readSnapshot()
        return CigaretteTimelineEntry(date: Date(), todayCount: snap.todayCount, lastCigaretteTime: snap.lastCigaretteTime)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CigaretteTimelineEntry) -> ()) {
        let snap = WidgetStore.readSnapshot()
        let entry = CigaretteTimelineEntry(date: Date(), todayCount: snap.todayCount, lastCigaretteTime: snap.lastCigaretteTime)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CigaretteTimelineEntry>) -> ()) {
        let snap = WidgetStore.readSnapshot()
        let currentDate = Date()
        let entry = CigaretteTimelineEntry(date: currentDate, todayCount: snap.todayCount, lastCigaretteTime: snap.lastCigaretteTime)
        // Aggiorna ogni 15 minuti; si aggiorna anche esplicitamente da app/intent
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
}

#Preview(as: .systemSmall) {
    CigaretteWidget()
} timeline: {
    CigaretteTimelineEntry(date: Date(), todayCount: 5, lastCigaretteTime: "14:30")
}
#endif