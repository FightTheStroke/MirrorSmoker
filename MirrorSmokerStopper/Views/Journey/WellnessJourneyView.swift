//
//  WellnessJourneyView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI
import SwiftData

// MARK: - Wellness Journey Map
struct WellnessJourneyMap: View {
    @StateObject private var journeyVM = WellnessJourneyViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.AdaptiveSpace.lg) {
                    JourneyTitle()
                    JourneyProgressBar(progress: journeyVM.journeyProgress)
                    AchievementGallery(achievements: journeyVM.recentAchievements)
                    NextMilestoneCard(milestone: journeyVM.nextMajorMilestone)
                    JourneyInsights(insights: journeyVM.journeyInsights)
                }
                .padding(DS.AdaptiveSpace.lg)
            }
            .background(DS.Colors.backgroundSecondary)
            .navigationTitle("journey.title".local())
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await journeyVM.updateJourneyStats()
            }
        }
        .onAppear {
            Task {
                await journeyVM.updateJourneyStats()
            }
        }
    }
}

// MARK: - Journey Title
struct JourneyTitle: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            Text("journey.welcome.title".local())
                .font(DS.Text.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(DS.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("journey.welcome.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.small)
    }
}

// MARK: - Journey Progress Bar
struct JourneyProgressBar: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            HStack {
                Text("journey.progress.title".local())
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(DS.Text.title3)
                    .foregroundColor(DS.Colors.primary)
                    .fontWeight(.bold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DS.Colors.glassTertiary)
                        .frame(height: 20)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DS.Colors.smokingProgressExcellent,
                                    DS.Colors.motivationInspiring,
                                    DS.Colors.primary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * animatedProgress,
                            height: 20
                        )
                        .animation(DS.Animation.spring.delay(0.3), value: animatedProgress)
                    
                    // Progress milestones
                    HStack {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(animatedProgress >= Double(index + 1) * 0.2 ? DS.Colors.textInverse : DS.Colors.glassPrimary)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(DS.Colors.primary, lineWidth: 2)
                                )
                            if index < 4 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                }
            }
            .frame(height: 20)
            .onAppear {
                withAnimation(DS.Animation.spring.delay(0.5)) {
                    animatedProgress = progress
                }
            }
            
            Text("journey.progress.description".local())
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Achievement Gallery
struct AchievementGallery: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            HStack {
                Text("journey.achievements.title".local())
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Spacer()
                
                Text("\(achievements.count)")
                    .font(DS.Text.captionMono)
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, DS.AdaptiveSpace.sm)
                    .padding(.vertical, DS.AdaptiveSpace.xs)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if achievements.isEmpty {
                EmptyAchievementsView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.AdaptiveSpace.md) {
                        ForEach(achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, DS.AdaptiveSpace.md)
                }
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.sm) {
            // Achievement icon with glow effect
            ZStack {
                Circle()
                    .fill(achievement.category.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.category.color)
            }
            
            VStack(spacing: DS.AdaptiveSpace.xs) {
                Text(achievement.title.local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description.local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
            
            if let unlockedDate = achievement.unlockedDate {
                Text(unlockedDate, style: .date)
                    .font(DS.Text.caption2)
                    .foregroundColor(DS.Colors.textTertiary)
            }
        }
        .frame(width: 140, height: 160)
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.glassPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall)
                .strokeBorder(
                    achievement.isUnlocked ? achievement.category.color.opacity(0.5) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Next Milestone Card
struct NextMilestoneCard: View {
    let milestone: Milestone?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            Text("journey.next.milestone.title".local())
                .font(DS.Text.title2)
                .foregroundColor(DS.Colors.textPrimary)
            
            if let milestone = milestone {
                HStack(spacing: DS.AdaptiveSpace.md) {
                    // Milestone preview
                    VStack {
                        Text(milestone.icon)
                            .font(.system(size: 32))
                        
                        Text(milestone.value)
                            .font(DS.Text.title3)
                            .foregroundColor(DS.Colors.primary)
                            .fontWeight(.bold)
                    }
                    .frame(width: 80)
                    
                    VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                        Text(milestone.title.local())
                            .font(DS.Text.headline)
                            .foregroundColor(DS.Colors.textPrimary)
                        
                        Text(milestone.description.local())
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                            .lineLimit(3)
                        
                        // Time remaining or progress indicator
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(DS.Colors.primary)
                            Text("journey.milestone.coming.soon".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.primary)
                        }
                    }
                    
                    Spacer()
                }
            } else {
                Text("journey.no.milestone".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Journey Insights
struct JourneyInsights: View {
    let insights: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            Text("journey.insights.title".local())
                .font(DS.Text.title2)
                .foregroundColor(DS.Colors.textPrimary)
            
            if insights.isEmpty {
                Text("journey.insights.loading".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.sm) {
                    ForEach(insights, id: \.self) { insight in
                        HStack(alignment: .top, spacing: DS.AdaptiveSpace.sm) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(DS.Colors.motivationInspiring)
                                .font(.caption)
                            
                            Text(insight)
                                .font(DS.Text.body)
                                .foregroundColor(DS.Colors.textPrimary)
                        }
                    }
                }
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Empty Achievements View
struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            Image(systemName: "star.circle")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textTertiary)
            
            VStack(spacing: DS.AdaptiveSpace.xs) {
                Text("journey.achievements.empty.title".local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text("journey.achievements.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    WellnessJourneyMap()
}