import SwiftUI
import SwiftData
import AppIntents

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
    }
}