//
//  ContentView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab principale - Dashboard giornaliera
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        DailyStatsHeader(
                            todayCount: 0,
                            onQuickAdd: {},
                            onAddWithTags: {}
                        )
                        
                        TodayCigarettesList(
                            todayCigarettes: [],
                            onDelete: { _ in },
                            onAddTags: { _ in }
                        )
                        
                        HistorySection()
                        
                        QuickStatsFooter()
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            // Tab statistiche avanzate
            NavigationView {
                StatisticsView()
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Stats")
            }
            .tag(1)
            
            // Tab impostazioni
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .accentColor(AppColors.primary)
    }
}