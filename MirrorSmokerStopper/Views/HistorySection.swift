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
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader(NSLocalizedString("history.recent.title", comment: ""))
                
                if dailyStats.isEmpty {
                    VStack(spacing: DS.Space.md) {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.textSecondary)
                        
                        Text(NSLocalizedString("history.no.history", comment: ""))
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    .padding(.vertical, DS.Space.lg)
                } else {
                    VStack(spacing: DS.Space.sm) {
                        ForEach(Array(dailyStats.prefix(7).enumerated()), id: \.offset) { index, stat in
                            HStack(spacing: DS.Space.md) {
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text(stat.date, format: .dateTime.weekday(.wide))
                                        .font(DS.Text.body)
                                        .fontWeight(.medium)
                                    
                                    Text(stat.date, format: .dateTime.month(.abbreviated).day())
                                        .font(DS.Text.caption)
                                        .foregroundStyle(DS.Colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                                    Text("\(stat.count)")
                                        .font(DS.Text.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(colorForCount(stat.count))
                                    
                                    Text(stat.count == 1 ? NSLocalizedString("cigarette.singular", comment: "") : NSLocalizedString("cigarettes", comment: ""))
                                        .font(DS.Text.small)
                                        .foregroundStyle(DS.Colors.textSecondary)
                                }
                            }
                            .padding(.vertical, DS.Space.xs)
                        }
                    }
                }
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return DS.Colors.success
        case 1...3: return DS.Colors.primary
        case 4...7: return DS.Colors.warning
        default: return DS.Colors.danger
        }
    }
}

#Preview {
    HistorySection()
}