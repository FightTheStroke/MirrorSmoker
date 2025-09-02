//
//  InsightCard.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 02/01/25.
//

import SwiftUI
import SwiftData

struct InsightCard: View {
    let insight: SmokingInsight
    @State private var isExpanded: Bool = false
    let onDismiss: (() -> Void)?
    let onActionTaken: (() -> Void)?
    
    init(insight: SmokingInsight, onDismiss: (() -> Void)? = nil, onActionTaken: (() -> Void)? = nil) {
        self.insight = insight
        self.onDismiss = onDismiss
        self.onActionTaken = onActionTaken
    }
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                // Header
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundStyle(priorityColor)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: DS.Space.xxs) {
                        Text(insight.title)
                            .font(DS.Text.headline)
                            .foregroundStyle(DS.Colors.textPrimary)
                        
                        Text(insight.category.displayName)
                            .font(DS.Text.caption2)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Priority indicator
                    priorityIndicator
                    
                    // Dismiss button
                    if let onDismiss = onDismiss {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(DS.Colors.textTertiary)
                        }
                    }
                }
                
                // Message
                Text(insight.message)
                    .font(DS.Text.body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(isExpanded ? nil : 3)
                
                // Actionable advice (expandable)
                if !insight.actionable.isEmpty {
                    if isExpanded {
                        Divider()
                        
                        HStack(spacing: DS.Space.xs) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(DS.Colors.warning)
                            
                            Text(NSLocalizedString("insight.suggestion", comment: ""))
                                .font(DS.Text.caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .fontWeight(.semibold)
                        }
                        
                        Text(insight.actionable)
                            .font(DS.Text.body)
                            .foregroundStyle(DS.Colors.textPrimary)
                            .padding(.top, DS.Space.xs)
                        
                        // Action button
                        if let onActionTaken = onActionTaken {
                            Button(action: {
                                onActionTaken()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text(NSLocalizedString("insight.action.understood", comment: ""))
                                }
                                .font(DS.Text.callout)
                                .foregroundStyle(DS.Colors.success)
                            }
                            .padding(.top, DS.Space.sm)
                        }
                    } else {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded = true
                            }
                        }) {
                            HStack {
                                Text(NSLocalizedString("insight.show.suggestion", comment: ""))
                                    .font(DS.Text.callout)
                                    .foregroundStyle(DS.Colors.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.primary)
                            }
                        }
                        .padding(.top, DS.Space.xs)
                    }
                }
            }
            .padding(DS.Space.md)
        }
        .overlay(
            // Priority border
            RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                .stroke(priorityColor.opacity(0.3), lineWidth: insight.priority == .critical ? 2 : 1)
        )
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .low:
            return DS.Colors.success
        case .medium:
            return DS.Colors.warning
        case .high:
            return DS.Colors.danger
        case .critical:
            return Color.red
        }
    }
    
    private var priorityIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
            .opacity(insight.priority == .critical ? 1.0 : 0.7)
    }
}

// MARK: - Insights View Model
@Observable
class InsightsViewModel {
    var currentInsights: [SmokingInsight] = []
    var shownInsights: Set<UUID> = []
    
    // Store in UserDefaults for now instead of SwiftData
    private let shownInsightsKey = "shownInsights"
    
    init() {
        loadShownInsights()
    }
    
    private func loadShownInsights() {
        if let data = UserDefaults.standard.data(forKey: shownInsightsKey),
           let uuidStrings = try? JSONDecoder().decode([String].self, from: data) {
            shownInsights = Set(uuidStrings.compactMap { UUID(uuidString: $0) })
        }
    }
    
    private func saveShownInsights() {
        let uuidStrings = shownInsights.map { $0.uuidString }
        if let data = try? JSONEncoder().encode(uuidStrings) {
            UserDefaults.standard.set(data, forKey: shownInsightsKey)
        }
    }
    
    func generateInsights(cigarettes: [Cigarette], profile: UserProfile, tags: [Tag]) {
        let newInsights = InsightEngine.generateInsights(for: cigarettes, profile: profile, tags: tags)
        
        // Filter out already shown insights
        currentInsights = newInsights.filter { !shownInsights.contains($0.id) }
    }
    
    func markInsightAsShown(_ insight: SmokingInsight) {
        shownInsights.insert(insight.id)
        currentInsights.removeAll { $0.id == insight.id }
        saveShownInsights()
    }
    
    func dismissInsight(_ insight: SmokingInsight) {
        markInsightAsShown(insight)
    }
    
    func getTodayInsight() -> SmokingInsight? {
        return currentInsights.first { insight in
            insight.timing == .immediate || insight.timing == .morning
        }
    }
}

struct InsightCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Space.md) {
            InsightCard(
                insight: SmokingInsight(
                    title: "Early Morning Pattern",
                    message: "You smoke your first cigarette 15 minutes after waking. Research shows this indicates high nicotine dependence.",
                    actionable: "Try delaying your first cigarette by 15-30 minutes tomorrow. Even small delays can reduce dependency.",
                    trigger: .morningPattern(firstCigaretteMinutes: 15),
                    priority: .high,
                    timing: .morning,
                    icon: "sun.rise",
                    category: .timing
                ),
                onDismiss: { print("Dismissed") },
                onActionTaken: { print("Action taken") }
            )
            
            InsightCard(
                insight: SmokingInsight(
                    title: "Great Progress!",
                    message: "You smoked 3 fewer cigarettes than yesterday!",
                    actionable: "Keep this momentum going. What did you do differently today?",
                    trigger: .improvementDetected(improvement: "3 cigarettes"),
                    priority: .medium,
                    timing: .immediate,
                    icon: "arrow.down.circle.fill",
                    category: .motivation
                )
            )
        }
        .padding()
    }
}