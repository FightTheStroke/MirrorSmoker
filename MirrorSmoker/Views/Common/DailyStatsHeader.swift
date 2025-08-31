//
//  DailyStatsHeader.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

struct DailyStatsHeader: View {
    // Add the required parameters with default values
    var todayCount: Int = 0
    var onQuickAdd: () -> Void = {}
    var onAddWithTags: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(todayCount)")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(todayCount == 0 ? .green : todayCount <= 10 ? .blue : todayCount <= 20 ? .orange : .red)
                    
                    Text("cigarettes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: onQuickAdd) {
                        Text("Quick Add")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onAddWithTags) {
                        Text("Add with Tags")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    DailyStatsHeader()
}