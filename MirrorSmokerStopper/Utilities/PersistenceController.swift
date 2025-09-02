//
//  PersistenceController.swift
//  MirrorSmokerStopper
//
//  Created by Roberto D’Angelo on 02/09/25.
//

import Foundation
import SwiftData
import os.log

/// Manages the SwiftData stack, including container setup and data migration.
class PersistenceController {
    
    /// The shared singleton instance of the persistence controller.
    static let shared = PersistenceController()
    
    /// The main SwiftData model container.
    let modelContainer: ModelContainer
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "Persistence")
    
    private init() {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        
        // First, try to initialize with the App Group container
        if let appGroupContainer = Self.createAppGroupContainer(schema: schema) {
            self.modelContainer = appGroupContainer
            Self.logger.info("✅ Successfully initialized with App Group shared container.")
            
            // Perform migration check on the shared container
            Self.performDataMigrationIfNeeded(to: self.modelContainer)
            
        } else {
            Self.logger.warning("⚠️ App Group not available. Falling back to a local-only container.")
            
            // If App Group fails, fall back to a standard local container
            if let localContainer = Self.createLocalContainer(schema: schema) {
                self.modelContainer = localContainer
                Self.logger.info("✅ Successfully initialized with local container.")
                
                // Perform migration check on the local container
                Self.performDataMigrationIfNeeded(to: self.modelContainer)
                
            } else {
                // As a last resort, use an in-memory container
                Self.logger.error("❌ Critical: Failed to create both App Group and local containers. Falling back to in-memory store.")
                self.modelContainer = Self.createInMemoryContainer(schema: schema)
            }
        }
    }
    
    // MARK: - Container Creation Strategies
    
    /// Creates a container in the shared App Group directory.
    private static func createAppGroupContainer(schema: Schema) -> ModelContainer? {
        guard let sharedContainer = AppGroupManager.sharedModelContainer else {
            return nil
        }
        return sharedContainer
    }
    
    /// Creates a standard container in the app's default directory.
    private static func createLocalContainer(schema: Schema) -> ModelContainer? {
        let configuration = ModelConfiguration(
            "MirrorSmokerModel_v2",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            logger.error("❌ Failed to create local ModelContainer: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Creates an in-memory container as a fallback.
    private static func createInMemoryContainer(schema: Schema) -> ModelContainer {
        let configuration = ModelConfiguration(
            "MirrorSmokerModel_v2_memory",
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If this fails, the app is in an unrecoverable state.
            fatalError("CRITICAL: Could not create even the in-memory fallback ModelContainer: \(error)")
        }
    }

    // MARK: - Data Migration
    
    /// Checks if data migration from a previous version of the database is needed and performs it.
    private static func performDataMigrationIfNeeded(to newContainer: ModelContainer) {
        // Use a flag to ensure migration runs only once.
        let migrationCompletedKey = "DataMigrationCompleted_v2"
        guard !UserDefaults.standard.bool(forKey: migrationCompletedKey) else {
            logger.info("✅ Migration check skipped: Already marked as completed.")
            return
        }
        
        logger.info("🔄 Checking if data migration is needed...")
        
        let newContext = ModelContext(newContainer)
        let cigaretteCheck = FetchDescriptor<Cigarette>()
        
        // Only proceed if the new database is empty.
        guard (try? newContext.fetch(cigaretteCheck).isEmpty) ?? true else {
            logger.info("✅ New database already contains data. No migration needed.")
            UserDefaults.standard.set(true, forKey: migrationCompletedKey) // Mark as complete to avoid future checks
            return
        }
        
        // Configuration for the old database.
        let oldSchema = Schema([Cigarette.self, Tag.self, UserProfile.self, Product.self])
        let oldConfiguration = ModelConfiguration("MirrorSmokerModel", schema: oldSchema, isStoredInMemoryOnly: false)
        
        do {
            let oldContainer = try ModelContainer(for: oldSchema, configurations: [oldConfiguration])
            let oldContext = ModelContext(oldContainer)
            
            logger.info("📂 Old database found. Checking for data to migrate...")
            
            // Fetch all data from the old container.
            let oldCigarettes = try oldContext.fetch(FetchDescriptor<Cigarette>())
            let oldTags = try oldContext.fetch(FetchDescriptor<Tag>())
            let oldProfiles = try oldContext.fetch(FetchDescriptor<UserProfile>())
            let oldProducts = try oldContext.fetch(FetchDescriptor<Product>())
            
            let totalOldItems = oldCigarettes.count + oldTags.count + oldProfiles.count + oldProducts.count
            
            guard totalOldItems > 0 else {
                logger.info("- Old database is empty. No migration required.")
                UserDefaults.standard.set(true, forKey: migrationCompletedKey)
                return
            }
            
            logger.info("📦 Found \(totalOldItems) items. Starting data migration...")
            
            var migratedCount = 0
            
            // --- Migration with Safe Relationship Mapping ---
            
            // 1. Migrate Tags and create a mapping from old ID to new Tag object.
            var tagMapping: [UUID: Tag] = [:]
            for oldTag in oldTags {
                let newTag = Tag(id: oldTag.id, name: oldTag.name, colorHex: oldTag.colorHex)
                newContext.insert(newTag)
                tagMapping[oldTag.id] = newTag
            }
            migratedCount += oldTags.count
            logger.info("🏷️ Migrated \(oldTags.count) tags.")
            
            // 2. Migrate Cigarettes and create a mapping.
            var cigaretteMapping: [UUID: Cigarette] = [:]
            for oldCigarette in oldCigarettes {
                let newCigarette = Cigarette(id: oldCigarette.id, timestamp: oldCigarette.timestamp, note: oldCigarette.note)
                newContext.insert(newCigarette)
                cigaretteMapping[oldCigarette.id] = newCigarette
            }
            migratedCount += oldCigarettes.count
            logger.info("🚬 Migrated \(oldCigarettes.count) cigarettes.")
            
            // 3. Re-establish Cigarette -> Tag relationships safely.
            var relationshipsEstablished = 0
            for oldCigarette in oldCigarettes {
                guard let newCigarette = cigaretteMapping[oldCigarette.id], let oldCigaretteTags = oldCigarette.tags else { continue }
                
                var newTagsForCigarette: [Tag] = []
                for oldTag in oldCigaretteTags {
                    if let newTag = tagMapping[oldTag.id] {
                        newTagsForCigarette.append(newTag)
                        relationshipsEstablished += 1
                    }
                }
                newCigarette.tags = newTagsForCigarette
            }
            logger.info("🔗 Established \(relationshipsEstablished) tag relationships.")
            
            // 4. Migrate UserProfile.
            if let oldProfile = oldProfiles.first {
                let newProfile = UserProfile()
                newProfile.id = oldProfile.id
                newProfile.name = oldProfile.name
                newProfile.quitDate = oldProfile.quitDate
                newProfile.enableGradualReduction = oldProfile.enableGradualReduction
                newProfile.reductionCurve = oldProfile.reductionCurve
                newProfile.startingSmokerType = oldProfile.startingSmokerType
                newProfile.healthInsights = oldProfile.healthInsights
                newProfile.motivationalMessages = oldProfile.motivationalMessages
                newProfile.createdAt = oldProfile.createdAt
                newProfile.dailyAverage = oldProfile.dailyAverage
                newContext.insert(newProfile)
                migratedCount += 1
                logger.info("👤 Migrated user profile.")
            }
            
            // 5. Migrate Products.
            for oldProduct in oldProducts {
                let newProduct = Product(id: oldProduct.id, name: oldProduct.name, brand: oldProduct.brand, price: oldProduct.price, cigarettesPerPack: oldProduct.cigarettesPerPack)
                newContext.insert(newProduct)
            }
            migratedCount += oldProducts.count
            logger.info("📦 Migrated \(oldProducts.count) products.")
            
            // Save all migrated data.
            try newContext.save()
            logger.info("💾 Successfully saved \(migratedCount) migrated items.")
            
            // Mark migration as complete to prevent it from running again.
            UserDefaults.standard.set(true, forKey: migrationCompletedKey)
            logger.info("✅ Migration completed successfully!")
            
        } catch {
            // This error is expected if the old database file doesn't exist (e.g., new install).
            logger.info("- Old database not found or could not be opened. No migration performed. Error: \(error.localizedDescription)")
            // Mark as complete anyway to avoid repeated checks on fresh installs.
            UserDefaults.standard.set(true, forKey: migrationCompletedKey)
        }
    }
}
