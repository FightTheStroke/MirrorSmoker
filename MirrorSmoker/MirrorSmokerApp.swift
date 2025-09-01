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
                    WidgetStore.shared.configure(modelContext: Self.sharedModelContainer.mainContext)
                }
                .task {
                    // Initial widget sync
                    WidgetStore.shared.syncWithWidget(modelContext: Self.sharedModelContainer.mainContext)
                }
        }
    }
}