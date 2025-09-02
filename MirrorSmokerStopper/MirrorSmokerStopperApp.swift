import SwiftUI
import SwiftData
import os.log

@main
struct MirrorSmokerStopperApp: App {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "App")

    // Use the new PersistenceController to manage the data stack.
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // Check if the container failed to load and show an error view.
            if persistenceController.modelContainer == nil {
                ErrorView(
                    title: "Failed to Load Database",
                    message: "The application could not load your data. Please try restarting the app. If the problem persists, contact support."
                )
            } else {
                MainTabView()
                    // Inject the managed model container into the environment.
                    .modelContainer(persistenceController.modelContainer)
                    .onAppear {
                        setupWidgetSync()
                    }
            }
        }
    }
    
    // MARK: - Widget Sync Setup
    
    private func setupWidgetSync() {
        // The primary mechanism for widget updates should be the shared data container.
        // Forcing a timeline reload can be done when absolutely necessary.
        // For example, after a significant background task.
        logger.info("Widget sync configured. Relying on SwiftData's automatic updates.")
        
        // The NotificationCenter observer can be kept for specific edge cases
        // or removed if @Query proves sufficient across all targets.
        // For now, we'll keep it for robustness.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CigaretteAddedFromWidget"),
            object: nil,
            queue: .main
        ) { _ in
            logger.info("Received notification: Cigarette added from widget. UI should refresh automatically via @Query.")
            // No explicit action needed here, as @Query handles the refresh.
        }
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