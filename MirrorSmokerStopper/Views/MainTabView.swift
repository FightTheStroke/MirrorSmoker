import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                ContentView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            // Statistics Tab
            NavigationView {
                EnhancedStatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Statistiche")
            }
            .tag(1)
            
            // History Tab
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("Cronologia")
            }
            .tag(2)
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Impostazioni")
            }
            .tag(3)
        }
        .accentColor(DS.Colors.primary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}