//
//  JITAIPlanner.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import UserNotifications
import SwiftData
import WidgetKit
import os.log

@MainActor
final class JITAIPlanner: ObservableObject {
    static let shared = JITAIPlanner()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "JITAIPlanner")
    private let coachEngine = CoachEngine.shared
    
    // Configuration
    @Published var isEnabled: Bool = true
    @Published var maxNotificationsPerDay: Int = 3
    @Published var quietHoursStart: Int = 22 // 10 PM
    @Published var quietHoursEnd: Int = 6 // 6 AM
    
    // State tracking
    private var notificationsSentToday: Int = 0
    private var lastNotificationDate: Date?
    
    private init() {
        resetDailyCountIfNeeded()
    }
    
    // MARK: - Main Evaluation Method
    
    func evaluateAndNotify(modelContext: ModelContext? = nil) async {
        guard isEnabled else {
            logger.debug("JITAI is disabled")
            return
        }
        
        resetDailyCountIfNeeded()
        
        guard canSendNotification() else {
            logger.debug("Cannot send notification due to rate limits or quiet hours")
            return
        }
        
        do {
            let context: ModelContext
            if let modelContext = modelContext {
                context = modelContext
            } else {
                context = await createModelContext()
            }
            let userProfile = try await getUserProfile(context: context)
            
            let action = await coachEngine.decide(
                modelContext: context,
                userProfile: userProfile,
                forceEvaluation: false
            )
            
            switch action {
            case .nudge(let tip):
                await sendCoachingNotification(tip: tip)
                await updateWidgetWithTip(tip)
                logger.info("JITAI intervention sent: coaching tip")
                
            case .none:
                logger.debug("No intervention needed at this time")
            }
            
        } catch {
            logger.error("Failed to evaluate JITAI: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Notification Management
    
    private func canSendNotification() -> Bool {
        // Check daily limit
        if notificationsSentToday >= maxNotificationsPerDay {
            return false
        }
        
        // Check quiet hours
        let currentHour = Calendar.current.component(.hour, from: Date())
        if isQuietHour(currentHour) {
            return false
        }
        
        // Check minimum interval (2 hours)
        if let lastDate = lastNotificationDate {
            let timeSinceLastNotification = Date().timeIntervalSince(lastDate)
            if timeSinceLastNotification < 2 * 3600 { // 2 hours
                return false
            }
        }
        
        return true
    }
    
    private func isQuietHour(_ hour: Int) -> Bool {
        if quietHoursStart > quietHoursEnd {
            // Spans midnight (e.g., 22 PM to 6 AM)
            return hour >= quietHoursStart || hour <= quietHoursEnd
        } else {
            return hour >= quietHoursStart && hour <= quietHoursEnd
        }
    }
    
    @MainActor
    private func sendCoachingNotification(tip: String) async {
        do {
            // Request authorization if needed
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            if settings.authorizationStatus != .authorized {
                let granted = try await center.requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                if !granted {
                    logger.warning("Notification authorization denied")
                    return
                }
            }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("jitai.notification.title", comment: "Coach")
            content.body = tip
            content.sound = .default
            content.categoryIdentifier = "COACHING_TIP"
            
            // Add action buttons
            content.userInfo = ["tip": tip, "timestamp": Date().timeIntervalSince1970]
            
            // Schedule immediate notification
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "coaching-tip-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
            
            // Update tracking
            notificationsSentToday += 1
            lastNotificationDate = Date()
            
            logger.info("Coaching notification scheduled successfully")
            
        } catch {
            logger.error("Failed to send coaching notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Widget Integration
    
    private func updateWidgetWithTip(_ tip: String) async {
        // Store the tip for widget consumption
        if let groupContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.fightthestroke.mirrorsmoker"
        ) {
            let tipURL = groupContainer.appendingPathComponent("latest_tip.json")
            
            let tipData: [String: Any] = [
                "tip": tip,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: tipData)
                try jsonData.write(to: tipURL)
                
                // Refresh widget timelines
                WidgetCenter.shared.reloadAllTimelines()
                
                logger.debug("Updated widget with coaching tip")
                
            } catch {
                logger.error("Failed to update widget with tip: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Actions Setup
    
    static func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Define actions
        let understoodAction = UNNotificationAction(
            identifier: "UNDERSTOOD",
            title: NSLocalizedString("jitai.action.understood", comment: "Got it!"),
            options: []
        )
        
        let moreHelpAction = UNNotificationAction(
            identifier: "MORE_HELP",
            title: NSLocalizedString("jitai.action.more.help", comment: "More help"),
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: NSLocalizedString("jitai.action.dismiss", comment: "Not now"),
            options: []
        )
        
        // Create category
        let coachingCategory = UNNotificationCategory(
            identifier: "COACHING_TIP",
            actions: [understoodAction, moreHelpAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        center.setNotificationCategories([coachingCategory])
    }
    
    // MARK: - Configuration
    
    func updateConfiguration(
        enabled: Bool,
        maxNotificationsPerDay: Int,
        quietHoursStart: Int,
        quietHoursEnd: Int
    ) {
        self.isEnabled = enabled
        self.maxNotificationsPerDay = max(1, min(10, maxNotificationsPerDay))
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        
        // Update coach engine quiet hours too
        coachEngine.updateQuietHours(start: quietHoursStart, end: quietHoursEnd)
        
        logger.info("JITAI configuration updated")
    }
    
    // Backward compatibility method
    func updateConfiguration(
        enabled: Bool,
        maxNotificationsPerDay: Int,
        quietHours: ClosedRange<Int>
    ) {
        updateConfiguration(
            enabled: enabled,
            maxNotificationsPerDay: maxNotificationsPerDay,
            quietHoursStart: quietHours.lowerBound,
            quietHoursEnd: quietHours.upperBound
        )
    }
    
    // MARK: - Background Processing
    
    func scheduleBackgroundEvaluation() {
        // This would be called from app lifecycle to set up background processing
        // For now, we rely on app foreground/background transitions
        logger.debug("Background evaluation scheduled")
    }
    
    // MARK: - Utilities
    
    private func resetDailyCountIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastNotificationDate {
            let lastDateDay = calendar.startOfDay(for: lastDate)
            if lastDateDay < today {
                notificationsSentToday = 0
                logger.debug("Reset daily notification count")
            }
        }
    }
    
    private func createModelContext() async -> ModelContext {
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
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            logger.info("Successfully created ModelContainer for JITAI")
            return ModelContext(container)
        } catch {
            logger.warning("Failed to create model context: \(error.localizedDescription)")
            // Return fallback in-memory context
            logger.info("Using fallback in-memory ModelContainer for JITAI")
            let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
            let fallbackContainer = try! ModelContainer(for: schema, configurations: [fallbackConfig])
            return ModelContext(fallbackContainer)
        }
    }
    
    private func getUserProfile(context: ModelContext) async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try context.fetch(descriptor).first
    }
}
