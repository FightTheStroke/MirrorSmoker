//
//  WeeklyStatsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct WeeklyStatsView: View {
    @Environment(\.dismiss) private var dismiss
    let cigarettes: [Cigarette]
    
    private var weeklyData: [(weekStart: Date, total: Int, daily: [Int])] {
        let calendar = Calendar.current
        let now = Date()
        
        var weeks: [(weekStart: Date, total: Int, daily: [Int])] = []
        
        for weekOffset in 0..<4 {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now)!)?.start ?? now
            
            var dailyCount: [Int] = []
            var weekTotal = 0
            
            for dayOffset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: day)!
                
                let count = cigarettes.filter { cigarette in
                    cigarette.timestamp >= day && cigarette.timestamp < dayEnd
                }.count
                
                dailyCount.append(count)
                weekTotal += count
            }
            
            weeks.append((weekStart: weekStart, total: weekTotal, daily: dailyCount))
        }
        
        return weeks.reversed()
    }
    
    private var maxDailyCount: Int {
        weeklyData.flatMap { $0.daily }.max() ?? 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("Ultime 4 settimane")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            let totalLast4Weeks = weeklyData.reduce(0) { $0 + $1.total }
                            let averagePerWeek = totalLast4Weeks / 4
                            
                            WeeklyStatCard(
                                title: "Totale 4 settimane",
                                value: "\(totalLast4Weeks)",
                                subtitle: "sigarette",
                                color: .red
                            )
                            
                            WeeklyStatCard(
                                title: "Media settimanale",
                                value: "\(averagePerWeek)",
                                subtitle: "a settimana",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.systemGray6)
                    .cornerRadius(16)
                    
                    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, week in
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(weekTitle(for: week.weekStart, index: index))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(week.total) sigarette totali")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("Media: \(week.total / 7)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                ForEach(0..<7, id: \.self) { dayIndex in
                                    let count = week.daily[dayIndex]
                                    let dayDate = Calendar.current.date(byAdding: .day, value: dayIndex, to: week.weekStart)!
                                    
                                    VStack(spacing: 4) {
                                        Rectangle()
                                            .fill(barColor(for: count))
                                            .frame(height: max(CGFloat(count) * 60.0 / CGFloat(maxDailyCount), count > 0 ? 4 : 2))
                                            .cornerRadius(2)
                                        
                                        Text(dayDate, format: .dateTime.weekday(.abbreviated))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(count)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .frame(height: 100)
                        }
                        .padding()
                        .background(AppColors.systemGray6)
                        .cornerRadius(12)
                    }
                    
                    if weeklyData.count >= 2 {
                        VStack(spacing: 12) {
                            Text("📊 Analisi tendenza")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            let thisWeek = weeklyData.last?.total ?? 0
                            let lastWeek = weeklyData.dropLast().last?.total ?? 0
                            let difference = thisWeek - lastWeek
                            
                            HStack {
                                Image(systemName: difference < 0 ? "arrow.down.circle.fill" : difference > 0 ? "arrow.up.circle.fill" : "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(difference < 0 ? .green : difference > 0 ? .red : .blue)
                                
                                VStack(alignment: .leading) {
                                    Text(difference == 0 ? "Nessun cambiamento" : difference < 0 ? "Miglioramento" : "Peggioramento")
                                        .font(.headline)
                                        .foregroundColor(difference < 0 ? .green : difference > 0 ? .red : .blue)
                                    
                                    Text(difference == 0 ? "Stesso numero della settimana scorsa" : "\(abs(difference)) sigarette \(difference < 0 ? "in meno" : "in più") rispetto alla settimana scorsa")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(AppColors.systemBackground)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(AppColors.systemGray6)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistiche Settimanali")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func weekTitle(for date: Date, index: Int) -> String {
        switch index {
        case 3: return "Questa settimana"
        case 2: return "Settimana scorsa"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }
    
    private func barColor(for count: Int) -> Color {
        if count == 0 { return .gray.opacity(0.3) }
        else if count <= 5 { return .green }
        else if count <= 10 { return .orange }
        else { return .red }
    }
}

struct WeeklyStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(AppColors.systemBackground)
        .cornerRadius(12)
    }
}

#Preview {
    WeeklyStatsView(cigarettes: [])
}
