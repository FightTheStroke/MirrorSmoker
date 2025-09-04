//
//  WidgetManager.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import Foundation
import WidgetKit

@MainActor
class WidgetManager {
    static let shared = WidgetManager()
    
    private init() {}
    
    /// Updates all widget timelines to reflect new data changes
    func updateWidgetData() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Updates specific widget timeline
    func updateSpecificWidget(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}