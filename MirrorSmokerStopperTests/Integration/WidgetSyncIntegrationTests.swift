import XCTest
@testable import MirrorSmokerStopper

@MainActor
final class WidgetSyncIntegrationTests: XCTestCase {
    let groupID = "group.fightthestroke.mirrorsmoker"

    func testPendingWidgetActionsProcessing() async throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: enqueue two pending timestamps
        let now = Date().timeIntervalSince1970
        ud.set([now - 60, now], forKey: "widget_pending_cigarettes")

        // Act: process pending
        await PendingWidgetActionsManager.shared.processPendingIfAny()

        // Assert: queue cleared and lastUpdated bumped
        let pending = ud.array(forKey: "widget_pending_cigarettes") as? [Double]
        XCTAssertTrue(pending == nil || pending?.isEmpty == true, "Pending queue should be cleared")
        XCTAssertNotNil(ud.object(forKey: "lastUpdated"), "lastUpdated should be set after processing")
    }

    func testSharedSnapshotUpdatesAfterFullSync() async throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: insert one cigarette into the shared model
        let context = PersistenceController.shared.container.mainContext
        let cig = Cigarette(timestamp: Date(), note: "Test from unit test")
        context.insert(cig)
        try context.save()

        // Act: perform full sync to export snapshot for widgets/watch
        await SyncCoordinator.shared.performFullSync()

        // Give a tiny delay for async task
        try await Task.sleep(for: .milliseconds(200))

        // Assert: todayCount exported
        let todayCount = ud.integer(forKey: "todayCount")
        XCTAssertGreaterThanOrEqual(todayCount, 1, "todayCount should be >= 1 after saving a cigarette and syncing")
    }
    
    func testBidirectionalSyncFromApp() async throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: clear any existing data
        ud.removeObject(forKey: "todayCount")
        ud.removeObject(forKey: "lastUpdated")
        
        let context = PersistenceController.shared.container.mainContext
        let initialCount = ud.integer(forKey: "todayCount")
        
        // Act: add cigarette from app
        let cig = Cigarette(timestamp: Date(), note: "Test sync from app")
        context.insert(cig)
        try context.save()
        
        // Trigger sync
        SyncCoordinator.shared.cigaretteAdded(from: .app, cigarette: cig)
        
        // Give a tiny delay for async operations
        try await Task.sleep(for: .milliseconds(300))

        // Assert: shared UserDefaults updated
        let updatedCount = ud.integer(forKey: "todayCount")
        XCTAssertEqual(updatedCount, initialCount + 1, "todayCount should be incremented after adding cigarette from app")
        XCTAssertNotNil(ud.object(forKey: "lastUpdated"), "lastUpdated should be set")
    }
    
    func testBidirectionalSyncFromWidget() async throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: clear any existing data
        ud.removeObject(forKey: "todayCount")
        ud.removeObject(forKey: "lastUpdated")
        ud.removeObject(forKey: "widget_cigarette_added")
        
        let initialCount = ud.integer(forKey: "todayCount")
        
        // Act: simulate widget adding cigarette
        ud.set(true, forKey: "widget_cigarette_added")
        ud.set(Date(), forKey: "lastUpdated")
        
        // Trigger sync check
        await SyncCoordinator.shared.performFullSync()
        
        // Give a tiny delay for async operations
        try await Task.sleep(for: .milliseconds(300))

        // Assert: widget flag cleared and sync triggered
        XCTAssertFalse(ud.bool(forKey: "widget_cigarette_added"), "widget_cigarette_added flag should be cleared after processing")
        XCTAssertNotNil(ud.object(forKey: "lastUpdated"), "lastUpdated should be set")
    }
    
    func testRealTimeSyncPerformance() async throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        let context = PersistenceController.shared.container.mainContext
        let startTime = Date()
        
        // Act: add multiple cigarettes rapidly
        for i in 0..<5 {
            let cig = Cigarette(timestamp: Date(), note: "Test sync \(i)")
            context.insert(cig)
            try context.save()
            
            SyncCoordinator.shared.cigaretteAdded(from: .app, cigarette: cig)
            
            // Small delay between additions
            try await Task.sleep(for: .milliseconds(50))
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Assert: sync completed quickly (should be under 1 second for 5 cigarettes)
        XCTAssertLessThan(duration, 1.0, "Sync should complete quickly for real-time performance")
        
        // Verify final count
        let finalCount = ud.integer(forKey: "todayCount")
        XCTAssertGreaterThanOrEqual(finalCount, 5, "All cigarettes should be synced")
    }
}

