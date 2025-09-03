//
//  JITAINotificationManager.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation
import UserNotifications
import os.log

// MARK: - JITAI Intervention
struct JITAIIntervention {
    let title: String
    let body: String
    let actionButtons: [InterventionAction]
    let priority: InterventionPriority
    let deliveryTime: Date
    let triggerPrediction: TriggerPrediction
    
    enum InterventionPriority: String, CaseIterable {
        case low = "low"
        case normal = "normal"  
        case high = "high"
        case critical = "critical"
        
        var interruptionLevel: UNNotificationInterruptionLevel {
            switch self {
            case .low: return .passive
            case .normal: return .active
            case .high: return .active
            case .critical: return .timeSensitive
            }
        }
    }
    
    struct InterventionAction {
        let identifier: String
        let title: String
        let isDestructive: Bool
        let icon: String?
        
        static let breathe = InterventionAction(
            identifier: "breathe",
            title: "jitai.action.breathe".local(),
            isDestructive: false,
            icon: "wind"
        )
        
        static let distract = InterventionAction(
            identifier: "distract", 
            title: "jitai.action.distract".local(),
            isDestructive: false,
            icon: "gamecontroller"
        )
        
        static let remind = InterventionAction(
            identifier: "remind",
            title: "jitai.action.remind".local(), 
            isDestructive: false,
            icon: "heart"
        )
        
        static let dismiss = InterventionAction(
            identifier: "dismiss",
            title: "jitai.action.dismiss".local(),
            isDestructive: true,
            icon: "xmark"
        )
    }
}

// MARK: - JITAI Notification Manager
@available(iOS 17.0, *)
@MainActor
final class JITAINotificationManager: ObservableObject {
    static let shared = JITAINotificationManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "JITAINotificationManager")
    private let coachEngine = CoachEngine.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Configuration
    @Published var isEnabled: Bool = true
    @Published var maxDailyInterventions: Int = 5
    @Published var quietHoursEnabled: Bool = true
    @Published var quietHoursStart: Int = 22  // 10 PM
    @Published var quietHoursEnd: Int = 7     // 7 AM
    @Published var minimumIntervalMinutes: Int = 30 // Minimum time between interventions
    
    // MARK: - State Tracking
    private var interventionsSentToday: Int = 0
    private var lastInterventionTime: Date?
    private var scheduledInterventions: Set<String> = []
    
    private init() {
        setupNotificationActions()
        resetDailyCounters()
    }
    
    // MARK: - Public Methods
    
    func scheduleJITAIntervention(for prediction: TriggerPrediction) async {
        guard await checkJITAIEnabled() else {
            logger.info("JITAI disabled, skipping intervention")
            return
        }
        
        guard canScheduleIntervention() else {
            logger.info("Cannot schedule intervention - limits reached or too frequent")
            return
        }
        
        do {
            let intervention = await generateJITAIIntervention(prediction)
            try await scheduleNotification(for: intervention)
            
            interventionsSentToday += 1
            lastInterventionTime = Date()
            
            logger.info("Scheduled JITAI intervention for trigger: \(prediction.trigger.name)")
        } catch {
            logger.error("Failed to schedule JITAI intervention: \(error.localizedDescription)")
        }
    }
    
    func handleInterventionAction(_ actionIdentifier: String, interventionId: String) async {
        logger.info("Handling JITAI action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "breathe":
            await handleBreatheAction()
        case "distract":
            await handleDistractionAction()
        case "remind":
            await handleRemindAction()
        case "dismiss":
            await handleDismissAction()
        default:
            logger.warning("Unknown JITAI action: \(actionIdentifier)")
        }
        
        // Remove scheduled intervention
        scheduledInterventions.remove(interventionId)
    }
    
    func cancelAllScheduledInterventions() async {
        notificationCenter.removeAllPendingNotificationRequests()
        scheduledInterventions.removeAll()
        logger.info("Cancelled all scheduled JITAI interventions")
    }
    
    // MARK: - Private Methods
    
    private func checkJITAIEnabled() async -> Bool {
        // Check user preference
        guard isEnabled else { return false }
        
        // Check notification permissions
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    private func canScheduleIntervention() -> Bool {
        // Check daily limit
        guard interventionsSentToday < maxDailyInterventions else {
            logger.info("Daily intervention limit reached")
            return false
        }
        
        // Check minimum interval
        if let lastTime = lastInterventionTime {
            let timeSince = Date().timeIntervalSince(lastTime)
            let minimumInterval = TimeInterval(minimumIntervalMinutes * 60)
            guard timeSince >= minimumInterval else {
                logger.info("Minimum interval not met since last intervention")
                return false
            }
        }
        
        // Check quiet hours
        if quietHoursEnabled && isInQuietHours() {
            logger.info("In quiet hours, skipping intervention")
            return false
        }
        
        return true
    }
    
    private func isInQuietHours() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if quietHoursStart < quietHoursEnd {
            // Normal range (e.g., 22:00 - 07:00)
            return hour >= quietHoursStart && hour < quietHoursEnd
        } else {
            // Overnight range (e.g., 22:00 - 07:00 next day)  
            return hour >= quietHoursStart || hour < quietHoursEnd
        }
    }
    
    private func generateJITAIIntervention(_ prediction: TriggerPrediction) async -> JITAIIntervention {
        let trigger = prediction.trigger
        let timeRelevance = getCurrentTimeRelevance()
        
        // Generate contextual intervention based on trigger type and time
        let (title, body) = generateInterventionContent(for: trigger, timeRelevance: timeRelevance, riskScore: prediction.riskScore)
        
        let actions: [JITAIIntervention.InterventionAction] = [
            .breathe, .distract, .remind, .dismiss
        ]
        
        let priority: JITAIIntervention.InterventionPriority = {
            switch prediction.riskScore {
            case 0.0..<0.3: return .low
            case 0.3..<0.6: return .normal
            case 0.6..<0.8: return .high
            default: return .critical
            }
        }()
        
        return JITAIIntervention(
            title: title,
            body: body,
            actionButtons: actions,
            priority: priority,
            deliveryTime: prediction.predictedTime,
            triggerPrediction: prediction
        )
    }
    
    private func generateInterventionContent(for trigger: Trigger, timeRelevance: PersonalizationContext.TimeRelevance, riskScore: Double) -> (String, String) {
        let triggerType = trigger.type
        let intensity = riskScore
        
        var title: String
        var body: String
        
        switch triggerType {
        case .emotional:
            if intensity > 0.7 {
                title = "jitai.emotional.high.title".local()
                body = "jitai.emotional.high.body".local()
            } else {
                title = "jitai.emotional.moderate.title".local()
                body = "jitai.emotional.moderate.body".local()
            }
        case .social:
            title = "jitai.social.title".local()
            body = "jitai.social.body".local()
        case .situational:
            title = "jitai.situational.title".local()
            body = "jitai.situational.body".local()
        case .temporal:
            switch timeRelevance {
            case .morning:
                title = "jitai.temporal.morning.title".local()
                body = "jitai.temporal.morning.body".local()
            case .afternoon:
                title = "jitai.temporal.afternoon.title".local() 
                body = "jitai.temporal.afternoon.body".local()
            case .evening:
                title = "jitai.temporal.evening.title".local()
                body = "jitai.temporal.evening.body".local()
            case .night:
                title = "jitai.temporal.night.title".local()
                body = "jitai.temporal.night.body".local()
            }
        case .physical:
            title = "jitai.physical.title".local()
            body = "jitai.physical.body".local()
        }
        
        return (title, body)
    }
    
    private func getCurrentTimeRelevance() -> PersonalizationContext.TimeRelevance {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
    
    private func scheduleNotification(for intervention: JITAIIntervention) async throws {
        let content = UNMutableNotificationContent()
        content.title = intervention.title
        content.body = intervention.body
        content.sound = .default
        content.interruptionLevel = intervention.priority.interruptionLevel
        
        // Add action buttons
        let actions = intervention.actionButtons.map { action in
            UNNotificationAction(
                identifier: action.identifier,
                title: action.title,
                options: action.isDestructive ? [.destructive] : []
            )
        }
        
        let categoryIdentifier = "JITAI_INTERVENTION"
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifier
        
        // Schedule notification
        let timeInterval = intervention.deliveryTime.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: false)
        
        let requestId = intervention.triggerPrediction.id.uuidString
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            scheduledInterventions.insert(requestId)
        } catch {
            logger.error("Failed to schedule JITAI notification: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func setupNotificationActions() {
        // This will be called when the app starts to register actions
        logger.info("Setting up JITAI notification actions")
    }
    
    private func resetDailyCounters() {
        // Reset counters at midnight
        let now = Date()
        let calendar = Calendar.current
        
        if let lastReset = lastInterventionTime {
            let isNewDay = !calendar.isDate(lastReset, inSameDayAs: now)
            if isNewDay {
                interventionsSentToday = 0
                logger.info("Reset daily intervention counter")
            }
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleBreatheAction() async {
        logger.info("User chose breathing exercise intervention")
        // Could open breathing exercise screen or provide quick breathing guide
    }
    
    private func handleDistractionAction() async {
        logger.info("User chose distraction intervention")
        // Could open alternative activity suggestions
    }
    
    private func handleRemindAction() async {
        logger.info("User chose motivation reminder intervention")
        // Could show their personal "why" statements
    }
    
    private func handleDismissAction() async {
        logger.info("User dismissed JITAI intervention")
        // Track dismissal for learning purposes
    }
}