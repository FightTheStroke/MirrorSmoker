//
//  MirrorStokerStopper_WidgetLiveActivity.swift
//  MirrorStokerStopper Widget
//
//  Created by Roberto D’Angelo on 01/09/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mirrorsmokerwidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mirrorsmokerwidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mirrorsmokerwidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension mirrorsmokerwidgetAttributes {
    fileprivate static var preview: mirrorsmokerwidgetAttributes {
        mirrorsmokerwidgetAttributes(name: "World")
    }
}

extension mirrorsmokerwidgetAttributes.ContentState {
    fileprivate static var smiley: mirrorsmokerwidgetAttributes.ContentState {
        mirrorsmokerwidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mirrorsmokerwidgetAttributes.ContentState {
         mirrorsmokerwidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mirrorsmokerwidgetAttributes.preview) {
   mirrorsmokerwidgetLiveActivity()
} contentStates: {
    mirrorsmokerwidgetAttributes.ContentState.smiley
    mirrorsmokerwidgetAttributes.ContentState.starEyes
}
