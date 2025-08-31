//
//  ContentView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cigarettes: [Cigarette]
    @Query private var tags: [Tag]
    
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showTagPicker = false
    @State private var selectedCigarette: Cigarette?
    
    // Filtered data for today
    private var todayCigarettes: [Cigarette] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Weekly count
    private var weeklyCount: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        return cigarettes.filter { $0.timestamp >= weekAgo }.count
    }
    
    // Monthly count
    private var monthlyCount: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        return cigarettes.filter { $0.timestamp >= monthAgo }.count
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Tab - Simple Dashboard
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Today's Counter - Simple and Clean
                        VStack(spacing: 12) {
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(todayCigarettes.count)")
                                .font(.system(size: 48, weight: .bold, design: .default))
                                .foregroundColor(colorForCount(todayCigarettes.count))
                            
                            Text("cigarettes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        
                        // Today's List - Simple
                        if !todayCigarettes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today's Cigarettes")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                ForEach(todayCigarettes) { cigarette in
                                    HStack {
                                        Image(systemName: "lungs.fill")
                                            .foregroundColor(.red)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                                .font(.subheadline)
                                            
                                            if !cigarette.note.isEmpty {
                                                Text(cigarette.note)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Simple delete button
                                        Button(action: {
                                            deleteCigarette(cigarette)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Simple Stats
                        VStack(spacing: 12) {
                            Text("Quick Stats")
                                .font(.headline)
                            
                            HStack {
                                StatBox(title: "This Week", value: "\(weeklyCount)", color: .blue)
                                StatBox(title: "This Month", value: "\(monthlyCount)", color: .orange)
                                StatBox(title: "Total", value: "\(cigarettes.count)", color: .purple)
                            }
                        }
                        
                        // Add bottom padding to avoid floating button
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            addCigarette()
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Mirror Smoker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Simple Stats Tab
            NavigationView {
                SimpleStatsView(cigarettes: cigarettes)
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }
            .tag(1)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .accentColor(.red)
    }
    
    // MARK: - Actions
    
    private func addCigarette() {
        let newCigarette = Cigarette()
        modelContext.insert(newCigarette)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving cigarette: \(error)")
        }
    }
    
    private func deleteCigarette(_ cigarette: Cigarette) {
        modelContext.delete(cigarette)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting cigarette: \(error)")
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 { return .green }
        else if count <= 5 { return .blue }
        else if count <= 10 { return .orange }
        else { return .red }
    }
}

// Simple Stat Box Component
struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Simple Stats View
struct SimpleStatsView: View {
    let cigarettes: [Cigarette]
    
    private var last7Days: [(Date, Int)] {
        let calendar = Calendar.current
        var result: [(Date, Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = cigarettes.filter { cigarette in
                cigarette.timestamp >= dayStart && cigarette.timestamp < dayEnd
            }.count
            
            result.append((dayStart, count))
        }
        
        return result.reversed()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 7-Day Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 7 Days")
                        .font(.headline)
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(last7Days, id: \.0) { date, count in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(count > 10 ? Color.red : count > 5 ? Color.orange : Color.green)
                                    .frame(height: max(CGFloat(count) * 8, 4))
                                    .frame(maxHeight: 100)
                                    .cornerRadius(2)
                                
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("\(count)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 120)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self, Product.self])
}