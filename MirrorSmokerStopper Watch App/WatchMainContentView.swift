//
//  WatchContentView.swift
//  MirrorSmokerWatchApp Watch App
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import SwiftUI

struct WatchMainContentView: View {
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    // Use WatchConnectivity data
    private var todayCount: Int {
        watchConnectivity.todayCount
    }
    
    private var yesterdayCount: Int {
        watchConnectivity.yesterdayCount
    }
    
    private var weekCount: Int {
        watchConnectivity.weekCount
    }
    
    private var todayCigarettes: [WatchCigarette] {
        watchConnectivity.todayCigarettes
    }
    
    var body: some View {
        TabView {
            // Main tab - Add cigarette
            VStack(spacing: 12) {
                Text("watch.today".local())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(todayCount)")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(colorForCount(todayCount))
                
                Text("watch.cigarettes".local())
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
                Text("watch.statistics".local())
                    .font(.headline)
                
                VStack(spacing: 6) {
                    HStack {
                        Text("watch.yesterday".local())
                        Spacer()
                        Text("\(yesterdayCount)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("watch.week".local())
                        Spacer()
                        Text("\(weekCount)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("watch.average".local())
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
                    Text("watch.today".local())
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    if todayCigarettes.isEmpty {
                        Text("watch.no.cigarettes".local())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(todayCigarettes.prefix(10).enumerated()), id: \.element.id) { index, cigarette in
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
            refreshData()
        }
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
        // Use WatchConnectivity to add cigarette and sync with iPhone
        watchConnectivity.addCigarette()
    }
    
    private func refreshData() {
        // Request fresh data from iPhone
        watchConnectivity.requestStats()
    }
}

#Preview {
    WatchMainContentView()
}

