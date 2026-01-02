import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { geometry in
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
                    Text(NSLocalizedString("tab.stats", comment: ""))
                }
                .tag(1)
                
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text(NSLocalizedString("tab.settings", comment: ""))
                }
                .tag(2)
            }
            .accentColor(DS.Colors.primary)
            .simultaneousGesture(
                DragGesture(coordinateSpace: .global)
                    .onEnded { value in
                        let horizontalMovement = value.translation.width
                        let verticalMovement = abs(value.translation.height)
                        let horizontalDistance = abs(horizontalMovement)
                        
                        // Only process horizontal swipes that are longer than vertical ones
                        // and meet the minimum distance threshold
                        if horizontalDistance > 100 && horizontalDistance > verticalMovement * 2 {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if horizontalMovement > 0 {
                                    // Swiping right - go to previous tab
                                    selectedTab = max(0, selectedTab - 1)
                                } else {
                                    // Swiping left - go to next tab  
                                    selectedTab = min(2, selectedTab + 1)
                                }
                            }
                        }
                    }
            )
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

