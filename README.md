# Mirror Smoker

A privacy-first, super simple, open-source cigarette tracking app for iOS and watchOS built with SwiftUI and SwiftData, aimining to help people reduce their cigarette consumption, ane eventually quit smoking. It supports iCloud sync, widgets, Siri/App Shortcuts, tagging, and advanced analytics to help you understand patterns and reduce consumption.

- iOS 17+ and watchOS 10+
- SwiftUI + SwiftData (CloudKit)
- App Intents (Siri + Shortcuts)
- Widget Extension (quick add)
- Tagging system
- Advanced analytics (weekday, hour, tags)
- English and Italian localization

## Features

- One-tap logging from the Home/Lock Screen widget
- “Hey Siri, I smoked a cigarette” (EN/IT) using App Intents
- iCloud sync across iPhone and Apple Watch
- Tagging (e.g., work, stress, coding) with tag-based insights
- Weekly and advanced analytics (weekday/hour heatmap)
- Motivation engine (WIP)
- Optional Sign in with Apple and a simple profile

## Getting Started

1. Open the project in Xcode 15+.
2. Set your Bundle Identifiers for:
   - App
   - Widget Extension
   - Watch app (if added)
3. Enable capabilities:
   - iCloud (CloudKit)
   - Sign in with Apple (optional)
4. Run the app on iOS 17+ or watchOS 10+.

## Siri & Shortcuts

- AddCigaretteIntent powers voice phrases in English and Italian (e.g., “I smoked a cigarette in Mirror Smoker”, “Ho fumato una sigaretta in Mirror Smoker”).
- You can also add tags via Shortcuts by passing a list of tag names.

## Widget

- “Mirror Smoker Widget” shows today’s count and has a prominent button to log a cigarette via the intent.

## Contributing

Please see CONTRIBUTING.md and CODE_OF_CONDUCT.md. We welcome issues and PRs.

## License

MIT © www.fightthestroke.org — contact: roberdan@fightthestroke.org

