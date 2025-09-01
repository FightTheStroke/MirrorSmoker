//
//  MirrorSmokerStopperApp.swift
//  MirrorSmokerStopper
//
//  Created by Roberto D’Angelo on 01/09/25.
//

import SwiftUI
import SwiftData

@main
struct MirrorSmokerStopperApp: App {
    // ModelContainer condiviso
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        
        // Configuration for local storage only (no ClouHai ragione, mi scuso per la confusione. Ti spiego esattamente il problema e cosa devo fare:
       
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
            MainTabView()
                .modelContainer(Self.sharedModelContainer)
        }
    }
}