//
//  InsightCard.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 02/01/25.
//

import SwiftUI
import SwiftData
import os.log

struct InsightCard: View {
    let insight: SmokingInsight
    @State private var isExpanded: Bool = false
    let onDismiss: (() -> Void)?
    let onActionTaken: (() -> Void)?
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "InsightCard")
    
    init(insight: SmokingInsight, onDismiss: (() -> Void)? = nil, onActionTaken: (() -> Void)? = nil) {
        self.insight = insight
        self.onDismiss = onDismiss
        self.onActionTaken = onActionTaken
    }
    
    var body: some View {
        LegacyDSCard {
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
    
    private func showActionSheet() {
        // This is a placeholder for a potential future implementation.
        // The current design uses direct buttons in the UI.
        _ = ActionSheet.Button.default(Text(NSLocalizedString("dismiss.button", comment: ""))) {
            onDismiss?()
            Self.logger.info("Insight dismissed by user.")
        }
        _ = ActionSheet.Button.default(Text(NSLocalizedString("take.action.button", comment: ""))) {
            onActionTaken?()
            Self.logger.info("Insight action taken by user.")
        }
        
        // To use this, you would present an ActionSheet with these buttons.
        // For example: .actionSheet(isPresented: $showingSheet) { ActionSheet(title: Text("..."), buttons: [dismissButton, actionButton, .cancel()]) }
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
                    title: NSLocalizedString("early.morning.pattern.insight", comment: ""),
                    message: NSLocalizedString("early.morning.smoking.message", comment: ""),
                    actionable: NSLocalizedString("delay.first.cigarette.advice", comment: ""),
                    trigger: .morningPattern(firstCigaretteMinutes: 15),
                    priority: .high,
                    timing: .morning,
                    icon: "sun.rise",
                    category: .timing
                ),
                onDismiss: { print(NSLocalizedString("dismissed.message", comment: "")) },
                onActionTaken: { print(NSLocalizedString("action.taken.message", comment: "")) }
            )
            
            InsightCard(
                insight: SmokingInsight(
                    title: NSLocalizedString("great.progress.title", comment: ""),
                    message: NSLocalizedString("fewer.cigarettes.yesterday.message", comment: ""),
                    actionable: NSLocalizedString("keep.momentum.advice", comment: ""),
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