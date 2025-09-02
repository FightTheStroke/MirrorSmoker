//
//  WeeklyChart.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

struct WeeklyChart: View {
    let weeklyStats: [(Date, Int)]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: DS.Space.sm) {
            ForEach(weeklyStats, id: \.0) { date, count in
                VStack(spacing: DS.Space.xs) {
                    // Barra
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(count))
                        .frame(width: 18, height: barHeight(count))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Day
                    Text(dayLabel(date))
                        .font(DS.Text.caption2)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    // Valore
                    Text("\(count)")
                        .font(DS.Text.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DS.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
    }
    
    private func barHeight(_ count: Int) -> CGFloat {
        let maxH: CGFloat = 100
        return count > 0 ? max(8, min(maxH, CGFloat(count) * 12)) : 4
    }
    
    private func barColor(_ count: Int) -> Color {
        switch count {
        case 0: return DS.Colors.success
        case 1...4: return DS.Colors.primary
        case 5...9: return DS.Colors.warning
        default: return DS.Colors.danger
        }
    }
    
    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("E")
        return formatter.string(from: date)
    }
}

#Preview {
    WeeklyChart(
        weeklyStats: (0..<7).map { 
            let date = Calendar.current.date(byAdding: .day, value: -$0, to: Date())!
            return (date, Int.random(in: 0...15))
        }
    )
}
