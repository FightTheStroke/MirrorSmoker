//
//  StatisticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    let cigarettes: [Cigarette]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GeneralStatsSection(
                    totalCigarettes: totalCigarettes,
                    averagePerDay: averagePerDay,
                    thisWeekTotal: thisWeekTotal,
                    lastWeekTotal: lastWeekTotal
                )
                
                WeeklyChart(weeklyStats: weeklyStats)
                
                // Additional statistics can be added here
                VStack(alignment: .leading, spacing: 12) {
                    Text("Informazioni aggiuntive")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Qui possono essere aggiunte altre statistiche come trend a lungo termine, confronti mensili, ecc.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalCigarettes: Int {
        cigarettes.count
    }
    
    private var averagePerDay: Double {
        guard !cigarettes.isEmpty else { return 0 }
        
        let days = Set(cigarettes.map { $0.dayOnly }).count
        return Double(totalCigarettes) / Double(max(days, 1))
    }
    
    private var weeklyStats: [(Date, Int)] {
        let calendar = Calendar.current
        let now = Date()
        
        var stats: [(Date, Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let count = cigarettes.filter { cigarette in
                cigarette.timestamp >= startOfDay && cigarette.timestamp < endOfDay
            }.count
            
            stats.append((date, count))
        }
        
        return stats.reversed()
    }
    
    private var thisWeekTotal: Int {
        weeklyStats.reduce(0) { $0 + $1.1 }
    }
    
    private var lastWeekTotal: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: Date())!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= twoWeeksAgo && cigarette.timestamp < oneWeekAgo
        }.count
    }
}

#Preview {
    StatisticsView(cigarettes: [])
}
