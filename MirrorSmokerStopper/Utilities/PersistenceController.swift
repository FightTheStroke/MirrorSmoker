//
//  PersistenceController.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 01/09/25.
//

import SwiftData
import Foundation
import os.log

struct PersistenceController {
    static let shared = PersistenceController()
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "Persistence")
    
    let container: ModelContainer
    
    init(inMemory: Bool = false) {
        do {
            // Define the schema with all models
            let schema = Schema([
                Cigarette.self,
                Tag.self,
                UserProfile.self,
                Product.self,
                Purchase.self // Add Purchase model to schema
            ])
            
            // Create configuration with a versioned name
            let configuration = ModelConfiguration(
                "MirrorSmokerModel_v2", // Versioned name for future migrations
                schema: schema,
                isStoredInMemoryOnly: inMemory,
                cloudKitDatabase: .automatic
            )
            
            // Create the container
            container = try ModelContainer(for: schema, configurations: [configuration])
            
            Self.logger.info("Successfully created ModelContainer with versioned configuration")
            
        } catch {
            Self.logger.critical("Failed to create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Preview Container
    static var preview: ModelContainer = {
        let configuration = ModelConfiguration(
            "MirrorSmokerModel_preview",
            isStoredInMemoryOnly: true
        )
        
        do {
            let container = try ModelContainer(
                for: Cigarette.self, Tag.self, UserProfile.self, Product.self, Purchase.self,
                configurations: [configuration]
            )
            
            // Add preview data
            // ... existing preview data code ...
            
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }()
}