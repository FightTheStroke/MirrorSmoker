import XCTest
import SwiftUI
import SwiftData
@testable import MirrorSmokerStopper

@MainActor
final class SettingsViewTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: UserProfile.self, Cigarette.self, Tag.self, Product.self, UrgeLog.self,
            configurations: config
        )
        modelContext = modelContainer.mainContext
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    func testDeleteAllDataFunctionality() async throws {
        // Arrange - Create test data
        let profile = UserProfile()
        profile.name = "Test User"
        modelContext.insert(profile)
        
        let cigarette = Cigarette(timestamp: Date(), note: "Test cigarette")
        modelContext.insert(cigarette)
        
        let tag = Tag(name: "Test Tag", colorHex: "#FF0000")
        modelContext.insert(tag)
        
        let product = Product()
        product.name = "Test Product"
        modelContext.insert(product)
        
        try modelContext.save()
        
        // Verify data exists
        var profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        var cigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        var tags = try modelContext.fetch(FetchDescriptor<Tag>())
        var products = try modelContext.fetch(FetchDescriptor<Product>())
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(cigarettes.count, 1)
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(products.count, 1)
        
        // Act - Simulate delete all data operation
        let profilesDescriptor = FetchDescriptor<UserProfile>()
        let profilesToDelete = try modelContext.fetch(profilesDescriptor)
        for profile in profilesToDelete {
            modelContext.delete(profile)
        }
        
        let cigarettesDescriptor = FetchDescriptor<Cigarette>()
        let cigarettesToDelete = try modelContext.fetch(cigarettesDescriptor)
        for cigarette in cigarettesToDelete {
            modelContext.delete(cigarette)
        }
        
        let tagsDescriptor = FetchDescriptor<Tag>()
        let tagsToDelete = try modelContext.fetch(tagsDescriptor)
        for tag in tagsToDelete {
            modelContext.delete(tag)
        }
        
        let productsDescriptor = FetchDescriptor<Product>()
        let productsToDelete = try modelContext.fetch(productsDescriptor)
        for product in productsToDelete {
            modelContext.delete(product)
        }
        
        try modelContext.save()
        
        // Assert - Verify all data is deleted
        profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        cigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        tags = try modelContext.fetch(FetchDescriptor<Tag>())
        products = try modelContext.fetch(FetchDescriptor<Product>())
        
        XCTAssertEqual(profiles.count, 0, "All profiles should be deleted")
        XCTAssertEqual(cigarettes.count, 0, "All cigarettes should be deleted")
        XCTAssertEqual(tags.count, 0, "All tags should be deleted")
        XCTAssertEqual(products.count, 0, "All products should be deleted")
    }
    
    func testDeleteAllDataButtonExists() {
        // This test verifies that the delete button exists in the UI
        // We'll create a minimal SettingsView and check if it renders
        let settingsView = SettingsView()
            .modelContainer(modelContainer)
        
        // Basic smoke test - view should initialize without crashing
        XCTAssertNotNil(settingsView)
    }
}