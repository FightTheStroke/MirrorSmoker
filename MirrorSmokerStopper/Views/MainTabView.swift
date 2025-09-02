import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ContentView()
            }
            .tabItem {
                Image(systemName: "house")
                Text(NSLocalizedString("tab.home", comment: ""))
            }
            .tag(0)
            
            NavigationView {
                EnhancedStatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text(NSLocalizedString("tab.stats.main", comment: ""))
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text(NSLocalizedString("tab.settings.main", comment: ""))
            }
            .tag(2)
        }
        .accentColor(DS.Colors.primary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}