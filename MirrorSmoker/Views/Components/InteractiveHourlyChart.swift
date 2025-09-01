//
//  InteractiveHourlyChart.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

struct InteractiveHourlyChart: View {
    let data: [HourlyData]
    let selectedDate: Date
    let onHourSelected: (Int) -> Void
    
    @State private var selectedHour: Int?
    
    private let maxCount: Int
    
    init(data: [HourlyData], selectedDate: Date, onHourSelected: @escaping (Int) -> Void) {
        self.data = data
        self.selectedDate = selectedDate
        self.onHourSelected = onHourSelected
        self.maxCount = data.map(\.count).max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(data, id: \.hour) { hourData in
                    VStack(spacing: 4) {
                        // Bar
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor(for: hourData))
                            .frame(height: barHeight(for: hourData.count))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(
                                        selectedHour == hourData.hour ? Color.blue : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .onTapGesture {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                
                                selectedHour = hourData.hour
                                onHourSelected(hourData.hour)
                            }
                        
                        // Hour label
                        Text(hourLabel(hourData.hour))
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
            
            // Legend
            HStack {
                Spacer()
                
                LegendItem(color: .gray.opacity(0.3), label: "0")
                LegendItem(color: .green, label: "1-2")
                LegendItem(color: .orange, label: "3-5")
                LegendItem(color: .red, label: "6+")
                
                Spacer()
            }
            
            // Selected hour info
            if let selectedHour = selectedHour {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text(String(format: NSLocalizedString("chart.tap.info", comment: ""), selectedHour, (selectedHour + 1) % 24))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        guard maxCount > 0 else { return 4 }
        let height = (CGFloat(count) / CGFloat(maxCount)) * 80
        return max(height, count > 0 ? 4 : 2)
    }
    
    private func barColor(for hourData: HourlyData) -> Color {
        switch hourData.count {
        case 0:
            return .gray.opacity(0.3)
        case 1...2:
            return .green
        case 3...5:
            return .orange
        default:
            return .red
        }
    }
    
    private func hourLabel(_ hour: Int) -> String {
        if hour == 0 {
            return "12AM"
        } else if hour < 12 {
            return "\(hour)AM"
        } else if hour == 12 {
            return "12PM"
        } else {
            return "\(hour - 12)PM"
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 8)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    InteractiveHourlyChart(
        data: Array(0..<24).map { hour in
            HourlyData(hour: hour, count: Int.random(in: 0...6))
        },
        selectedDate: Date()
    ) { hour in
        print("Selected hour: \(hour)")
    }
    .padding()
}