//
//  VisualQuitPlan.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI
import Charts

// MARK: - Visual Quit Plan
struct VisualQuitPlan: View {
    @Binding var quitDate: Date
    @Binding var enableGradualReduction: Bool
    @State private var currentAverage: Double = 12.0
    @State private var dailyTargets: [DailyTarget] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text("quit.plan.title".local())
                        .font(DS.Text.title)
                        .foregroundColor(DS.Colors.primary)
                    
                    Text("quit.plan.subtitle".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer()
                
                StatusIndicator(isActive: enableGradualReduction)
            }
            
            VStack(spacing: DS.AdaptiveSpace.md) {
                // Quit date picker
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(DS.Colors.primary)
                        .font(.title3)
                    
                    DatePicker("quit.plan.target.date".local(), selection: $quitDate, in: Date()..., displayedComponents: .date)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                }
                .padding(DS.AdaptiveSpace.md)
                .background(DS.Colors.glassPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
                
                // Gradual reduction toggle
                HStack {
                    VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                        Text("quit.plan.gradual.reduction".local())
                            .font(DS.Text.headline)
                            .foregroundColor(DS.Colors.textPrimary)
                        
                        Text("quit.plan.gradual.description".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $enableGradualReduction)
                        .toggleStyle(SwitchToggleStyle(tint: DS.Colors.primary))
                }
                .padding(DS.AdaptiveSpace.md)
                .background(DS.Colors.glassPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
            }
            
            // Visual timeline
            if enableGradualReduction {
                QuitPlanChart(
                    quitDate: quitDate,
                    currentAverage: currentAverage,
                    targets: dailyTargets
                )
            } else {
                QuitDateCountdown(quitDate: quitDate)
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
        .onChange(of: quitDate) { _, _ in
            updateTargets()
        }
        .onChange(of: enableGradualReduction) { _, _ in
            updateTargets()
        }
        .onAppear {
            updateTargets()
        }
    }
    
    // Calculate reduction curve when parameters change
    private func updateTargets() {
        guard enableGradualReduction else {
            dailyTargets = []
            return
        }
        
        let daysUntilQuit = Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 30
        let days = max(daysUntilQuit, 1)
        let reductionPerDay = currentAverage / Double(days)
        
        dailyTargets = (0..<min(days, 30)).map { day in
            let target = max(0, currentAverage - (Double(day) * reductionPerDay))
            return DailyTarget(
                day: day,
                target: target,
                date: Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
            )
        }
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: DS.AdaptiveSpace.xs) {
            Circle()
                .fill(isActive ? DS.Colors.smokingProgressExcellent : DS.Colors.textTertiary)
                .frame(width: 8, height: 8)
            
            Text(isActive ? "quit.plan.active".local() : "quit.plan.inactive".local())
                .font(DS.Text.caption)
                .foregroundColor(isActive ? DS.Colors.smokingProgressExcellent : DS.Colors.textTertiary)
        }
        .padding(.horizontal, DS.AdaptiveSpace.sm)
        .padding(.vertical, DS.AdaptiveSpace.xs)
        .background(isActive ? DS.Colors.smokingProgressExcellent.opacity(0.1) : DS.Colors.glassTertiary)
        .clipShape(Capsule())
    }
}

// MARK: - Quit Plan Chart
struct QuitPlanChart: View {
    let quitDate: Date
    let currentAverage: Double
    let targets: [DailyTarget]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            Text("quit.plan.visualization".local())
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            if !targets.isEmpty {
                Chart(targets) { target in
                    LineMark(
                        x: .value("Day", target.day),
                        y: .value("Target", target.target)
                    )
                    .foregroundStyle(DS.Colors.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Day", target.day),
                        y: .value("Target", target.target)
                    )
                    .foregroundStyle(DS.Colors.primary.opacity(0.2))
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Double.self) {
                                Text("\(Int(intValue))")
                                    .font(DS.Text.caption2)
                                    .foregroundColor(DS.Colors.textTertiary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("Day \(intValue + 1)")
                                    .font(DS.Text.caption2)
                                    .foregroundColor(DS.Colors.textTertiary)
                            }
                        }
                    }
                }
                
                // Progress summary
                HStack {
                    VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                        Text("quit.plan.starting".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        Text("\(Int(currentAverage))")
                            .font(DS.Text.title3)
                            .foregroundColor(DS.Colors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: DS.AdaptiveSpace.xs) {
                        Text("quit.plan.days".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        Text("\(targets.count)")
                            .font(DS.Text.title3)
                            .foregroundColor(DS.Colors.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: DS.AdaptiveSpace.xs) {
                        Text("quit.plan.ending".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                        Text("0")
                            .font(DS.Text.title3)
                            .foregroundColor(DS.Colors.smokingProgressExcellent)
                    }
                }
                .padding(DS.AdaptiveSpace.md)
                .background(DS.Colors.glassPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
            }
        }
    }
}

// MARK: - Quit Date Countdown
struct QuitDateCountdown: View {
    let quitDate: Date
    
    private var daysUntilQuit: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: quitDate).day ?? 0
    }
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            Text("quit.plan.countdown.title".local())
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(DS.Colors.primary)
                
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text("\(daysUntilQuit)")
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text(daysUntilQuit == 1 ? "quit.plan.day.remaining".local() : "quit.plan.days.remaining".local())
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(DS.AdaptiveSpace.lg)
            .background(DS.Colors.glassPrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadius))
        }
    }
}

// MARK: - Daily Target Model
struct DailyTarget: Identifiable {
    let id = UUID()
    let day: Int
    let target: Double
    let date: Date
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DS.AdaptiveSpace.xl) {
            VisualQuitPlan(
                quitDate: .constant(Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()),
                enableGradualReduction: .constant(true)
            )
            
            VisualQuitPlan(
                quitDate: .constant(Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
                enableGradualReduction: .constant(false)
            )
        }
        .padding()
    }
    .background(DS.Colors.backgroundSecondary)
}