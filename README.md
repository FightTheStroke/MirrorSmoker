# Mirror Smoker 🚭

A privacy-first, open-source cigarette tracking app for iOS and watchOS designed to help users monitor their smoking habits and work towards reducing consumption. Built with SwiftUI, SwiftData, and CloudKit for seamless synchronization across all devices.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![watchOS](https://img.shields.io/badge/watchOS-10.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Key Features

### Core Functionality
- **One-tap logging**: Quick cigarette tracking with timestamp
- **Tag system**: Categorize cigarettes by context (work, stress, social, etc.)
- **iCloud sync**: Seamless data synchronization across iPhone and Apple Watch
- **Privacy-first**: All data stays on your devices and iCloud

### Smart Integrations
- **Siri support**: "Hey Siri, I smoked a cigarette" in all supported languages
- **Widget support**: ✅ Implemented - Small and medium home screen widgets with real-time sync
- **App Shortcuts**: Custom shortcuts integration with iOS 17+ App Intents
- **Watch app**: Native Apple Watch experience with sync capabilities
- **App Groups**: Seamless data synchronization between main app and widget extension

### Analytics & Insights
- **Daily/Weekly stats**: Track your progress over time
- **Pattern recognition**: Understand when and why you smoke most
- **Tag analytics**: See which situations trigger smoking
- **Visual charts**: Beautiful, interactive data visualization
- **Trend analysis**: Monitor your reduction progress

### Localization
- **Multi-language**: English, Italian, Spanish, French, and German support
- **Fully localized**: All UI elements, widget text, and Siri integration
- **Expandable**: Easy to add new languages

## 📱 Screenshots

[Screenshots would go here in a real project]

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ / watchOS 10.0+
- Apple Developer account (for device testing and App Store distribution)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mirror-smoker.git
   cd mirror-smoker
   ```

2. **Open in Xcode**
   ```bash
   open MirrorSmokerStopper.xcodeproj
   ```

3. **Configure Bundle Identifiers**
   - Main app: `com.yourteam.mirrorsmoker`
   - Widget extension: `com.yourteam.mirrorsmoker.widget`
   - Watch app: `com.yourteam.mirrorsmoker.watchapp`

4. **Enable Capabilities**
   - iCloud (CloudKit) for data synchronization
   - App Groups for widget/app data sharing
   - Sign in with Apple (optional)

5. **Build and Run**
   - Select your target device
   - Build and run the project (⌘+R)

### First Launch Setup

1. Grant necessary permissions (notifications, Siri)
2. Optionally create a user profile
3. Start logging your cigarettes
4. Add widgets to your Home screen for quick access

### Widget Setup

The app includes home screen widgets that allow quick cigarette logging:

- **Small Widget**: Shows today's cigarette count with color-coded status and quick add button
- **Medium Widget**: Displays today's count, last cigarette time, daily average, and add button
- **Real-time Sync**: Changes in the app appear in widgets instantly and vice versa
- **Localized**: Widget text adapts to your device language automatically

To add widgets:
1. Long press on your home screen
2. Tap the "+" button
3. Search for "MirrorSmoker Tracker"
4. Choose your preferred size and add to home screen

## 🏗️ Architecture

### Technology Stack
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Core Data successor for data persistence
- **CloudKit**: Apple's cloud database for sync
- **App Intents**: Siri and Shortcuts integration
- **WidgetKit**: Home screen widgets

### Data Models
- `Cigarette`: Core smoking event with timestamp and tags
- `Tag`: Categorization system for different contexts
- `UserProfile`: Optional user information and preferences
- `Product`: Cigarette brands and types (future feature)

### Project Structure
```
MirrorSmokerStopper/
├── Models/           # SwiftData models (Cigarette, Tag, UserProfile, Product)
├── Views/            # SwiftUI views
│   ├── Components/   # Reusable UI components
│   ├── Statistics/   # Analytics and charts
│   └── Settings/     # Settings and configuration views
├── Utilities/        # Helper classes and extensions
│   ├── DesignSystem/ # App-wide design system (DS)
│   ├── AppGroupManager/ # Widget/app data synchronization
│   └── DateQueryHelpers/ # Date-based query utilities
├── Resources/        # Localization files (5 languages)
│   ├── en.lproj/     # English
│   ├── it.lproj/     # Italian
│   ├── es.lproj/     # Spanish
│   ├── fr.lproj/     # French
│   ├── de.lproj/     # German
│   └── Fonts/        # JetBrains Mono NL font family
└── Extensions/       # Swift extensions

HomeWidget/          # Widget extension with App Intents
├── HomeWidget.swift # Main widget implementation
├── AddCigaretteIntent.swift # Siri/Shortcuts integration
└── HomeWidgetBundle.swift # Widget bundle

MirrorSmokerStopper Watch App/ # watchOS companion app
└── MirrorSmokerStopper Watch App Extension/
```

## 🎨 Design System

The app uses a custom design system (`DS`) that provides:
- **Typography**: JetBrains Mono NL font family with system font fallbacks
- **Colors**: Comprehensive color palette with semantic naming
- **Spacing**: 8pt grid system for consistent layouts  
- **Components**: Reusable UI components (cards, buttons, forms)
- **Accessibility**: VoiceOver support with descriptive labels
- **Responsive**: Adaptive sizing for different screen sizes
- **Dark/Light mode**: Full theme support

## 📊 Analytics & Privacy

### What We Track
- Cigarette count and timing
- User-defined tags and categories
- Usage patterns (for insights)

### What We DON'T Track
- Personal identifying information
- Location data
- Third-party analytics
- Advertising data

All data is stored locally and synchronized through your personal iCloud account.

## 🛠️ Development

### Running Tests
```bash
# Run unit tests
⌘+U in Xcode

# Run UI tests
Select UI test target and run
```

### Adding New Features
1. Follow the existing architecture patterns
2. Add appropriate tests
3. Update localization files
4. Consider watch app compatibility

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Comment complex logic
- Keep files under 250 lines when possible

## 🌍 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Areas for Contribution
- New language translations
- UI/UX improvements
- Additional analytics features
- Bug fixes and performance improvements
- Documentation updates

## 🗺️ Roadmap

See our [Roadmap](Roadmap.md) for planned features and development milestones.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Issues**: Report bugs or request features via GitHub Issues
- **Discussions**: Join community discussions
- **Email**: Contact us at roberdan@fightthestroke.org

## 🙏 Acknowledgments

- Built with ❤️ by the Fight the Stroke team
- Inspired by the need for privacy-focused health tracking
- Thanks to the Swift and iOS development community

---

**Disclaimer**: This app is designed to help track smoking habits and should not replace professional medical advice. Please consult healthcare professionals for smoking cessation guidance.
