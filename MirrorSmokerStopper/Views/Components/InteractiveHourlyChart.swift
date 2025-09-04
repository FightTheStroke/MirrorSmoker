//
//  InteractiveHourlyChart.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import Charts
import SwiftData
import os.log

// Shared Data Models
struct HourlyData {
    let hour: Int
    let count: Int
}

struct InteractiveHourlyChart: View {
    let data: [HourlyData]
    let selectedDate: Date
    let onHourSelected: (Int) -> Void
    
    @State private var selectedHour: Int?
    
    private let maxCount: Int
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "InteractiveHourlyChart")
    
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
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        guard maxCount > 0 else { return 4 }
        let height = (CGFloat(count) / CGFloat(maxCount)) * 80
        return max(height, count > 0 ? 4 : 2)
    }
    
    private func barColor(for hourData: HourlyData) -> Color {
        switch hourData.count {
        case 0: return .gray.opacity(0.3)
        case 1...2: return .green
        case 3...5: return .orange
        default: return .red
        }
    }
    
    private func hourLabel(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "ha"
        
        let dateComponents = DateComponents(hour: hour)
        if let date = Calendar.current.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        
        // Fallback for safety
        if hour == 0 { return NSLocalizedString("12AM", comment: "Midnight") }
        else if hour < 12 { return String(format: NSLocalizedString("%dAM", comment: "Morning hour format"), hour) }
        else if hour == 12 { return NSLocalizedString("12PM", comment: "Noon") }
        else { return String(format: NSLocalizedString("%dPM", comment: "Afternoon hour format"), hour - 12) }
    }
    
    private func onSelectionChanged(hour: Int?) {
        if let hour {
            selectedHour = hour
            Self.logger.debug("Selected hour: \(hour)")
        } else {
            selectedHour = nil
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