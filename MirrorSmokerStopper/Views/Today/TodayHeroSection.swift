//
//  TodayHeroSection.swift
//  Phase 2: Today View Revolution - Hero Section Redesign
//
//  Enhanced hero section with personalized greeting, visual impact,
//  and clear "at a glance" daily status
//

import SwiftUI
import SwiftData

// MARK: - Main Hero Section
struct TodayHeroSection: View {
    let todayCount: Int
    let todayTarget: Int
    let dailyAverage: Double
    let userProfile: UserProfile?
    let colorForTodayCount: Color
    let progressPercentage: Double
    let timeAgoString: String
    
    var body: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                PersonalizedGreeting(userProfile: userProfile)
                ProgressRingSection(
                    todayCount: todayCount,
                    todayTarget: todayTarget,
                    color: colorForTodayCount,
                    progressPercentage: progressPercentage
                )
                DailyStatusMessage(
                    todayCount: todayCount,
                    todayTarget: todayTarget,
                    dailyAverage: dailyAverage,
                    timeAgoString: timeAgoString
                )
            }
        }
    }
}

// MARK: - Personalized Greeting Component
struct PersonalizedGreeting: View {
    let userProfile: UserProfile?
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "greeting.morning".local()
        case 12..<17: return "greeting.afternoon".local()
        case 17..<22: return "greeting.evening".local()
        default: return "greeting.night".local()
        }
    }
    
    private var motivationalEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "☀️"
        case 12..<17: return "🌤️"
        case 17..<22: return "🌅"
        default: return "🌙"
        }
    }
    
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(greeting)
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    if let name = userProfile?.name, !name.isEmpty {
                        Text(name)
                            .font(DS.Text.title2)
                            .foregroundStyle(DS.Colors.primary)
                    } else {
                        Text("hero.subtitle.default".local())
                            .font(DS.Text.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Date indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text(Date.now, format: .dateTime.weekday(.wide))
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text(Date.now, format: .dateTime.day().month(.abbreviated))
                        .font(DS.Text.headline)
                        .foregroundStyle(DS.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Progress Ring Section with Enhanced Visuals
struct ProgressRingSection: View {
    let todayCount: Int
    let todayTarget: Int
    let color: Color
    let progressPercentage: Double
    
    var body: some View {
        HStack(spacing: DS.Space.xl) {
            // Enhanced progress ring
            ZStack {
                DSProgressRing(
                    progress: progressPercentage,
                    size: 90,
                    lineWidth: 8,
                    color: color
                )
                
                VStack(spacing: 2) {
                    Text("\(todayCount)")
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                    Text("today.cigarettes.short".local())
                        .font(DS.Text.micro)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("today.target".local())
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text("\(todayTarget)")
                        .font(DS.Text.title)
                        .foregroundStyle(DS.Colors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("today.remaining".local())
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text("\(max(0, todayTarget - todayCount))")
                        .font(DS.Text.title)
                        .foregroundStyle(todayCount <= todayTarget ? DS.Colors.success : DS.Colors.danger)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Smart Daily Status Message
struct DailyStatusMessage: View {
    let todayCount: Int
    let todayTarget: Int
    let dailyAverage: Double
    let timeAgoString: String
    
    private var statusMessage: (text: String, color: Color, icon: String) {
        if todayCount == 0 {
            return (
                text: "status.perfect.day".local(),
                color: DS.Colors.success,
                icon: "heart.fill"
            )
        } else if todayCount <= todayTarget / 2 {
            return (
                text: "status.doing.great".local(),
                color: DS.Colors.success,
                icon: "checkmark.circle.fill"
            )
        } else if todayCount <= todayTarget {
            return (
                text: "status.on.track".local(),
                color: DS.Colors.warning,
                icon: "target"
            )
        } else {
            return (
                text: "status.exceed.target".local(),
                color: DS.Colors.danger,
                icon: "exclamationmark.triangle.fill"
            )
        }
    }
    
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: statusMessage.icon)
                    .foregroundStyle(statusMessage.color)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(statusMessage.text)
                    .font(DS.Text.body)
                    .foregroundStyle(statusMessage.color)
                
                Spacer()
            }
            
            if !timeAgoString.isEmpty {
                HStack {
                    Text("last.cigarette.time".local())
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    
                    Text(timeAgoString)
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    Spacer()
                }
            }
        }
        .padding(DS.Space.md)
        .background(statusMessage.color.opacity(0.1))
        .cornerRadius(DS.AdaptiveSize.buttonRadius)
    }
}


#Preview {
    TodayHeroSection(
        todayCount: 3,
        todayTarget: 8,
        dailyAverage: 12.5,
        userProfile: nil,
        colorForTodayCount: .blue,
        progressPercentage: 0.375,
        timeAgoString: "2 ore fa"
    )
    .padding()
}