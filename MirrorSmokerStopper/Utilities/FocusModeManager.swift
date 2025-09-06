//
//  FocusModeManager.swift
//  MirrorSmokerStopper
//
//  Manages Focus Mode detection and smart notification timing
//

import Foundation
import Intents
import UserNotifications
import os.log

/// Manager for detecting system Focus Mode and Sleep Schedule
@MainActor
final class FocusModeManager: ObservableObject {
    static let shared = FocusModeManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "FocusMode")
    
    // MARK: - Published Properties
    
    @Published var currentFocusState: FocusState = .available
    @Published var isDoNotDisturbActive = false
    @Published var isSleepModeActive = false
    @Published var isDrivingModeActive = false
    @Published var notificationPriority: NotificationPriority = .standard
    
    // MARK: - Types
    
    enum FocusState {
        case available
        case doNotDisturb
        case sleep
        case driving
        case work
        case personal
        
        var allowsStandardNotifications: Bool {
            switch self {
            case .available, .personal:
                return true
            case .doNotDisturb, .sleep, .driving, .work:
                return false
            }
        }
        
        var allowsCriticalNotifications: Bool {
            switch self {
            case .available, .personal, .work:
                return true
            case .doNotDisturb, .sleep, .driving:
                return false  // Only breakthrough notifications
            }
        }
        
        var description: String {
            switch self {
            case .available:
                return "Available"
            case .doNotDisturb:
                return "Do Not Disturb"
            case .sleep:
                return "Sleep Mode"
            case .driving:
                return "Driving Mode"
            case .work:
                return "Work Focus"
            case .personal:
                return "Personal Time"
            }
        }
    }
    
    enum NotificationPriority {
        case standard    // Respect all Focus Modes
        case important   // Break through some Focus Modes
        case critical    // Emergency interventions only
        
        func shouldNotify(in focusState: FocusState) -> Bool {
            switch self {
            case .standard:
                return focusState.allowsStandardNotifications
            case .important:
                return focusState.allowsCriticalNotifications
            case .critical:
                return true  // Always notify for critical interventions
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        setupFocusDetection()
        observeNotificationSettings()
    }
    
    // MARK: - Focus Mode Detection
    
    private func setupFocusDetection() {
        // Monitor Focus status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(focusStatusChanged),
            name: INFocusStatusCenter.didUpdateNotification,
            object: nil
        )
        
        // Check initial status
        Task {
            await checkCurrentFocusStatus()
        }
    }
    
    @objc private func focusStatusChanged(_ notification: Notification) {
        Task {
            await checkCurrentFocusStatus()
        }
    }
    
    private func checkCurrentFocusStatus() async {
        let focusStatusCenter = INFocusStatusCenter()
        let authStatus = focusStatusCenter.authorizationStatus
        
        // Determine current focus state based on authorization
        switch authStatus {
        case .authorized:
            // When authorized, we can check if focus is enabled
            let status = focusStatusCenter.focusStatus
            // In iOS 15+, we only know if Focus is on, not the specific type
            // We'll treat any focus mode as Do Not Disturb for simplicity
            currentFocusState = .doNotDisturb
            isDoNotDisturbActive = true
            isSleepModeActive = false
            isDrivingModeActive = false
        case .notDetermined, .restricted, .denied:
            currentFocusState = .available
            isDoNotDisturbActive = false
            isSleepModeActive = false
            isDrivingModeActive = false
        @unknown default:
            currentFocusState = .available
            isDoNotDisturbActive = false
            isSleepModeActive = false
            isDrivingModeActive = false
        }
        
        logger.info("Focus state changed to: \(self.currentFocusState.description)")
    }
    
    // MARK: - Activity Context Detection
    
    func detectActivityContext() -> ActivityContext {
        // Combine multiple signals to determine activity
        if isDrivingModeActive {
            return .driving
        }
        
        if isSleepModeActive {
            return .sleeping
        }
        
        // Check time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<9:
            return .morningRoutine
        case 9..<12:
            return .workMorning
        case 12..<13:
            return .lunch
        case 13..<17:
            return .workAfternoon
        case 17..<19:
            return .commute
        case 19..<22:
            return .evening
        default:
            return .night
        }
    }
    
    enum ActivityContext {
        case sleeping
        case morningRoutine
        case workMorning
        case lunch
        case workAfternoon
        case commute
        case evening
        case night
        case driving
        
        var isGoodTimeForIntervention: Bool {
            switch self {
            case .sleeping, .driving:
                return false
            case .morningRoutine, .commute:
                return true  // High stress times
            case .workMorning, .workAfternoon:
                return true  // Can take breaks
            case .lunch, .evening, .night:
                return true  // Available times
            }
        }
        
        var suggestedInterventionType: String {
            switch self {
            case .sleeping, .driving:
                return "none"
            case .morningRoutine:
                return "breathing"  // Quick morning stress relief
            case .workMorning, .workAfternoon:
                return "microbreak"  // Short work breaks
            case .lunch:
                return "walk"  // Physical activity
            case .commute:
                return "mindfulness"  // Mental exercises
            case .evening:
                return "reflection"  // Daily review
            case .night:
                return "relaxation"  // Wind down
            }
        }
    }
    
    // MARK: - Smart Notification Timing
    
    func shouldSendNotification(
        priority: NotificationPriority,
        interventionType: HeartRateIntervention? = nil
    ) -> Bool {
        // Check Focus Mode compatibility
        let focusAllows = priority.shouldNotify(in: currentFocusState)
        
        // Check activity context
        let activityContext = detectActivityContext()
        let contextAllows = activityContext.isGoodTimeForIntervention
        
        // Critical notifications always go through
        if priority == .critical {
            return true
        }
        
        // For standard notifications, respect both Focus Mode and context
        if priority == .standard {
            return focusAllows && contextAllows
        }
        
        // Important notifications respect Focus Mode but can override context
        return focusAllows
    }
    
    func determineNotificationPriority(
        for intervention: HeartRateIntervention,
        cravingRisk: HeartRateCoachingEngine.CravingRisk,
        stressLevel: HeartRateCoachingEngine.StressLevel
    ) -> NotificationPriority {
        // Critical: High risk situations
        if cravingRisk == .imminent || stressLevel == .high {
            return .critical
        }
        
        // Important: Medium risk or elevated stress
        if cravingRisk == .high || stressLevel == .elevated {
            return .important
        }
        
        // Standard: Low risk coaching
        return .standard
    }
    
    // MARK: - Notification Settings
    
    private func observeNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.processNotificationSettings(settings)
            }
        }
    }
    
    private func processNotificationSettings(_ settings: UNNotificationSettings) {
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            logger.info("Notifications authorized")
        case .denied:
            logger.warning("Notifications denied - coach effectiveness reduced")
        case .notDetermined:
            // Request authorization
            Task {
                await requestNotificationAuthorization()
            }
        @unknown default:
            break
        }
        
        // Check critical alert authorization for breakthrough notifications
        if settings.criticalAlertSetting == .enabled {
            logger.info("Critical alerts enabled - can send breakthrough notifications")
        }
    }
    
    private func requestNotificationAuthorization() async {
        do {
            let authorized = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .criticalAlert]
            )
            
            if authorized {
                logger.info("Notification authorization granted")
            }
        } catch {
            logger.error("Failed to request notification authorization: \(error)")
        }
    }
    
    // MARK: - Integration with JITAI
    
    func updateJITAIWithFocusState() {
        let jitai = JITAIPlanner.shared
        
        // Adjust intervention timing based on Focus Mode
        let interventionEnabled = currentFocusState.allowsStandardNotifications
        
        if !interventionEnabled {
            logger.info("JITAI interventions paused due to Focus Mode: \(self.currentFocusState.description)")
        }
        
        // Update JITAI configuration
        jitai.updateConfiguration(
            enabled: interventionEnabled && AIConfiguration.shared.isAICoachingEnabled,
            maxNotificationsPerDay: AIConfiguration.shared.maxDailyNotifications,
            quietHours: determineQuietHours()
        )
    }
    
    private func determineQuietHours() -> ClosedRange<Int> {
        // Combine user preferences with Focus Mode detection
        let aiConfig = AIConfiguration.shared
        
        if isSleepModeActive {
            // Respect sleep mode regardless of settings
            return 0...23  // No notifications during sleep
        }
        
        if aiConfig.quietHoursEnabled {
            return aiConfig.quietHoursRange
        }
        
        // No quiet hours if not configured
        return 25...25  // Invalid range means no quiet hours
    }
}

// MARK: - Intent Types (iOS 16+)

private protocol INSleepIntent {}
private protocol INDrivingIntent {}
private protocol INWorkIntent {}
private protocol INPersonalIntent {}

// MARK: - Focus Status Center

extension INFocusStatusCenter {
    static let didUpdateNotification = Notification.Name("INFocusStatusCenterDidUpdate")
}