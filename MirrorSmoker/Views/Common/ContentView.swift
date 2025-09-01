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
    @State private var selectedTags: [Tag] = []
    
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
            NavigationView {
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // App Title & Context
                            VStack(spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Mirror Smoker")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                        
                                        Text("Track and reflect on your smoking habits")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // Quick Stats - Moved above Today's card
                            VStack(spacing: 12) {
                                Text("Quick Stats")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    StatBox(title: "This Week", value: "\(weeklyCount)", color: .blue)
                                    StatBox(title: "This Month", value: "\(monthlyCount)", color: .orange)
                                    StatBox(title: "Total", value: "\(cigarettes.count)", color: .purple)
                                }
                            }
                            
                            // Today's Counter - Now below quick stats
                            VStack(spacing: 12) {
                                Text("Today")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(todayCigarettes.count)")
                                    .font(.system(size: 48, weight: .bold, design: .default))
                                    .foregroundColor(colorForCount(todayCigarettes.count))
                                
                                Text(todayCigarettes.count == 1 ? "cigarette" : "cigarettes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            
                            // Today's List - With Tags
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
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                
                                                if !cigarette.note.isEmpty {
                                                    Text(cigarette.note)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                // Show tags as colored chips
                                                if let cigaretteTags = cigarette.tags, !cigaretteTags.isEmpty {
                                                    HStack {
                                                        ForEach(cigaretteTags.prefix(3)) { tag in
                                                            Text(tag.name)
                                                                .font(.system(size: 10))
                                                                .padding(.horizontal, 6)
                                                                .padding(.vertical, 2)
                                                                .background(tag.color)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(4)
                                                        }
                                                        
                                                        if cigaretteTags.count > 3 {
                                                            Text("+\(cigaretteTags.count - 3)")
                                                                .font(.system(size: 10))
                                                                .padding(.horizontal, 6)
                                                                .padding(.vertical, 2)
                                                                .background(Color.gray)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(4)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 8) {
                                                // Add/Edit tags button
                                                Button(action: {
                                                    selectedCigarette = cigarette
                                                    selectedTags = cigarette.tags ?? []
                                                    showTagPicker = true
                                                }) {
                                                    Image(systemName: "tag")
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                // Simple delete button
                                                Button(action: {
                                                    deleteCigarette(cigarette)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(8)
                                        .swipeActions(edge: .leading) {
                                            Button(action: {
                                                selectedCigarette = cigarette
                                                selectedTags = cigarette.tags ?? []
                                                showTagPicker = true
                                            }) {
                                                Label("Tags", systemImage: "tag")
                                            }
                                            .tint(.blue)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive, action: {
                                                deleteCigarette(cigarette)
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Empty state
                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                    
                                    Text("Great! No cigarettes today")
                                        .font(.headline)
                                    
                                    Text("Keep it up! Use the + button to log one if needed.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
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
            }
            .navigationBarHidden(true)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Simple Stats Tab
            NavigationView {
                EnhancedStatisticsView()
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }
            .tag(1)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(selectedTags: $selectedTags)
                .onDisappear {
                    // Save tags to the selected cigarette
                    if let cigarette = selectedCigarette {
                        cigarette.tags = selectedTags
                        try? modelContext.save()
                        selectedCigarette = nil
                    }
                }
        }
        .accentColor(.red)
    }
    
    // MARK: - Actions
    
    private func addCigarette() {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        let newCigarette = Cigarette()
        modelContext.insert(newCigarette)
        
        do {
            try modelContext.save()
            
            // Sync with widget
            WidgetStore.shared.syncWithWidget(modelContext: modelContext)
            
        } catch {
            print("Error saving cigarette: \(error)")
        }
    }
    
    private func deleteCigarette(_ cigarette: Cigarette) {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        modelContext.delete(cigarette)
        
        do {
            try modelContext.save()
            
            // Sync with widget
            WidgetStore.shared.syncWithWidget(modelContext: modelContext)
            
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
                // Quick Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatCard(
                        title: "Today",
                        value: "\(todayCount)",
                        subtitle: "cigarettes",
                        color: .blue,
                        systemImage: "lungs.fill"
                    )
                    
                    StatCard(
                        title: "This Week",
                        value: "\(weekCount)",
                        subtitle: "total",
                        color: .orange,
                        systemImage: "calendar"
                    )
                    
                    StatCard(
                        title: "Average",
                        value: String(format: "%.1f", weeklyAverage),
                        subtitle: "per day",
                        color: .green,
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                    
                    StatCard(
                        title: "Total",
                        value: "\(cigarettes.count)",
                        subtitle: "all time",
                        color: .purple,
                        systemImage: "sum"
                    )
                }
                .padding(.horizontal)
                
                // 7-Day Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 7 Days")
                        .font(.headline)
                        .padding(.horizontal)
                    
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
                    .padding(.horizontal)
                }
                .padding()
                .background(AppColors.systemGray6)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private var todayCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return cigarettes.filter { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
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
}

#Preview {
    ContentView()
        .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self, Product.self])
}