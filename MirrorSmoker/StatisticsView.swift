//
//  StatisticsView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    let cigarettes: [Cigarette]
    
    private var totalCigarettes: Int {
        cigarettes.count
    }
    
    private var averagePerDay: Double {
        guard !cigarettes.isEmpty else { return 0 }
        
        let days = Set(cigarettes.map { $0.dayOnly }).count
        return Double(totalCigarettes) / Double(max(days, 1))
    }
    
    private var weeklyStats: [(Date, Int)] {
        let calendar = Calendar.current
        let now = Date()
        
        var stats: [(Date, Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let count = cigarettes.filter { cigarette in
                cigarette.timestamp >= startOfDay && cigarette.timestamp < endOfDay
            }.count
            
            stats.append((date, count))
        }
        
        return stats.reversed()
    }
    
    private var thisWeekTotal: Int {
        weeklyStats.reduce(0) { $0 + $1.1 }
    }
    
    private var lastWeekTotal: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: Date())!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= twoWeeksAgo && cigarette.timestamp < oneWeekAgo
        }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistiche generali
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
                .background(AppColors.systemGray6)
                .cornerRadius(12)
                
                // Grafico settimanale
                VStack(alignment: .leading, spacing: 12) {
                    Text("Andamento settimanale")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(weeklyStats, id: \.0) { date, count in
                            VStack(spacing: 4) {
                                // Barra
                                Rectangle()
                                    .fill(count > 15 ? Color.red : count > 10 ? Color.orange : Color.green)
                                    .frame(height: max(CGFloat(count) * 8, 4))
                                    .frame(maxHeight: 120)
                                    .cornerRadius(2)
                                
                                // Giorno
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // Numero
                                Text("\(count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .frame(height: 160)
                }
                .padding()
                .background(AppColors.systemGray6)
                .cornerRadius(12)
                
                // Messaggi motivazionali
                VStack(spacing: 12) {
                    Text("💪 Motivazione")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Group {
                        if todaysCount == 0 {
                            MotivationalCard(
                                icon: "🎉",
                                title: "Fantastico!",
                                message: "Non hai fumato nessuna sigaretta oggi!",
                                color: .green
                            )
                        } else if todaysCount < 5 {
                            MotivationalCard(
                                icon: "👍",
                                title: "Buon lavoro!",
                                message: "Stai mantenendo un basso consumo oggi.",
                                color: .blue
                            )
                        } else if todaysCount < 15 {
                            MotivationalCard(
                                icon: "⚠️",
                                title: "Attenzione",
                                message: "Prova a ridurre il numero di sigarette.",
                                color: .orange
                            )
                        } else {
                            MotivationalCard(
                                icon: "🚨",
                                title: "Rifletti",
                                message: "È un giorno pesante. Considera di prenderti una pausa.",
                                color: .red
                            )
                        }
                        
                        if thisWeekTotal < lastWeekTotal {
                            MotivationalCard(
                                icon: "📉",
                                title: "Progresso!",
                                message: "Hai fumato meno questa settimana rispetto alla scorsa!",
                                color: .green
                            )
                        }
                    }
                }
                .padding()
                .background(AppColors.systemGray6)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Statistiche")
        #if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    private var todaysCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
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
        .cornerRadius(8)
    }
}

struct MotivationalCard: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.systemBackground)
        .cornerRadius(8)
    }
}

#Preview {
    StatisticsView(cigarettes: [])
}
