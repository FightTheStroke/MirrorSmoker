//
//  SmokingIntents.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 02/01/25.
//

import AppIntents
import SwiftData
import SwiftUI

// MARK: - Shared Model Container Access
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
extension AppIntent {
    var sharedModelContainer: ModelContainer {
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        
        // Use the same versioned configuration as the main app
        let configuration = ModelConfiguration(
            "MirrorSmokerModel_v2", // Same version as main app
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("Failed to create ModelContainer in Intent: \(error)")
            // Fallback to in-memory container
            let fallbackConfig = ModelConfiguration(
                "MirrorSmokerModel_v2_memory",
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .automatic
            )
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create fallback ModelContainer in Intent: \(error)")
            }
        }
    }
}

// MARK: - Add Cigarette Intent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct AddCigaretteIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Cigarette"
    static var description = IntentDescription("Record a cigarette you just smoked")
    
    static var suggestedInvocationPhrase: String = "I smoked a cigarette"
    
    @Parameter(title: "Tags", description: "Optional tags to add to this cigarette")
    var tags: [String]?
    
    @Parameter(title: "Note", description: "Optional note about this cigarette")
    var note: String?
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let modelContext = ModelContext(sharedModelContainer)
        
        // Create the cigarette record
        let cigarette = Cigarette()
        cigarette.timestamp = Date()
        cigarette.note = note ?? ""
        
        // Handle tags if provided
        if let tagNames = tags, !tagNames.isEmpty {
            var cigaretteTags: [Tag] = []
            
            for tagName in tagNames {
                // Try to find existing tag
                let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == tagName })
                let existingTags = try modelContext.fetch(descriptor)
                
                if let existingTag = existingTags.first {
                    cigaretteTags.append(existingTag)
                } else {
                    // Create new tag with random color
                    let colors = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#FF2D92"]
                    let randomColor = colors.randomElement() ?? "#007AFF"
                    
                    let newTag = Tag(name: tagName, colorHex: randomColor)
                    modelContext.insert(newTag)
                    cigaretteTags.append(newTag)
                }
            }
            
            cigarette.tags = cigaretteTags
        }
        
        // Save the cigarette
        modelContext.insert(cigarette)
        try modelContext.save()
        
        let message = tags?.isEmpty == false ? 
            "Cigarette recorded with tags: \(tags?.joined(separator: ", ") ?? "")" :
            "Cigarette recorded successfully"
            
        return .result(dialog: IntentDialog(stringLiteral: message)) {
            CigaretteRecordedView(timestamp: cigarette.timestamp, tags: tags)
        }
    }
}

// MARK: - Get Today's Count Intent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct GetTodayCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Today's Cigarette Count"
    static var description = IntentDescription("Get the number of cigarettes smoked today")
    
    static var suggestedInvocationPhrase: String = "How many cigarettes did I smoke today"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let modelContext = ModelContext(sharedModelContainer)
        
        // Get today's cigarettes
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: #Predicate { cigarette in
                cigarette.timestamp >= today && cigarette.timestamp < tomorrow
            }
        )
        
        let todaysCigarettes = try modelContext.fetch(descriptor)
        let count = todaysCigarettes.count
        
        let message = count == 0 ? 
            "Great job! You haven't smoked any cigarettes today!" :
            count == 1 ?
            "You've smoked 1 cigarette today." :
            "You've smoked \(count) cigarettes today."
            
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - Get Weekly Stats Intent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct GetWeeklyStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Weekly Smoking Stats"
    static var description = IntentDescription("Get your smoking statistics for this week")
    
    static var suggestedInvocationPhrase: String = "Show my weekly smoking stats"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let modelContext = ModelContext(sharedModelContainer)
        
        // Get this week's cigarettes
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: #Predicate { cigarette in
                cigarette.timestamp >= weekAgo
            }
        )
        
        let weeklyCigarettes = try modelContext.fetch(descriptor)
        let weeklyCount = weeklyCigarettes.count
        let dailyAverage = Double(weeklyCount) / 7.0
        
        let message = weeklyCount == 0 ?
            "Fantastic! You haven't smoked any cigarettes this week!" :
            "This week you've smoked \(weeklyCount) cigarettes, averaging \(String(format: "%.1f", dailyAverage)) per day."
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - Set Quit Goal Intent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct SetQuitGoalIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Quit Goal"
    static var description = IntentDescription("Set your target date to quit smoking")
    
    static var suggestedInvocationPhrase: String = "Set my quit smoking date"
    
    @Parameter(title: "Quit Date", description: "When do you want to quit smoking?")
    var quitDate: Date
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let modelContext = ModelContext(sharedModelContainer)
        
        // Get or create user profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        
        let profile: UserProfile
        if let existingProfile = profiles.first {
            profile = existingProfile
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }
        
        // Update quit date
        profile.quitDate = quitDate
        profile.enableGradualReduction = true
        
        try modelContext.save()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: quitDate)
        
        let message = "Great! Your quit smoking goal is set for \(dateString). You've got this!"
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - Get Motivation Intent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct GetMotivationIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Motivation"
    static var description = IntentDescription("Get a motivational message to help with quitting smoking")
    
    static var suggestedInvocationPhrase: String = "Give me smoking motivation"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let motivationalMessages = [
            "Every cigarette you don't smoke is a victory. Keep going!",
            "Your lungs are already starting to heal. Each smoke-free hour matters.",
            "You're stronger than any craving. This feeling will pass.",
            "Think about all the money you're saving by not smoking today.",
            "Your future self will thank you for the choice you make right now.",
            "Every day smoke-free is a day your body gets healthier.",
            "You've quit before - you can quit again. You have the strength.",
            "The urge to smoke is temporary, but the benefits of quitting are permanent."
        ]
        
        let randomMessage = motivationalMessages.randomElement() ?? motivationalMessages[0]
        
        return .result(dialog: IntentDialog(stringLiteral: randomMessage))
    }
}

// MARK: - App Shortcuts Provider

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct SmokingAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddCigaretteIntent(),
            phrases: [
                "I smoked with \(.applicationName)",
                "Record cigarette in \(.applicationName)",
                "Log smoke in \(.applicationName)"
            ],
            shortTitle: "Record Cigarette",
            systemImageName: "plus.circle"
        )
        
        AppShortcut(
            intent: GetTodayCountIntent(),
            phrases: [
                "How many cigarettes today in \(.applicationName)",
                "Today's count in \(.applicationName)",
                "Show today's smoking in \(.applicationName)"
            ],
            shortTitle: "Today's Count",
            systemImageName: "number"
        )
        
        AppShortcut(
            intent: GetWeeklyStatsIntent(),
            phrases: [
                "Weekly smoking stats in \(.applicationName)",
                "Show my week in \(.applicationName)",
                "This week's progress in \(.applicationName)"
            ],
            shortTitle: "Weekly Stats",
            systemImageName: "chart.bar"
        )
        
        AppShortcut(
            intent: GetMotivationIntent(),
            phrases: [
                "Motivate me in \(.applicationName)",
                "Help me quit smoking with \(.applicationName)",
                "I need motivation in \(.applicationName)"
            ],
            shortTitle: "Get Motivation",
            systemImageName: "heart.fill"
        )
        
        AppShortcut(
            intent: SetQuitGoalIntent(),
            phrases: [
                "Set quit goal in \(.applicationName)",
                "Set my quit date in \(.applicationName)",
                "Plan to quit in \(.applicationName)"
            ],
            shortTitle: "Set Quit Goal",
            systemImageName: "target"
        )
    }
}