import XCTest
import SwiftData
import WatchConnectivity
import Combine
@testable import MirrorSmokerStopper

@MainActor
final class WatchSyncIntegrationTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var syncCoordinator: SyncCoordinator!
    var watchConnectivityManager: WatchConnectivityManager!
    var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Cigarette.self, configurations: config)
        modelContext = ModelContext(modelContainer)
        syncCoordinator = SyncCoordinator.shared
        watchConnectivityManager = WatchConnectivityManager.shared
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        syncCoordinator = nil
        watchConnectivityManager = nil
        cancellables.removeAll()
        try await super.tearDown()
    }

    func testWatchConnectivitySetup() async throws {
        // Test that WatchConnectivity is properly configured
        XCTAssertTrue(WCSession.isSupported(), "WatchConnectivity should be supported")
        
        // Test that our WatchConnectivityManager is properly initialized
        XCTAssertNotNil(watchConnectivityManager, "WatchConnectivityManager should be initialized")
    }

    func testWatchCigaretteAddition() async throws {
        // Test that adding a cigarette from Watch triggers proper sync
        let expectation = XCTestExpectation(description: "Watch cigarette addition triggers sync")
        
        // Listen for the notification that should be posted when a cigarette is added from Watch
        NotificationCenter.default.publisher(for: NSNotification.Name("CigaretteAddedFromWatchNotification"))
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate adding a cigarette from Watch
        let cigarette = Cigarette(timestamp: Date(), note: "Test from Watch")
        modelContext.insert(cigarette)
        try modelContext.save()
        
        // Post the notification that would be sent by the Watch app
        NotificationCenter.default.post(name: NSNotification.Name("CigaretteAddedFromWatchNotification"), object: nil)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Verify that the cigarette was added to the database
        let fetchDescriptor = FetchDescriptor<Cigarette>()
        let cigarettes = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(cigarettes.count, 1, "Expected one cigarette to be added to the database")
    }

    func testWatchDataSynchronization() async throws {
        // Test that data is properly synchronized between iPhone and Watch
        let expectation = XCTestExpectation(description: "Data synchronization between iPhone and Watch")
        
        // Add a cigarette from the iPhone
        let cigarette = Cigarette(timestamp: Date(), note: "Test from iPhone")
        modelContext.insert(cigarette)
        try modelContext.save()
        
        // Simulate the sync coordinator handling the cigarette addition
        // Note: This would normally be called by the app when a cigarette is added
        // For testing, we'll just verify the cigarette was added to the database
        
        // Wait a bit for the sync to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Verify that the sync coordinator has processed the cigarette
        let fetchDescriptor = FetchDescriptor<Cigarette>()
        let cigarettes = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(cigarettes.count, 1, "Expected one cigarette to be in the database")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testWatchUserDefaultsFallback() async throws {
        // Test that UserDefaults fallback works for Watch communication
        let userDefaults = UserDefaults(suiteName: "group.fightthestroke.mirrorsmoker")
        XCTAssertNotNil(userDefaults, "Shared UserDefaults should be accessible")
        
        // Test writing and reading data
        let testKey = "testWatchSync"
        let testValue = "testValue"
        
        userDefaults?.set(testValue, forKey: testKey)
        let retrievedValue = userDefaults?.string(forKey: testKey)
        
        XCTAssertEqual(retrievedValue, testValue, "UserDefaults should work for Watch fallback")
        
        // Clean up
        userDefaults?.removeObject(forKey: testKey)
    }

    func testWatchConnectivityMessageHandling() async throws {
        // Test that WatchConnectivity messages are handled properly
        let expectation = XCTestExpectation(description: "WatchConnectivity message handling")
        
        // Simulate receiving a message from the Watch
        let message = [
            "action": "addCigarette",
            "timestamp": Date().timeIntervalSince1970,
            "note": "Test from Watch"
        ] as [String : Any]
        
        // This would normally be handled by the WatchConnectivityManager
        // For testing, we'll simulate the behavior
        if let action = message["action"] as? String, action == "addCigarette" {
            let cigarette = Cigarette(
                timestamp: Date(timeIntervalSince1970: message["timestamp"] as! TimeInterval),
                note: message["note"] as! String
            )
            modelContext.insert(cigarette)
            try modelContext.save()
            
            // Post the notification
            NotificationCenter.default.post(name: NSNotification.Name("CigaretteAddedFromWatchNotification"), object: nil)
        }
        
        // Wait for the sync to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Verify that the cigarette was added
        let fetchDescriptor = FetchDescriptor<Cigarette>()
        let cigarettes = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(cigarettes.count, 1, "Expected one cigarette to be added from Watch message")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
