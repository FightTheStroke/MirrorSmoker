//
//  HeroSection.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - Hero Section
struct HeroSection: View {
    let profile: UserProfile?
    let todayCount: Int
    let todayTarget: Int
    let dailyAverage: Double
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            // Personalized greeting with motivation
            PersonalizedGreeting(name: profile?.name)
            
            // Interactive progress ring with animations
            ProgressRingSection(todayCount: todayCount, todayTarget: todayTarget)
            
            // Smart status messaging
            DailyStatusMessage(todayCount: todayCount, todayTarget: todayTarget, dailyAverage: dailyAverage)
            
            // Key metrics in clean layout
            DailyMetricsGrid(todayCount: todayCount, dailyAverage: dailyAverage)
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Personalized Greeting
struct PersonalizedGreeting: View {
    let name: String?
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 5..<12:
            timeGreeting = "greeting.morning".local()
        case 12..<17:
            timeGreeting = "greeting.afternoon".local()
        case 17..<22:
            timeGreeting = "greeting.evening".local()
        default:
            timeGreeting = "greeting.night".local()
        }
        
        if let name = name, !name.isEmpty {
            return String(format: "greeting.personalized".local(), timeGreeting, name)
        } else {
            return timeGreeting
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                Text(greetingMessage)
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text("hero.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Progress Ring Section
struct ProgressRingSection: View {
    let todayCount: Int
    let todayTarget: Int
    @State private var animateProgress = false
    
    private var progress: Double {
        guard todayTarget > 0 else { return 0 }
        return min(1.0, Double(todayCount) / Double(todayTarget))
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.5: return DS.Colors.smokingProgressExcellent
        case 0.5..<0.8: return DS.Colors.smokingProgressGood
        case 0.8..<1.0: return DS.Colors.smokingProgressCaution
        default: return DS.Colors.smokingProgressHigh
        }
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(DS.Colors.glassTertiary, lineWidth: 8)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animateProgress ? progress : 0)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(DS.Animation.spring.delay(0.3), value: animateProgress)
            
            // Center content
            VStack(spacing: DS.AdaptiveSpace.xs) {
                Text("\(todayCount)")
                    .font(DS.Text.display)
                    .foregroundColor(DS.Colors.textPrimary)
                    .fontWeight(.bold)
                
                Text("/")
                    .font(DS.Text.title3)
                    .foregroundColor(DS.Colors.textTertiary)
                
                Text("\(todayTarget)")
                    .font(DS.Text.title3)
                    .foregroundColor(DS.Colors.textSecondary)
            }
        }
        .onAppear {
            withAnimation(DS.Animation.spring.delay(0.5)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Daily Status Message
struct DailyStatusMessage: View {
    let todayCount: Int
    let todayTarget: Int
    let dailyAverage: Double
    
    private var statusMessage: String {
        let progress = todayTarget > 0 ? Double(todayCount) / Double(todayTarget) : 0
        
        switch progress {
        case 0:
            return "status.excellent.start".local()
        case 0..<0.5:
            return "status.excellent.progress".local()
        case 0.5..<0.8:
            return "status.good.progress".local()
        case 0.8..<1.0:
            return "status.caution.approaching".local()
        case 1.0:
            return "status.limit.reached".local()
        default:
            return "status.over.limit".local()
        }
    }
    
    private var statusColor: Color {
        let progress = todayTarget > 0 ? Double(todayCount) / Double(todayTarget) : 0
        
        switch progress {
        case 0..<0.5: return DS.Colors.smokingProgressExcellent
        case 0.5..<0.8: return DS.Colors.smokingProgressGood
        case 0.8..<1.0: return DS.Colors.smokingProgressCaution
        default: return DS.Colors.smokingProgressHigh
        }
    }
    
    var body: some View {
        HStack(spacing: DS.AdaptiveSpace.sm) {
            Image(systemName: "heart.fill")
                .foregroundColor(statusColor)
                .font(.title3)
            
            Text(statusMessage)
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, DS.AdaptiveSpace.md)
        .padding(.vertical, DS.AdaptiveSpace.sm)
        .background(statusColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
    }
}

// MARK: - Daily Metrics Grid
struct DailyMetricsGrid: View {
    let todayCount: Int
    let dailyAverage: Double
    
    var body: some View {
        HStack(spacing: DS.AdaptiveSpace.md) {
            MetricCard(
                title: "metrics.today".local(),
                value: "\(todayCount)",
                icon: "calendar.badge.clock",
                color: DS.Colors.primary
            )
            
            MetricCard(
                title: "metrics.average".local(),
                value: String(format: "%.1f", dailyAverage),
                icon: "chart.line.uptrend.xyaxis",
                color: DS.Colors.smokingProgressGood
            )
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(DS.Text.title2)
                .foregroundColor(DS.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Text(title)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.glassPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DS.AdaptiveSpace.xl) {
            HeroSection(
                profile: nil,
                todayCount: 3,
                todayTarget: 10,
                dailyAverage: 8.5
            )
            
            HeroSection(
                profile: UserProfile(name: "Mario", age: 30),
                todayCount: 12,
                todayTarget: 10,
                dailyAverage: 11.2
            )
        }
        .padding()
    }
    .background(DS.Colors.backgroundSecondary)
}