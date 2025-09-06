import SwiftUI
import SwiftData
import AppIntents

@main
struct MirrorSmokerStopperApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var sharedModelContainer: ModelContainer {
        PersistenceController.shared.container
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(healthKitManager)
            } else {
                OnboardingView()
                    .environmentObject(healthKitManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}