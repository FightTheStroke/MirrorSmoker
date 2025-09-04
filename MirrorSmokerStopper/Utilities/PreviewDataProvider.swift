//
//  PreviewDataProvider.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData

@MainActor
final class PreviewDataProvider {
    static let shared = PreviewDataProvider()
    
    lazy var previewContainer: ModelContainer = {
        do {
            let schema = Schema([
                Cigarette.self,
                Tag.self,
                UserProfile.self,
                Product.self,
                UrgeLog.self
            ])
            
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: true
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // Add sample data for previews
            addSampleData(to: container)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
    
    private init() {}
    
    private func addSampleData(to container: ModelContainer) {
        let context = ModelContext(container)
        
        // Create sample tags
        let stressTag = Tag(name: "Stress", colorHex: "#FF4444")
        let socialTag = Tag(name: "Social", colorHex: "#44FF44")
        let workTag = Tag(name: "Work", colorHex: "#4444FF")
        
        context.insert(stressTag)
        context.insert(socialTag)
        context.insert(workTag)
        
        // Create sample user profile
        let profile = UserProfile(
            name: "John Doe",
            birthDate: Calendar.current.date(byAdding: .year, value: -35, to: Date()),
            weight: 75.0,
            smokingType: .cigarettes,
            startedSmokingAge: 18,
            quitDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            enableGradualReduction: true,
            dailyAverage: 15.0
        )
        context.insert(profile)
        
        // Create sample cigarettes
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let cigarettesForDay = max(0, Int.random(in: 0...20))
            
            for _ in 0..<cigarettesForDay {
                let time = calendar.date(byAdding: .hour, value: Int.random(in: 0...23), to: calendar.startOfDay(for: date))!
                let cigarette = Cigarette(timestamp: time)
                
                // Add random tags
                if Bool.random() {
                    cigarette.tags = [stressTag]
                } else if Bool.random() {
                    cigarette.tags = [socialTag]
                } else if Bool.random() {
                    cigarette.tags = [workTag]
                }
                
                context.insert(cigarette)
            }
        }
        
        // Create sample urge logs
        for i in 0..<10 {
            let date = calendar.date(byAdding: .hour, value: -i * 6, to: now)!
            let urgeLog = UrgeLog(
                timestamp: date,
                intensity: Int.random(in: 1...10),
                resistanceOutcome: Bool.random() ? .resisted : .smoked
            )
            context.insert(urgeLog)
        }
        
        try? context.save()
    }
    
    // Static convenience property
    static var previewContainer: ModelContainer {
        shared.previewContainer
    }
}