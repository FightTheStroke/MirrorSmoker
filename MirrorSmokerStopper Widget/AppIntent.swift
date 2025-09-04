//
//  AppIntent.swift
//  MirrorStokerStopper Widget
//
//  Created by Roberto D’Angelo on 01/09/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "widget.configuration.title"
    static var description: IntentDescription = "widget.configuration.description"

    // An example configurable parameter.
    @Parameter(title: "widget.configuration.parameter.title", default: "😃")
    var favoriteEmoji: String
}
