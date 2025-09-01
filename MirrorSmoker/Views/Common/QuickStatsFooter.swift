//
//  QuickStatsFooter.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

struct QuickStatsFooter: View {
    // Add parameters with default values
    var weeklyCount: Int = 0
    var monthlyCount: Int = 0
    var allTimeCount: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("quick.stats", comment: ""))
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("\(weeklyCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("stats.this.week", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 4) {
                    Text("\(monthlyCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("stats.this.month", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 4) {
                    Text("\(allTimeCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("quick.stats.all.time", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    QuickStatsFooter()
}