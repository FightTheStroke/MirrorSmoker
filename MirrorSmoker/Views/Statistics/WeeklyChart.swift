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
        VStack(alignment: .leading, spacing: 12) {
            Text("Andamento settimanale")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyStats, id: \.0) { date, count in
                    VStack(spacing: 4) {
                        // Barra
                        Rectangle()
                            .fill(count > 15 ? Color.red : count > 10 ? Color.orange : Color.green)
                            .frame(height: max(min(CGFloat(count) * 8, 120), count > 0 ? 4 : 2))
                            .cornerRadius(2)
                        
                        // Giorno
                        Text(date, format: .dateTime.weekday(.abbreviated))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        // Valore
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    WeeklyChart(
        weeklyStats: [
            (Date(), 5),
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 8),
            (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 12),
            (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 6),
            (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 15),
            (Calendar.current.date(byAdding: .day, value: -5, to: Date())!, 9),
            (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, 11)
        ]
    )
}