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
                                            colors: gradientColors(for: item.1, isToday: isToday),
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
                    Text(NSLocalizedString("weekly.total", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text("\(data.map { $1 }.reduce(0, +))")
                        .font(DS.Text.title3)
                        .foregroundStyle(colorForWeeklyTotal(data.map { $1 }.reduce(0, +)))
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                    Text(NSLocalizedString("daily.average", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                    let average = Double(data.map { $1 }.reduce(0, +)) / 7.0
                    Text(String(format: "%.1f", average))
                        .font(DS.Text.title3)
                        .foregroundStyle(colorForDailyAverage(average))
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
    
    private func gradientColors(for count: Int, isToday: Bool) -> [Color] {
        let baseColors: [Color]
        
        switch count {
        case 0:
            baseColors = [DS.Colors.backgroundSecondary, DS.Colors.backgroundSecondary]
        case 1...3:
            baseColors = [DS.Colors.success, DS.Colors.success.opacity(0.7)] // Verde - molto buono
        case 4...7:
            baseColors = [DS.Colors.success, DS.Colors.warning] // Verde a giallo - buono
        case 8...12:
            baseColors = [DS.Colors.warning, Color.orange] // Giallo a arancione - attenzione
        case 13...20:
            baseColors = [Color.orange, DS.Colors.danger] // Arancione a rosso - male
        default:
            baseColors = [DS.Colors.danger, DS.Colors.cigarette] // Rosso intenso - molto male
        }
        
        // Se è oggi, aggiungi un leggero accent
        if isToday && count > 0 {
            return baseColors.map { $0.opacity(0.9) }
        }
        
        return baseColors
    }
    
    private func colorForWeeklyTotal(_ total: Int) -> Color {
        switch total {
        case 0...20:
            return DS.Colors.success // Verde - settimana eccellente
        case 21...35:
            return DS.Colors.warning // Giallo - settimana discreta
        case 36...50:
            return Color.orange // Arancione - settimana preoccupante
        case 51...70:
            return DS.Colors.danger // Rosso - settimana problematica
        default:
            return DS.Colors.cigarette // Rosso scuro - settimana critica
        }
    }
    
    private func colorForDailyAverage(_ average: Double) -> Color {
        switch average {
        case 0..<3:
            return DS.Colors.success // Verde - media eccellente
        case 3..<5:
            return DS.Colors.warning // Giallo - media accettabile
        case 5..<7:
            return Color.orange // Arancione - media preoccupante
        case 7..<10:
            return DS.Colors.danger // Rosso - media problematica
        default:
            return DS.Colors.cigarette // Rosso scuro - media critica
        }
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
        if trend > 0.1 { return DS.Colors.danger } // Più sigarette = male
        if trend < -0.1 { return DS.Colors.success } // Meno sigarette = bene
        return DS.Colors.warning // Stabile = neutro
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
            (Date().addingTimeInterval(-5*86400), 15), // Alto = rosso
            (Date().addingTimeInterval(-4*86400), 2),  // Basso = verde
            (Date().addingTimeInterval(-3*86400), 7),  // Medio = giallo
            (Date().addingTimeInterval(-2*86400), 4),
            (Date().addingTimeInterval(-1*86400), 1),
            (Date(), 8)
        ])
        
        HStack {
            CircularProgressView(
                progress: 0.7,
                color: DS.Colors.primary,
                label: "Today vs Goal",
                value: "70%"
            )
            
            CircularProgressView(
                progress: 0.3,
                color: DS.Colors.success,
                label: "Weekly Progress",
                value: "30%"
            )
        }
        
        TrendIndicator(trend: -0.25, label: "vs last week") // Negative = green = good
    }
    .padding()
}