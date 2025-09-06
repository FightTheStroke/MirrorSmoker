//
//  GetCoachTipIntent.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import AppIntents
import SwiftData
import os.log

@available(iOS 16.0, *)
struct GetCoachTipIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Coach Tip"
    static var description = IntentDescription("Provides an on-device quit tip now.")
    
    static var suggestedInvocationPhrase: String = "Give me a smoking tip"
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "GetCoachTipIntent")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        Self.logger.info("GetCoachTipIntent invoked")
        
        do {
            // Access shared model container
            let schema = Schema([
                Cigarette.self,
                Tag.self,
                UserProfile.self,
                Product.self,
                Purchase.self,
                UrgeLog.self
            ])
            
            let configuration = ModelConfiguration(
                "MirrorSmokerModel_v2",
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)
            
            // Get user profile
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let userProfile = try context.fetch(profileDescriptor).first
            
            // Get coaching action (force evaluation for manual request)
            let action = await CoachEngine.shared.decide(
                modelContext: context,
                userProfile: userProfile,
                forceEvaluation: true
            )
            
            switch action {
            case .nudge(let text):
                Self.logger.info("Providing coaching tip via intent")
                return .result(dialog: IntentDialog(stringLiteral: text))
                
            case .none:
                // Fallback tip for manual requests
                let fallbackTip = "Take a deep breath. You're stronger than the urge."
                Self.logger.info("Providing fallback tip via intent")
                return .result(dialog: IntentDialog(stringLiteral: fallbackTip))
            }
            
        } catch {
            Self.logger.error("Failed to get coach tip: \(error.localizedDescription)")
            
            // Fallback response
            return .result(dialog: IntentDialog(stringLiteral: "Stay strong. Take it one moment at a time."))
        }
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get an on-device coaching tip for quitting smoking")
    }
    
    // App Shortcuts
    static var shortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: GetCoachTipIntent(),
                phrases: [
                    "Get coaching tip in \(.applicationName)",
                    "Give me quit smoking advice in \(.applicationName)",
                    "Help me resist smoking in \(.applicationName)",
                    "Coach me in \(.applicationName)"
                ],
                shortTitle: "Get Tip",
                systemImageName: "brain.head.profile"
            )
        ]
    }
}

@available(iOS 16.0, *)
struct LogUrgeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Urge"
    static var description = IntentDescription("Log an urge to smoke and get immediate support.")
    
    @Parameter(title: "Intensity", description: "How strong is the urge? (1-10)", default: 5)
    var intensity: Int
    
    @Parameter(title: "Note", description: "Optional note about the urge")
    var note: String?
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "LogUrgeIntent")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        Self.logger.info("LogUrgeIntent invoked with intensity: \(intensity)")
        
        do {
            // Access shared model container
            let schema = Schema([
                Cigarette.self,
                Tag.self,
                UserProfile.self,
                Product.self,
                Purchase.self,
                UrgeLog.self
            ])
            
            let configuration = ModelConfiguration(
                "MirrorSmokerModel_v2",
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)
            
            // Create urge log
            let urgeLog = UrgeLog(
                timestamp: Date(),
                intensity: max(1, min(10, intensity)), // Clamp between 1-10
                note: note ?? "",
                resistanceOutcome: .pending // Initially pending, can be updated later
            )
            
            context.insert(urgeLog)
            try context.save()
            
            // Get immediate coaching tip for high-intensity urges
            if intensity >= 7 {
                let userProfile = try context.fetch(FetchDescriptor<UserProfile>()).first
                let action = await CoachEngine.shared.decide(
                    modelContext: context,
                    userProfile: userProfile,
                    forceEvaluation: true
                )
                
                if case .nudge(let tip) = action {
                    let response = "Urge logged (intensity: \(intensity)/10). \(tip)"
                    return .result(dialog: IntentDialog(stringLiteral: response))
                }
            }
            
            // Standard response for lower intensity urges
            let encouragement = intensity >= 7 ? 
                "That's a strong urge. You can get through this." :
                "Urge noted. You're building awareness - that's powerful."
                
            return .result(dialog: IntentDialog(stringLiteral: "Logged urge (intensity: \(intensity)/10). \(encouragement)"))
            
        } catch {
            Self.logger.error("Failed to log urge: \(error.localizedDescription)")
            return .result(dialog: IntentDialog(stringLiteral: "The urge will pass. You're stronger than you think."))
        }
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log urge with intensity \(\.$intensity)") {
            \.$note
        }
    }
    
    // App Shortcuts
    static var shortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: LogUrgeIntent(),
                phrases: [
                    "Log urge in \(.applicationName)",
                    "I have an urge in \(.applicationName)",
                    "Record craving in \(.applicationName)",
                    "Track urge in \(.applicationName)"
                ],
                shortTitle: "Log Urge",
                systemImageName: "exclamationmark.triangle"
            )
        ]
    }
}
