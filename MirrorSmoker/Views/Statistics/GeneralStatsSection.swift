//
//  GeneralStatsSection.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

struct GeneralStatsSection: View {
    // Add required parameters with default values
    var totalCigarettes: Int = 0
    var averagePerDay: Double = 0.0
    var thisWeekTotal: Int = 0
    var lastWeekTotal: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("General Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Total cigarettes
            StatCard(
                title: "Total",
                value: "\(totalCigarettes)",
                subtitle: "cigarettes",
                color: .blue
            )
            
            // Average per day
            StatCard(
                title: "Average",
                value: String(format: "%.1f", averagePerDay),
                subtitle: "per day",
                color: .green
            )
            
            // This week vs last week comparison
            VStack(spacing: 8) {
                Text("Weekly Comparison")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    VStack(spacing: 4) {
                        Text("\(thisWeekTotal)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Image(systemName: thisWeekTotal > lastWeekTotal ? "arrow.up" : "arrow.down")
                        .foregroundColor(thisWeekTotal > lastWeekTotal ? .red : .green)
                    
                    VStack(spacing: 4) {
                        Text("\(lastWeekTotal)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Last Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    GeneralStatsSection()
}