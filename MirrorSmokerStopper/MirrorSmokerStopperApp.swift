import SwiftUI
import SwiftData
import AppIntents

@main
struct MirrorSmokerStopperApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var sharedModelContainer: ModelContainer {
        PersistenceController.shared.container
    }
    
    var body: some Scene {
        WindowGroup {
            // Onboarding disabled - always show main app
            MainTabView()
                .environmentObject(healthKitManager)
            
            // MARK: - Onboarding disabled (commented out)
            /*
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(healthKitManager)
            } else {
                OnboardingView()
                    .environmentObject(healthKitManager)
            }
            */
        }
        .modelContainer(sharedModelContainer)
    }
}