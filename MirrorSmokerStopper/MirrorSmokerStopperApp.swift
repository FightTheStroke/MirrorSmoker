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
    // Shared ModelContainer with App Group support and automatic migration
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        
        // First try to use the App Group shared container for widget sync
        if let sharedContainer = AppGroupManager.sharedModelContainer {
            print("✅ Using App Group shared container for widget sync")
            return sharedContainer
        }
        
        print("⚠️ App Group not available, falling back to local container")
        
        // Try to create the new v2 container
        let newConfiguration = ModelConfiguration(
            "MirrorSmokerModel_v2",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            let newContainer = try ModelContainer(for: schema, configurations: [newConfiguration])
            
            // Check if migration is needed (if old database exists and new is empty)
            let context = ModelContext(newContainer)
            let cigaretteDescriptor = FetchDescriptor<Cigarette>()
            let existingCigarettes = try? context.fetch(cigaretteDescriptor)
            
            // If new database is empty, attempt migration from old database
            if existingCigarettes?.isEmpty != false {
                print("🔍 New database is empty, checking for old database...")
                performDataMigrationIfNeeded(to: newContainer)
            } else {
                print("✅ New database already has data, skipping migration")
            }
            
            return newContainer
        } catch {
            print("❌ Failed to create new ModelContainer: \(error)")
            
            // Try to create fallback container
            let fallbackConfig = ModelConfiguration(
                "MirrorSmokerModel_v2_memory",
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .automatic
            )
            
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }()
    
    // Migration function
    private static func performDataMigrationIfNeeded(to newContainer: ModelContainer) {
        print("🔄 Checking for data migration...")
        
        // Try to open the old database
        let oldConfiguration = ModelConfiguration(
            "MirrorSmokerModel", // Original database name
            schema: Schema([Cigarette.self, Tag.self, UserProfile.self, Product.self]),
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            print("📂 Attempting to open old database...")
            let oldContainer = try ModelContainer(for: Schema([Cigarette.self, Tag.self, UserProfile.self, Product.self]), configurations: [oldConfiguration])
            let oldContext = ModelContext(oldContainer)
            let newContext = ModelContext(newContainer)
            
            // Check if old database actually has data
            let cigaretteDescriptor = FetchDescriptor<Cigarette>()
            let oldCigarettes = try? oldContext.fetch(cigaretteDescriptor)
            let cigarettesCount = oldCigarettes?.count ?? 0
            
            let tagDescriptor = FetchDescriptor<Tag>()
            let oldTags = try? oldContext.fetch(tagDescriptor)
            let tagsCount = oldTags?.count ?? 0
            
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let oldProfiles = try? oldContext.fetch(profileDescriptor)
            let profilesCount = oldProfiles?.count ?? 0
            
            let productDescriptor = FetchDescriptor<Product>()
            let oldProducts = try? oldContext.fetch(productDescriptor)
            let productsCount = oldProducts?.count ?? 0
            
            print("📊 Old database contents - Cigarettes: \(cigarettesCount), Tags: \(tagsCount), Profiles: \(profilesCount), Products: \(productsCount)")
            
            // Only proceed with migration if old database has data
            if cigarettesCount + tagsCount + profilesCount + productsCount > 0 {
                print("📦 Starting data migration...")
                
                var migratedCount = 0
                
                // Migrate Cigarettes
                if let oldCigarettes = oldCigarettes, !oldCigarettes.isEmpty {
                    print("📦 Migrating \(oldCigarettes.count) cigarettes...")
                    for cigarette in oldCigarettes {
                        let newCigarette = Cigarette()
                        newCigarette.id = cigarette.id
                        newCigarette.timestamp = cigarette.timestamp
                        newCigarette.note = cigarette.note
                        newContext.insert(newCigarette)
                        migratedCount += 1
                    }
                }
                
                // Migrate Tags
                var tagMapping: [UUID: Tag] = [:]
                if let oldTags = oldTags, !oldTags.isEmpty {
                    print("🏷️ Migrating \(oldTags.count) tags...")
                    
                    for oldTag in oldTags {
                        let newTag = Tag(id: oldTag.id, name: oldTag.name, colorHex: oldTag.colorHex)
                        newContext.insert(newTag)
                        tagMapping[oldTag.id] = newTag
                    }
                }
                
                // Re-establish tag relationships
                if let oldCigarettes = oldCigarettes, !oldCigarettes.isEmpty {
                    let newCigaretteDescriptor = FetchDescriptor<Cigarette>()
                    if let newCigarettes = try? newContext.fetch(newCigaretteDescriptor) {
                        print("🔗 Re-establishing tag relationships...")
                        var relationshipCount = 0
                        for (index, oldCigarette) in oldCigarettes.enumerated() {
                            if let oldTags = oldCigarette.tags, index < newCigarettes.count {
                                var newTags: [Tag] = []
                                for tag in oldTags {
                                    if let newTag = tagMapping[tag.id] {
                                        newTags.append(newTag)
                                    }
                                }
                                newCigarettes[index].tags = newTags
                                relationshipCount += newTags.count
                            }
                        }
                        print("🔗 Established \(relationshipCount) tag relationships")
                    }
                }
                
                // Migrate UserProfile
                if let oldProfiles = oldProfiles, let oldProfile = oldProfiles.first {
                    print("👤 Migrating user profile...")
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
                }
                
                // Migrate Products
                if let oldProducts = oldProducts, !oldProducts.isEmpty {
                    print("🚬 Migrating \(oldProducts.count) products...")
                    for oldProduct in oldProducts {
                        let newProduct = Product()
                        newProduct.id = oldProduct.id
                        newProduct.name = oldProduct.name
                        newProduct.brand = oldProduct.brand
                        newProduct.price = oldProduct.price
                        newProduct.cigarettesPerPack = oldProduct.cigarettesPerPack
                        newContext.insert(newProduct)
                        migratedCount += 1
                    }
                }
                
                // Save the migrated data
                if migratedCount > 0 {
                    print("💾 Saving \(migratedCount) migrated items...")
                    try newContext.save()
                    print("✅ Migration completed successfully! Migrated \(migratedCount) items")
                    
                    // Store migration flag to avoid re-migration
                    UserDefaults.standard.set(true, forKey: "DataMigrationCompleted_v2")
                } else {
                    print("⚠️ No data was migrated")
                }
            } else {
                print("⚠️ Old database appears to be empty, no migration needed")
            }
            
        } catch {
            print("❌ Migration failed: \(error)")
            // This is expected for new installations
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(Self.sharedModelContainer)
                .onAppear {
                    setupWidgetSyncNotifications()
                }
        }
    }
    
    // MARK: - Widget Sync Setup
    private func setupWidgetSyncNotifications() {
        // Listen for cigarettes added from widget
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CigaretteAddedFromWidget"),
            object: nil,
            queue: .main
        ) { _ in
            print("📱 Cigarette added from widget, refreshing app...")
            // The app will automatically refresh since it shares the same ModelContainer
        }
    }
}