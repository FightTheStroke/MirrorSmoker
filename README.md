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
- **Siri support**: "Hey Siri, I smoked a cigarette" in English and Italian
- **Widget support**: Home screen and Lock screen widgets for quick logging
- **App Shortcuts**: Custom shortcuts for power users
- **Watch app**: Native Apple Watch experience with complications

### Analytics & Insights
- **Daily/Weekly stats**: Track your progress over time
- **Pattern recognition**: Understand when and why you smoke most
- **Tag analytics**: See which situations trigger smoking
- **Visual charts**: Beautiful, interactive data visualization
- **Trend analysis**: Monitor your reduction progress

### Localization
- **Multi-language**: English and Italian support
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
├── Models/           # SwiftData models
├── Views/            # SwiftUI views
│   ├── Components/   # Reusable UI components
│   └── Statistics/   # Analytics and charts
├── Utilities/        # Helper classes and extensions
├── Resources/        # Localization files
└── Extensions/       # Swift extensions

Widget/               # Widget extension
Watch App/           # watchOS app
```

## 🎨 Design System

The app uses a custom design system (`DS`) that provides:
- Consistent colors, typography, and spacing
- Reusable UI components
- Dark/Light mode support
- Accessibility features

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
