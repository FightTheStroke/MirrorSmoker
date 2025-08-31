//
//  GeneralStatsSection.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

struct GeneralStatsSection: View {
    let totalCigarettes: Int
    let averagePerDay: Double
    let thisWeekTotal: Int
    let lastWeekTotal: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistiche Generali")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Totale", value: "\(totalCigarettes)", subtitle: "sigarette", color: .red)
                StatCard(title: "Media giornaliera", value: String(format: "%.1f", averagePerDay), subtitle: "al giorno", color: .orange)
                StatCard(title: "Questa settimana", value: "\(thisWeekTotal)", subtitle: "sigarette", color: .blue)
                StatCard(title: "Settimana scorsa", value: "\(lastWeekTotal)", subtitle: "sigarette", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GeneralStatsSection(
        totalCigarettes: 150,
        averagePerDay: 8.5,
        thisWeekTotal: 45,
        lastWeekTotal: 52
    )
}
