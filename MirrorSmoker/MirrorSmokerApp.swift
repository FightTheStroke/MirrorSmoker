//
//  MirrorSmokerApp.swift
//  Mirror Smoker
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

@main
struct MirrorSmokerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cigarette.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
#if os(watchOS)
            WatchContentView()
#else
            ContentView()
#endif
        }
        .modelContainer(sharedModelContainer)
        
#if os(macOS)
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
#endif
    }
}
