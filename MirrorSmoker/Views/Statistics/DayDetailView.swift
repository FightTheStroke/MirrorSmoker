//
//  DayDetailView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct DayDetailView: View {
    let date: Date
    let cigarettes: [Cigarette]
    
    private var sortedCigarettes: [Cigarette] {
        cigarettes.sorted { $0.timestamp < $1.timestamp }
    }
    
    private var hourlyBreakdown: [(Int, Int)] {
        let grouped = Dictionary(grouping: sortedCigarettes) { cigarette in
            Calendar.current.component(.hour, from: cigarette.timestamp)
        }
        
        return (0...23).map { hour in
            (hour, grouped[hour]?.count ?? 0)
        }
    }
    
    private var peakHour: Int? {
        let breakdown = hourlyBreakdown.filter { $0.1 > 0 }
        return breakdown.max { $0.1 < $1.1 }?.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header con informazioni del giorno
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(cigarettes.count) sigarette")
                                .font(.title3)
                                .foregroundColor(cigarettes.count > 20 ? .red : cigarettes.count > 10 ? .orange : .green)
                        }
                        
                        Spacer()
                        
                        if let peakHour = peakHour {
                            VStack {
                                Text("Ora di picco")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(peakHour):00")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(AppColors.systemGray6))
                .cornerRadius(12)
                
                // Grafico orario
                if !sortedCigarettes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Distribuzione oraria")
                            .font(.headline)
                        
                        HStack(alignment: .bottom, spacing: 2) {
                            ForEach(hourlyBreakdown, id: \.0) { hour, count in
                                VStack(spacing: 2) {
                                    Rectangle()
                                        .fill(count > 0 ? (count > 3 ? Color.red : count > 1 ? Color.orange : Color.blue) : Color.gray.opacity(0.3))
                                        .frame(height: max(CGFloat(count) * 15, count > 0 ? 8 : 4))
                                        .frame(maxHeight: 80)
                                        .cornerRadius(1)
                                    
                                    if hour % 4 == 0 {
                                        Text("\(hour)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Lista dettagliata delle sigarette
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dettagli")
                        .font(.headline)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(sortedCigarettes) { cigarette in
                            HStack {
                                Image(systemName: "lungs.fill")
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if !cigarette.note.isEmpty {
                                        Text(cigarette.note)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(timeAgo(from: cigarette.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Dettaglio giorno")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationView {
        DayDetailView(date: Date(), cigarettes: [])
    }
}
