import SwiftUI
import SwiftData
import UserNotifications
import os.log

@main
struct MirrorSmokerStopperApp: App {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "App")

    // Use the new PersistenceController to manage the data stack.
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Inject the managed model container into the environment.
                .modelContainer(persistenceController.modelContainer)
                .task {
                    await setupAICoaching()
                }
                .onAppear {
                    setupWidgetSync()
                    setupNotificationCategories()
                }
        }
    }
    
    // MARK: - Widget Sync Setup
    
    private func setupWidgetSync() {
        // The primary mechanism for widget updates should be the shared data container.
        // Forcing a timeline reload can be done when absolutely necessary.
        // For example, after a significant background task.
        Self.logger.info("Widget sync configured. Relying on SwiftData's automatic updates.")
        
        // The NotificationCenter observer can be kept for specific edge cases
        // or removed if @Query proves sufficient across all targets.
        // For now, we'll keep it for robustness.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CigaretteAddedFromWidget"),
            object: nil,
            queue: .main
        ) { _ in
            Self.logger.info("Received notification: Cigarette added from widget. UI should refresh automatically via @Query.")
            // No explicit action needed here, as @Query handles the refresh.
        }
    }
    
    // MARK: - AI Coaching Setup
    
    private func setupAICoaching() async {
        Self.logger.info("Setting up AI coaching system")
        
        // Request HealthKit authorization (deferred, non-blocking)
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()
                Self.logger.info("HealthKit authorization completed")
            } catch {
                Self.logger.info("HealthKit authorization skipped or failed: \(error.localizedDescription)")
                // Continue without HealthKit - the app should work with fallback data
            }
        }
        
        // Set up JITAI evaluation
        Task {
            let jitaiPlanner = JITAIPlanner.shared
            jitaiPlanner.scheduleBackgroundEvaluation()
            
            // Initial evaluation
            await jitaiPlanner.evaluateAndNotify()
            Self.logger.info("JITAI system initialized")
        }
    }
    
    private func setupNotificationCategories() {
        JITAIPlanner.setupNotificationCategories()
        Self.logger.info("Notification categories configured")
    }
}

// A simple view to display critical errors.
struct ErrorView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    MainTabView()
}
