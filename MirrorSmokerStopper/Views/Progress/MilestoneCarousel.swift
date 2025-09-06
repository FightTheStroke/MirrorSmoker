//
//  MilestoneCarousel.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - Milestone Model
struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let achievedDate: Date
    let icon: String
    let category: MilestoneCategory
    let value: String // e.g., "7 days", "€50", "10%"
    
    var isRecent: Bool {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(achievedDate) ?? false
    }
}

enum MilestoneCategory: String, CaseIterable {
    case smokeFree = "smoke_free"
    case health = "health"
    case savings = "savings"
    case streak = "streak"
    
    var color: Color {
        switch self {
        case .smokeFree: return DS.Colors.smokingProgressExcellent
        case .health: return DS.Colors.healthImprovement
        case .savings: return DS.Colors.smokingProgressCaution
        case .streak: return DS.Colors.motivationInspiring
        }
    }
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .smokeFree:
            return LinearGradient(
                colors: [DS.Colors.smokingProgressExcellent, DS.Colors.smokingProgressGood],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .health:
            return LinearGradient(
                colors: [DS.Colors.healthImprovement, DS.Colors.healthImprovementExcellent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .savings:
            return LinearGradient(
                colors: [DS.Colors.smokingProgressCaution, DS.Colors.smokingProgressModerate],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .streak:
            return LinearGradient(
                colors: [DS.Colors.motivationInspiring, DS.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Milestone Card
struct MilestoneCard: View {
    let milestone: Milestone
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            // Icon and badge
            HStack {
                Spacer()
                
                if milestone.isRecent {
                    Text("milestone.new".local())
                        .font(DS.Text.micro)
                        .foregroundColor(DS.Colors.textInverse)
                        .padding(.horizontal, DS.AdaptiveSpace.xs)
                        .padding(.vertical, 2)
                        .background(DS.Colors.primary)
                        .clipShape(Capsule())
                }
            }
            
            // Icon
            Image(systemName: milestone.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(DS.Colors.textInverse)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(milestone.category.backgroundGradient)
                        .shadow(color: milestone.category.color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            
            Spacer()
            
            // Content
            VStack(spacing: DS.AdaptiveSpace.xs) {
                Text(milestone.value)
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textPrimary)
                    .fontWeight(.bold)
                
                Text(milestone.title.local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(milestone.description.local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Date
            Text(milestone.achievedDate, style: .date)
                .font(DS.Text.caption2)
                .foregroundColor(DS.Colors.textTertiary)
        }
        .padding(DS.AdaptiveSpace.lg)
        .frame(width: 200, height: 240)
        .liquidGlassCard(elevation: isPressed ? DS.Shadow.large : DS.Shadow.medium)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(DS.Animation.fast) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(DS.Animation.fast) {
                    isPressed = false
                }
            }
            // Show milestone detail when implemented
        }
        .animation(DS.Animation.spring, value: isPressed)
    }
}

// MARK: - Milestone Carousel
struct MilestoneCarousel: View {
    let milestones: [Milestone]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text("progress.achievements".local())
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("progress.achievements.subtitle".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer()
                
                // Achievement count badge
                Text("\(milestones.count)")
                    .font(DS.Text.captionMono)
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, DS.AdaptiveSpace.sm)
                    .padding(.vertical, DS.AdaptiveSpace.xs)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if milestones.isEmpty {
                // Empty state
                EmptyMilestonesView()
            } else {
                // Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.AdaptiveSpace.md) {
                        ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                            MilestoneCard(milestone: milestone)
                                .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                                .opacity(index == currentIndex ? 1.0 : 0.8)
                        }
                    }
                    .padding(.horizontal, DS.AdaptiveSpace.md)
                }
                .onAppear {
                    // Auto-scroll to most recent achievement
                    if let recentIndex = milestones.firstIndex(where: { $0.isRecent }) {
                        currentIndex = recentIndex
                    }
                }
                
                // Page indicators
                if milestones.count > 1 {
                    HStack(spacing: DS.AdaptiveSpace.xs) {
                        ForEach(milestones.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? DS.Colors.primary : DS.Colors.glassTertiary)
                                .frame(width: 8, height: 8)
                                .animation(DS.Animation.fast, value: currentIndex)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, DS.AdaptiveSpace.md)
    }
}

// MARK: - Empty Milestones View
struct EmptyMilestonesView: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            Image(systemName: "trophy.circle")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textTertiary)
            
            VStack(spacing: DS.AdaptiveSpace.sm) {
                Text("progress.no.achievements.title".local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("progress.no.achievements.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .liquidGlassCard(elevation: DS.Shadow.small)
        .padding(.horizontal, DS.AdaptiveSpace.md)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DS.AdaptiveSpace.xl) {
            // With milestones
            MilestoneCarousel(milestones: [
                Milestone(
                    title: "milestone.smoke.free.day",
                    description: "milestone.smoke.free.day.desc",
                    achievedDate: Date().addingTimeInterval(-86400),
                    icon: "heart.fill",
                    category: .smokeFree,
                    value: "1 day"
                ),
                Milestone(
                    title: "milestone.money.saved",
                    description: "milestone.money.saved.desc",
                    achievedDate: Date().addingTimeInterval(-172800),
                    icon: "dollarsign.circle.fill",
                    category: .savings,
                    value: "25"
                ),
                Milestone(
                    title: "milestone.health.improvement",
                    description: "milestone.health.improvement.desc",
                    achievedDate: Date().addingTimeInterval(-259200),
                    icon: "lungs.fill",
                    category: .health,
                    value: "15%"
                )
            ])
            
            // Empty state
            MilestoneCarousel(milestones: [])
        }
    }
    .background(DS.Colors.backgroundSecondary)
}
