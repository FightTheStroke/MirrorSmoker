//
//  MainTabView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    
    var body: some View {
        TabView {
            // Home Tab
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(NSLocalizedString("tab.home", comment: ""))
                }
            
            // Statistics Tab  
            NavigationStack {
                EnhancedStatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text(NSLocalizedString("tab.stats", comment: ""))
            }
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text(NSLocalizedString("tab.settings", comment: ""))
            }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self], inMemory: true)
}