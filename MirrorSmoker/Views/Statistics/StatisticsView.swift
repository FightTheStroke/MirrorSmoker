//
//  StatisticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    // Add required parameter with default value
    var cigarettes: [Cigarette] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GeneralStatsSection(
                    totalCigarettes: cigarettes.count,
                    averagePerDay: 0.0,
                    thisWeekTotal: 0,
                    lastWeekTotal: 0
                )
                
                WeeklyStatsView(cigarettes: cigarettes)
            }
            .padding()
        }
        .navigationTitle("Statistics")
    }
}