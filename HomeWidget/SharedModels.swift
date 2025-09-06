//
//  SharedModels.swift
//  HomeWidget
//
//  Simplified shared models for widget-app consistency
//

import SwiftData
import Foundation

// MARK: - Cigarette Model (simplified for widget)
@Model
public final class Cigarette {
    public var id: UUID
    public var timestamp: Date
    public var note: String
    public var tags: [Tag]?
    
    public init(timestamp: Date = Date(), note: String = "", tags: [Tag]? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.note = note
        self.tags = tags
    }
}

// MARK: - Tag Model (simplified for widget)  
@Model
public final class Tag {
    public var id: UUID
    public var name: String
    public var colorHex: String  // FIXED: Using colorHex to match main app
    public var createdAt: Date
    public var cigarettes: [Cigarette]?
    
    public init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex  // FIXED: Using colorHex
        self.createdAt = Date()
        self.cigarettes = []
    }
}

// MARK: - UserProfile Model (simplified for widget)
@Model
public final class UserProfile {
    public var id: UUID
    public var name: String
    public var dailyAverage: Double
    public var quitDate: Date?
    public var lastUpdated: Date
    
    public init(name: String = "", 
                dailyAverage: Double = 0.0,
                quitDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.dailyAverage = dailyAverage
        self.quitDate = quitDate
        self.lastUpdated = Date()
    }
}

// MARK: - SmokingType Enum (for compatibility)
public enum SmokingType: String, CaseIterable, Codable {
    case cigarettes = "cigarettes"
    case cigar = "cigar"
    case pipe = "pipe"
    case vape = "vape"
    
    public var displayName: String {
        switch self {
        case .cigarettes: return NSLocalizedString("smoking.type.cigarettes", comment: "")
        case .cigar: return NSLocalizedString("smoking.type.cigar", comment: "")
        case .pipe: return NSLocalizedString("smoking.type.pipe", comment: "")
        case .vape: return NSLocalizedString("smoking.type.vape", comment: "")
        }
    }
}