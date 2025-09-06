import XCTest
@testable import MirrorSmokerStopper

final class WidgetSyncIntegrationTests: XCTestCase {
    let groupID = "group.fightthestroke.mirrorsmoker"

    func testPendingWidgetActionsProcessing() throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: enqueue two pending timestamps
        let now = Date().timeIntervalSince1970
        ud.set([now - 60, now], forKey: "widget_pending_cigarettes")

        // Act: process pending
        PendingWidgetActionsManager.shared.processPendingIfAny()

        // Assert: queue cleared and lastUpdated bumped
        let pending = ud.array(forKey: "widget_pending_cigarettes") as? [Double]
        XCTAssertTrue(pending == nil || pending?.isEmpty == true, "Pending queue should be cleared")
        XCTAssertNotNil(ud.object(forKey: "lastUpdated"), "lastUpdated should be set after processing")
    }

    func testSharedSnapshotUpdatesAfterFullSync() throws {
        guard let ud = UserDefaults(suiteName: groupID) else {
            throw XCTSkip("App Group UserDefaults not available in test environment")
        }

        // Arrange: insert one cigarette into the shared model
        let context = PersistenceController.shared.container.mainContext
        let cig = Cigarette(timestamp: Date(), note: "Test from unit test")
        context.insert(cig)
        try context.save()

        // Act: perform full sync to export snapshot for widgets/watch
        SyncCoordinator.shared.performFullSync()

        // Give a tiny delay for async task
        let exp = expectation(description: "wait for sync")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)

        // Assert: todayCount exported
        let todayCount = ud.integer(forKey: "todayCount")
        XCTAssertGreaterThanOrEqual(todayCount, 1, "todayCount should be >= 1 after saving a cigarette and syncing")
    }
}

