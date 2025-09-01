import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ContentView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text(NSLocalizedString("tab.home", comment: ""))
            }
            .tag(0)
            
            NavigationStack {
                EnhancedStatisticsView()
            }
            .tabItem {
                Image(systemName: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                Text(NSLocalizedString("tab.stats", comment: ""))
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: selectedTab == 2 ? "gear" : "gear")
                Text(NSLocalizedString("tab.settings", comment: ""))
            }
            .tag(2)
        }
        .tint(DS.Colors.primary)
    }
}