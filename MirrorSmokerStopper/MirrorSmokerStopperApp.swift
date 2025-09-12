import SwiftUI
import SwiftData
import AppIntents

@main
struct MirrorSmokerStopperApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Environment(\.scenePhase) private var scenePhase
    @State private var didSeedDemoData = false
    
    var sharedModelContainer: ModelContainer {
        PersistenceController.shared.container
    }
    
    var body: some Scene {
        WindowGroup {
            // Onboarding disabled - always show main app
            MainTabView()
                .environmentObject(healthKitManager)
                .task {
                    // Seed demo data una sola volta se lanciato con argomento SCREENSHOT_MODE
                    guard !didSeedDemoData else { return }
                    if ProcessInfo.processInfo.arguments.contains("SCREENSHOT_MODE") {
                        await seedScreenshotDemoData()
                        didSeedDemoData = true
                    }
                }
                .onAppear {
                    // Setup AI Coach notifications
                    JITAIPlanner.setupNotificationCategories()
                    
                    // Setup background tasks for periodic evaluations
                    BackgroundTaskManager.shared.setupBackgroundTasks()
                    BackgroundTaskManager.shared.scheduleJITAIEvaluation()
                    BackgroundTaskManager.shared.scheduleAppRefresh()
                }
            
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

// MARK: - Demo Data Seeding per Screenshot Mode
extension MirrorSmokerStopperApp {
    @MainActor
    func seedScreenshotDemoData() async {
        let context = PersistenceController.shared.container.mainContext
        do {
            // Evita duplicati se già ci sono almeno 10 sigarette
            let existing = try context.fetch(FetchDescriptor<Cigarette>())
            if existing.count >= 10 { return }

            // Crea alcuni Tag
            let triggers = [
                ("Morning Coffee", "#FF9500"),
                ("Work Break", "#34C759"),
                ("After Lunch", "#007AFF"),
                ("Stress", "#FF3B30")
            ].map { Tag(name: $0.0, colorHex: $0.1) }

            // Crea sigarette spalmate nelle ultime 24h
            let now = Date()
            for i in 0..<14 {
                let offsetMin = Int.random(in: 30..<(60 * 18))
                let ts = Calendar.current.date(byAdding: .minute, value: -(offsetMin + i * 7), to: now) ?? now
                let tag = triggers.randomElement()
                let cig = Cigarette(timestamp: ts, note: tag?.name ?? "", tags: tag.map { [$0] })
                context.insert(cig)
            }

            // Associa alcune sigarette ai tag manualmente per densità
            let allCigs = try context.fetch(FetchDescriptor<Cigarette>())
            for (idx, cig) in allCigs.enumerated() where idx < triggers.count {
                var arr = cig.tags ?? []
                arr.append(triggers[idx])
                cig.tags = Array(Set(arr))
            }

            // Salva
            try context.save()
        } catch {
            print("Seeding demo data failed: \(error)")
        }
    }
}