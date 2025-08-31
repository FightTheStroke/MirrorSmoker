//
//  ContentView.swift
//  MirrorSmokerWatchApp Watch App
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import SwiftUI
import SwiftData
import WatchConnectivity

struct ContentView: View {
    // ModelContainer locale al Watch con lo stesso schema (CloudKit abilitato)
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
            fatalError("Could not create ModelContainer for watchOS: \(error)")
        }
    }()
    
    var body: some View {
        WatchContentView()  // This needs to be updated if we rename the file
            .modelContainer(Self.sharedModelContainer)
            .task {
                ConnectivityManager.shared.activate()
            }
    }
}