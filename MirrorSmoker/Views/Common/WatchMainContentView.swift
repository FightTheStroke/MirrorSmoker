//
//  WatchMainContentView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//
//  Renamed from WatchContentView.swift to resolve naming conflict with Watch App target.
//

import SwiftUI
import SwiftData

#if canImport(WatchKit)
import WatchKit
#endif

#if os(watchOS)
struct WatchMainContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    
    private var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
    }
    
    var body: some View {
        TabView {
            // Tab principale - Aggiungi sigaretta
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
            .containerBackground(for: .tabView) {
                Color.black
            }
            
            // Tab statistiche rapide
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
            .containerBackground(for: .tabView) {
                Color.black
            }
            
            // Tab lista sigarette di oggi
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
            .containerBackground(for: .tabView) {
                Color.black
            }
        }
        .tabViewStyle(.verticalPage)
        .task {
            // Removed ConnectivityManager calls for iOS app version
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
        
        // Removed ConnectivityManager calls for iOS app version
        
        // Feedback aptico per watchOS (solo se disponibile)
        #if canImport(WatchKit)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}

#Preview {
    WatchMainContentView()
        .modelContainer(for: Cigarette.self, inMemory: true)
}
#endif