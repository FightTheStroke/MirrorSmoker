//
//  WidgetModels.swift
//  HomeWidget
//
//  Created by Assistant on 02/09/25.
//

import SwiftData
import Foundation

// MARK: - Cigarette Model for Widget
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

// MARK: - Tag Model for Widget
@Model
public final class Tag {
    public var id: UUID
    public var name: String
    public var color: String
    public var isActive: Bool
    public var createdAt: Date
    public var cigarettes: [Cigarette]?
    
    public init(name: String, color: String = "#007AFF", isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.isActive = isActive
        self.createdAt = Date()
        self.cigarettes = []
    }
}

// MARK: - UserProfile Model for Widget
@Model
public final class UserProfile {
    public var id: UUID
    public var name: String
    public var birthDate: Date?
    public var weight: Double
    public var smokingType: SmokingType
    public var startedSmokingAge: Int
    public var dailyAverage: Double
    public var quitDate: Date?
    public var enableGradualReduction: Bool
    public var lastUpdated: Date
    
    public init(name: String = "", 
                birthDate: Date? = nil, 
                weight: Double = 0.0,
                smokingType: SmokingType = .cigarettes,
                startedSmokingAge: Int = 18,
                dailyAverage: Double = 0.0,
                quitDate: Date? = nil,
                enableGradualReduction: Bool = true) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.weight = weight
        self.smokingType = smokingType
        self.startedSmokingAge = startedSmokingAge
        self.dailyAverage = dailyAverage
        self.quitDate = quitDate
        self.enableGradualReduction = enableGradualReduction
        self.lastUpdated = Date()
    }
}

// MARK: - SmokingType for Widget
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
    
    public var icon: String {
        switch self {
        case .cigarettes: return "lungs.fill"
        case .cigar: return "smoke.fill"
        case .pipe: return "flame.fill"
        case .vape: return "cloud.fill"
        }
    }
}