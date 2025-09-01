//
//  EnhancedWeeklyChart.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 01/09/25.
//

import SwiftUI

struct EnhancedWeeklyChart: View {
    let data: [(Date, Int)]
    let maxValue: Int
    
    init(data: [(Date, Int)]) {
        self.data = data
        self.maxValue = max(1, data.map { $1 }.max() ?? 1)
    }
    
    var body: some View {
        VStack(spacing: DS.Space.md) {
            // Chart
            HStack(alignment: .bottom, spacing: DS.Space.sm) {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    let height = CGFloat(item.1) / CGFloat(maxValue) * 120
                    let isToday = Calendar.current.isDateInToday(item.0)
                    
                    VStack(spacing: DS.Space.xs) {
                        // Value label
                        if item.1 > 0 {
                            Text("\(item.1)")
                                .font(DS.Text.caption2)
                                .foregroundStyle(DS.Colors.textPrimary)
                                .fontWeight(.medium)
                        } else {
                            Text("")
                                .font(DS.Text.caption2)
                        }
                        
                        // Bar
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(DS.Colors.backgroundSecondary)
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Size.buttonRadiusSmall))
                            
                            if item.1 > 0 {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                isToday ? DS.Colors.primary : DS.Colors.chartSecondary,
                                                isToday ? DS.Colors.accent : DS.Colors.chartTertiary.opacity(0.7)
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(height: max(8, height))
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Size.buttonRadiusSmall))
                                    .animation(DS.Animation.spring.delay(Double(index) * 0.1), value: height)
                            }
                        }
                        
                        // Day label
                        VStack(spacing: DS.Space.xxs) {
                            Text(dayFormatter.string(from: item.0))
                                .font(DS.Text.caption2)
                                .foregroundStyle(isToday ? DS.Colors.primary : DS.Colors.textSecondary)
                                .fontWeight(isToday ? .semibold : .regular)
                            
                            if isToday {
                                Circle()
                                    .fill(DS.Colors.primary)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DS.Space.sm)
            
            // Summary stats
            HStack {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("Weekly Total")
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text("\(data.map { $1 }.reduce(0, +))")
                        .font(DS.Text.title3)
                        .foregroundStyle(DS.Colors.primary)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                    Text("Daily Avg")
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text(String(format: "%.1f", Double(data.map { $1 }.reduce(0, +)) / 7.0))
                        .font(DS.Text.title3)
                        .foregroundStyle(DS.Colors.warning)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, DS.Space.sm)
        }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color
    let label: String
    let value: String
    
    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        size: CGFloat = 80,
        color: Color = DS.Colors.primary,
        label: String,
        value: String
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
        self.label = label
        self.value = value
    }
    
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: lineWidth)
                    .frame(width: size, height: size)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(DS.Animation.spring, value: progress)
                
                // Center text
                VStack(spacing: DS.Space.xxs) {
                    Text(value)
                        .font(DS.Text.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                    Text(label)
                        .font(DS.Text.caption2)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

struct TrendIndicator: View {
    let trend: Double
    let label: String
    
    var trendDirection: String {
        if trend > 0.1 { return "arrow.up" }
        if trend < -0.1 { return "arrow.down" }
        return "minus"
    }
    
    var trendColor: Color {
        if trend > 0.1 { return DS.Colors.danger }
        if trend < -0.1 { return DS.Colors.success }
        return DS.Colors.warning
    }
    
    var body: some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: trendDirection)
                .font(.caption)
                .foregroundStyle(trendColor)
            
            Text(label)
                .font(DS.Text.caption)
                .foregroundStyle(DS.Colors.textSecondary)
            
            Text(String(format: "%.0f%%", abs(trend * 100)))
                .font(DS.Text.caption)
                .fontWeight(.semibold)
                .foregroundStyle(trendColor)
        }
        .padding(.horizontal, DS.Space.sm)
        .padding(.vertical, DS.Space.xs)
        .background(trendColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedWeeklyChart(data: [
            (Date().addingTimeInterval(-6*86400), 3),
            (Date().addingTimeInterval(-5*86400), 5),
            (Date().addingTimeInterval(-4*86400), 2),
            (Date().addingTimeInterval(-3*86400), 7),
            (Date().addingTimeInterval(-2*86400), 4),
            (Date().addingTimeInterval(-1*86400), 1),
            (Date(), 8)
        ])
        
        HStack {
            CircularProgressView(
                progress: 0.7,
                color: DS.Colors.primary,
                label: "Today vs Avg",
                value: "140%"
            )
            
            CircularProgressView(
                progress: 0.3,
                color: DS.Colors.success,
                label: "Week Goal",
                value: "30%"
            )
        }
        
        TrendIndicator(trend: 0.25, label: "vs last week")
    }
    .padding()
}