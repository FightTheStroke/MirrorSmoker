//
//  CoachMessageCard.swift
//  Phase 2: AI Coach Integration for Today View
//
//  Contextual coaching messages and daily tips
//

import SwiftUI
import SwiftData

// MARK: - Coach Message Card
struct CoachMessageCard: View {
    let todayCount: Int
    let todayTarget: Int
    let dailyAverage: Double
    let timeAgoString: String
    
    @State private var isExpanded = false
    @State private var currentTipIndex = 0
    
    private var coachMessage: CoachMessage {
        generateContextualMessage()
    }
    
    var body: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                // Coach Header
                HStack {
                    CoachAvatar()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("coach.daily.tip".local())
                            .font(DS.Text.headline)
                            .foregroundColor(DS.Colors.primary)
                        
                        Text(coachMessage.category.localizedName)
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(DS.Colors.primary)
                            .font(.system(size: 20))
                    }
                }
                
                // Coach Message Content
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(coachMessage.message)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                        .lineLimit(isExpanded ? nil : 2)
                        .animation(.easeInOut, value: isExpanded)
                    
                    if isExpanded {
                        if !coachMessage.actionTips.isEmpty {
                            VStack(alignment: .leading, spacing: DS.Space.xs) {
                                Text("coach.action.tips".local())
                                    .font(DS.Text.caption)
                                    .foregroundColor(DS.Colors.textSecondary)
                                
                                ForEach(coachMessage.actionTips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: DS.Space.xs) {
                                        Text("•")
                                            .foregroundColor(DS.Colors.primary)
                                        Text(tip)
                                            .font(DS.Text.caption)
                                            .foregroundColor(DS.Colors.textPrimary)
                                    }
                                }
                            }
                            .padding(.top, DS.Space.sm)
                            .transition(.opacity.combined(with: .slide))
                        }
                        
                        // Action Buttons
                        HStack(spacing: DS.Space.sm) {
                            Button(action: {
                                // Refresh tip action
                                currentTipIndex = (currentTipIndex + 1) % 3
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("coach.new.tip".local())
                                }
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.primary)
                                .padding(.horizontal, DS.Space.sm)
                                .padding(.vertical, DS.Space.xs)
                                .background(DS.Colors.primary.opacity(0.1))
                                .cornerRadius(DS.AdaptiveSize.buttonRadius)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, DS.Space.sm)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
            }
        }
    }
    
    // MARK: - Generate Contextual Message
    private func generateContextualMessage() -> CoachMessage {
        if todayCount == 0 {
            return CoachMessage(
                category: .motivation,
                message: "coach.perfect.day.message".local(),
                actionTips: [
                    "coach.tip.celebrate".local(),
                    "coach.tip.plan.triggers".local(),
                    "coach.tip.reward.yourself".local()
                ]
            )
        } else if todayCount <= todayTarget / 2 {
            return CoachMessage(
                category: .encouragement,
                message: "coach.doing.well.message".local(),
                actionTips: [
                    "coach.tip.keep.routine".local(),
                    "coach.tip.stay.aware".local(),
                    "coach.tip.track.triggers".local()
                ]
            )
        } else if todayCount <= todayTarget {
            return CoachMessage(
                category: .guidance,
                message: "coach.on.track.message".local(),
                actionTips: [
                    "coach.tip.mindful.moments".local(),
                    "coach.tip.breathing.exercise".local(),
                    "coach.tip.alternative.activity".local()
                ]
            )
        } else {
            return CoachMessage(
                category: .support,
                message: "coach.over.target.message".local(),
                actionTips: [
                    "coach.tip.no.judgment".local(),
                    "coach.tip.reset.tomorrow".local(),
                    "coach.tip.identify.trigger".local()
                ]
            )
        }
    }
}

// MARK: - Coach Avatar Component
struct CoachAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [DS.Colors.primary, DS.Colors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
            
            Text("🧠")
                .font(.system(size: 20))
        }
    }
}

// MARK: - Coach Message Model
struct CoachMessage {
    let category: Category
    let message: String
    let actionTips: [String]
    
    enum Category: CaseIterable {
        case motivation, encouragement, guidance, support
        
        var localizedName: String {
            switch self {
            case .motivation: return "coach.category.motivation".local()
            case .encouragement: return "coach.category.encouragement".local()
            case .guidance: return "coach.category.guidance".local()
            case .support: return "coach.category.support".local()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CoachMessageCard(
            todayCount: 0,
            todayTarget: 8,
            dailyAverage: 12.0,
            timeAgoString: ""
        )
        
        CoachMessageCard(
            todayCount: 6,
            todayTarget: 8,
            dailyAverage: 12.0,
            timeAgoString: "2 hours ago"
        )
    }
    .padding()
}