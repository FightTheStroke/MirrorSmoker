//
//  UrgeLog.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData

enum ResistanceOutcome: String, CaseIterable, Codable {
    case pending = "pending"
    case resisted = "resisted"
    case smoked = "smoked"
    case partiallyResisted = "partiallyResisted"
    
    var displayName: String {
        switch self {
        case .pending:
            return NSLocalizedString("urge.outcome.pending", comment: "")
        case .resisted:
            return NSLocalizedString("urge.outcome.resisted", comment: "")
        case .smoked:
            return NSLocalizedString("urge.outcome.smoked", comment: "")
        case .partiallyResisted:
            return NSLocalizedString("urge.outcome.partial", comment: "")
        }
    }
    
    var color: String {
        switch self {
        case .pending:
            return "#FFA500" // Orange
        case .resisted:
            return "#34C759" // Green
        case .smoked:
            return "#FF3B30" // Red
        case .partiallyResisted:
            return "#007AFF" // Blue
        }
    }
}

@Model
final class UrgeLog: Sendable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var intensity: Int = 5 // Scale of 1-10
    var note: String = ""
    private var resistanceOutcomeRaw: String = ResistanceOutcome.pending.rawValue
    var duration: TimeInterval = 0 // Duration of the urge in seconds
    var triggers: [String] = [] // Context/triggers that caused the urge
    var copingStrategies: [String] = [] // Strategies used to cope
    
    // Computed property for enum access
    var resistanceOutcome: ResistanceOutcome {
        get {
            return ResistanceOutcome(rawValue: resistanceOutcomeRaw) ?? .pending
        }
        set {
            resistanceOutcomeRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int = 5,
        note: String = "",
        resistanceOutcome: ResistanceOutcome = .pending,
        duration: TimeInterval = 0,
        triggers: [String] = [],
        copingStrategies: [String] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = max(1, min(10, intensity)) // Clamp between 1-10
        self.note = note
        self.resistanceOutcomeRaw = resistanceOutcome.rawValue
        self.duration = duration
        self.triggers = triggers
        self.copingStrategies = copingStrategies
    }
    
    // Computed properties for analysis
    var isResolved: Bool {
        resistanceOutcome != .pending
    }
    
    var wasSuccessful: Bool {
        resistanceOutcome == .resisted || resistanceOutcome == .partiallyResisted
    }
    
    var intensityLevel: String {
        switch intensity {
        case 1...3:
            return NSLocalizedString("urge.intensity.low", comment: "")
        case 4...6:
            return NSLocalizedString("urge.intensity.medium", comment: "")
        case 7...8:
            return NSLocalizedString("urge.intensity.high", comment: "")
        case 9...10:
            return NSLocalizedString("urge.intensity.extreme", comment: "")
        default:
            return NSLocalizedString("urge.intensity.unknown", comment: "")
        }
    }
}