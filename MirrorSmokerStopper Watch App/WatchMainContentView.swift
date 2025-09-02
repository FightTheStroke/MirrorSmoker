//
//  WatchContentView.swift
//  MirrorSmokerWatchApp Watch App
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct WatchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    
    private var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
    }
    
    var body: some View {
        TabView {
            // Main tab - Add cigarette
            VStack(spacing: 12) {
                Text("Oggi")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(todayCount)")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(colorForCount(todayCount))
                
                Text("sigarette")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: addCigarette) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .background(Circle().fill(Color.red.opacity(0.2)).frame(width: 60, height: 60))
            }
            .background(Color.black)
            
            // Quick stats tab
            VStack(spacing: 8) {
                Text("Statistiche")
                    .font(.headline)
                
                VStack(spacing: 6) {
                    HStack {
                        Text("Ieri:")
                        Spacer()
                        Text("\(yesterdayCount)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Settimana:")
                        Spacer()
                        Text("\(weekCount)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Media:")
                        Spacer()
                        Text(String(format: "%.1f", weeklyAverage))
                            .fontWeight(.semibold)
                    }
                }
                .font(.caption)
            }
            .background(Color.black)
            
            // Today's cigarettes list tab
            ScrollView {
                LazyVStack(spacing: 4) {
                    Text("Oggi")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    let todayCigarettes = cigarettes.filter { cigarette in
                        Calendar.current.isDateInToday(cigarette.timestamp)
                    }
                    
                    if todayCigarettes.isEmpty {
                        Text("Nessuna sigaretta")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(todayCigarettes.prefix(10)) { cigarette in
                            HStack {
                                Image(systemName: "lungs.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                
                                Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                    .font(.caption2)
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.black)
        }
        .tabViewStyle(.page) // Use .page instead of .verticalPage for watchOS
        .task {
            // Removed ConnectivityManager calls for Watch App version
        }
    }
    
    private var yesterdayCount: Int {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= startOfYesterday && cigarette.timestamp < endOfYesterday
        }.count
    }
    
    private var weekCount: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= weekAgo
        }.count
    }
    
    private var weeklyAverage: Double {
        guard weekCount > 0 else { return 0 }
        return Double(weekCount) / 7.0
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 { return .green }
        else if count <= 5 { return .blue }
        else if count <= 10 { return .orange }
        else { return .red }
    }
    
    private func addCigarette() {
        let newCigarette = Cigarette()
        newCigarette.id = UUID()
        modelContext.insert(newCigarette)
        try? modelContext.save()
        
        // Removed ConnectivityManager calls for Watch App version
        // Removed WKInterfaceDevice call since WatchKit is not available
    }
}

#Preview {
    WatchContentView()
        .modelContainer(for: Cigarette.self, inMemory: true)
}

