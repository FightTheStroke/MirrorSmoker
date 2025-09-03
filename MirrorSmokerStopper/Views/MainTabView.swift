import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ContentView()
            }
            .tabItem {
                Image(systemName: "sun.max")
                Text(NSLocalizedString("tab.today", comment: ""))
            }
            .tag(0)
            
            NavigationView {
                EnhancedStatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text(NSLocalizedString("tab.progress", comment: ""))
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text(NSLocalizedString("tab.plan.profile", comment: ""))
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

