//
//  HistorySection.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct HistorySection: View {
    // Add required parameters with default values
    var dailyStats: [(date: Date, count: Int)] = []
    var cigarettes: [Cigarette] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("history.recent.title", comment: ""))
                    .font(.headline)
                
                Spacer()
            }
            
            if dailyStats.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text(NSLocalizedString("history.no.history", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                // Show last 7 days of stats
                ForEach(dailyStats.prefix(7), id: \.date) { stat in
                    HStack {
                        Text(stat.date, format: .dateTime.weekday(.wide))
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(stat.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    HistorySection()
}