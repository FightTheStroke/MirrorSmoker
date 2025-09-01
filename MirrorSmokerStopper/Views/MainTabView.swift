import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(NSLocalizedString("tab.home", comment: ""))
                }
            
            EnhancedStatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(NSLocalizedString("tab.stats", comment: ""))
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(NSLocalizedString("tab.settings", comment: ""))
                }
        }
        .accentColor(DS.Colors.primary)
    }
}