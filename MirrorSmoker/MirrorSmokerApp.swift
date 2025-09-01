//
//  MirrorSmokerApp.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

@main
struct MirrorSmokerApp: App {
    // ModelContainer condiviso
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        
        // Configuration for local storage only (no CloudKit)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("Failed to create ModelContainer: \(error)")
            // Fallback to in-memory container
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Self.sharedModelContainer)
                .onAppear {
                    // Configure WidgetStore with model context
                    WidgetStore.shared.configure(modelContext: Self.sharedModelContainer.mainContext)
                    
                    // Force immediate initial sync to ensure widget has correct data
                    Task {
                        // Give a small delay to ensure database is ready
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                        
                        // Force sync on first launch
                        await WidgetStore.shared.performInitialSync(modelContext: Self.sharedModelContainer.mainContext)
                    }
                }
                .task {
                    // Secondary sync check - ensure widget has latest data
                    if WidgetStore.shared.needsRefresh() {
                        WidgetStore.shared.syncWithWidget(modelContext: Self.sharedModelContainer.mainContext)
                    }
                }
        }
    }
}