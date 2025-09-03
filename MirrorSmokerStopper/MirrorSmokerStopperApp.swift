import SwiftUI
import SwiftData

@main
struct MirrorSmokerStopperApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var sharedModelContainer: ModelContainer {
        PersistenceController.shared.container
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(healthKitManager)
        }
        .modelContainer(sharedModelContainer)
        
        // Register App Intents
        #if os(iOS)
        IntentConfiguration(
            intent: AddCigaretteIntent.self,
            provider: nil
        ) { _ in
            EmptyView()
        }
        
        IntentConfiguration(
            intent: GetTodayCountIntent.self,
            provider: nil
        ) { _ in
            EmptyView()
        }
        
        IntentConfiguration(
            intent: GetWeeklyStatsIntent.self,
            provider: nil
        ) { _ in
            EmptyView()
        }
        
        IntentConfiguration(
            intent: SetQuitGoalIntent.self,
            provider: nil
        ) { _ in
            EmptyView()
        }
        
        IntentConfiguration(
            intent: GetMotivationIntent.self,
            provider: nil
        ) { _ in
            EmptyView()
        }
        
        IntentConfiguration(
            intent: LogPurchaseIntent.self, // Add this intent configuration
            provider: nil
        ) { _ in
            EmptyView()
        }
        #endif
    }
}