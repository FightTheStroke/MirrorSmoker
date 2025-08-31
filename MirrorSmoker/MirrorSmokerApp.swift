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
    // Remove the invalid AppDelegate attribute and UserManager
    @State private var showSettings = false
    
    // ModelContainer condiviso (CloudKit abilitato)
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Remove environmentObject since UserManager doesn't exist
                .modelContainer(Self.sharedModelContainer)
                .onAppear {
                    // FirebaseApp.configure() - Removed Firebase
                    WidgetStore.shared.configure(modelContext: Self.sharedModelContainer.mainContext)
                }
                .task {
                    ConnectivityManager.shared.activate()
                }
        }
    }
}