//
//  MirrorSmokerStopperApp.swift
//  MirrorSmokerStopper Watch App
//
//  Created by Roberto D'Angelo on 01/09/25.
//

import SwiftUI

@main
struct MirrorSmokerStopper_Watch_AppApp: App {
    @StateObject private var sharedDataManager = SharedDataManager.shared
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            WatchMainContentView()
                .environmentObject(sharedDataManager)
                .environmentObject(watchConnectivity)
        }
    }
}
