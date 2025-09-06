# Mirror Smoker 🚭

A privacy-first, open-source cigarette tracking app for iOS and watchOS designed to help users monitor their smoking habits and work towards reducing consumption. Built with SwiftUI, SwiftData, and CloudKit for seamless synchronization across all devices.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![watchOS](https://img.shields.io/badge/watchOS-10.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Key Features

### 🎯 Core Functionality
- **One-tap logging**: Quick cigarette tracking with timestamp and contextual tagging
- **Unified Tag System**: Smart categorization with predefined and custom tags (stress, work, coffee, social, etc.)
- **iCloud sync**: Real-time data synchronization across iPhone and Apple Watch
- **Privacy-first**: All data stays on your devices and personal iCloud account
- **Production-ready**: Complete app ready for App Store deployment

### 🤖 AI Coach (Advanced)
- **Smart Pattern Recognition**: AI-powered analysis of smoking patterns and triggers
- **Just-In-Time Interventions (JITAI)**: Contextual coaching when you need it most
- **HealthKit Integration**: Heart rate and activity data for comprehensive insights
- **Behavioral Analysis**: Advanced machine learning for personalized recommendations
- **Multiple Coaching Moods**: Supportive, motivational, analytical approaches

### 📱 Smart Integrations
- **Siri support**: "Hey Siri, I smoked a cigarette" in all supported languages
- **Widget support**: Small and medium home screen widgets with real-time sync
- **App Shortcuts**: Custom shortcuts integration with iOS 17+ App Intents
- **Watch app**: Native Apple Watch experience with full sync capabilities
- **Fastlane integration**: Automated deployment and App Store metadata management

### 📊 Analytics & Insights
- **Advanced Statistics**: Daily, weekly, monthly trends with visual charts
- **Pattern recognition**: Machine learning insights into smoking triggers
- **Tag analytics**: Comprehensive analysis of contextual smoking patterns
- **Progress tracking**: Visual progress indicators and milestone celebrations
- **Wellness Journey**: Structured quit programs with coaching support

### 🌍 Full Localization
- **5 Languages**: English, Italian, Spanish, French, and German
- **Complete localization**: All UI, widgets, permissions, and App Store metadata
- **App Store ready**: Fully localized metadata for international distribution
- **Accessibility**: VoiceOver support in all languages

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

Sync architecture for Widgets, App, and Watch is unified:
- Widgets and the app both read/write from the same SwiftData store located in the App Group (`group.fightthestroke.mirrorsmoker`).
- For fast loading, the app publishes a shared snapshot to App Group UserDefaults: `todayCount` and a day-scoped JSON (`cigarettes_yyyy-MM-dd`). Widgets use this when appropriate.
- Adding from the widget uses App Intents and writes directly into the App Group SwiftData store; the app updates the shared snapshot and reloads widget timelines.
- The watch app syncs via WatchConnectivity and the same App Group snapshot to keep the count aligned everywhere.
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
- `Cigarette`: Core smoking event with timestamp and unified tag system
- `Tag`: Unified categorization system with predefined and custom tags
- `UserProfile`: User preferences, AI coach settings, and wellness journey progress
- `Product`: Cigarette brands and types tracking
- `SmokingInsight`: AI-generated insights and pattern analysis
- `UrgeLog`: Craving tracking and resistance logging
- `StandardTriggerTag`: Predefined context tags (stress, coffee, work, social)
- `WellnessJourneyModels`: Structured quit programs and milestones

### Project Structure
```
MirrorSmokerStopper/
├── Models/           # SwiftData models
│   ├── Cigarette.swift     # Core smoking events
│   ├── Tag.swift          # Unified tag system
│   ├── UserProfile.swift  # User data and preferences
│   ├── SmokingInsight.swift # AI insights and analysis
│   ├── UrgeLog.swift      # Craving tracking
│   ├── StandardTriggerTag.swift # Predefined context tags
│   └── WellnessJourneyModels.swift # Quit programs
├── Views/            # SwiftUI views
│   ├── Components/   # Reusable UI components with design system
│   ├── Statistics/   # Advanced analytics and interactive charts
│   ├── Settings/     # Configuration and preferences
│   ├── Onboarding/   # User onboarding and setup
│   ├── Profile/      # User profile and preferences
│   ├── Progress/     # Progress tracking and milestones
│   ├── Journey/      # Wellness journey and coaching
│   └── Today/        # Today's view and quick actions
├── Utilities/        # Helper classes and extensions
│   ├── DesignSystem/ # Comprehensive design system (DS)
│   ├── AppGroupManager/ # Widget/app data synchronization
│   ├── DateQueryHelpers/ # Date-based query utilities
│   └── AICoach/      # AI coaching and pattern analysis
├── Resources/        # Complete localization (5 languages)
│   ├── en.lproj/     # English (base)
│   ├── it.lproj/     # Italian
│   ├── es.lproj/     # Spanish
│   ├── fr.lproj/     # French
│   ├── de.lproj/     # German
│   └── Fonts/        # JetBrains Mono NL font family
└── Extensions/       # Swift extensions and utilities

HomeWidget/          # Widget extension with full functionality
├── HomeWidget.swift # Main widget with real-time sync
├── AddCigaretteIntent.swift # Siri/Shortcuts integration
└── HomeWidgetBundle.swift # Widget bundle configuration

MirrorSmokerStopper Watch App/ # Native watchOS app
├── ContentView.swift # Watch interface
├── ConnectivityManager.swift # Phone-watch sync
└── WatchOS Extensions/ # Watch-specific features

fastlane/           # Automated deployment and App Store management
├── Fastfile        # Deployment automation
├── Appfile         # App configuration
├── Matchfile       # Certificate management
└── metadata/       # 5-language App Store metadata
    ├── en-US/      # English App Store listing
    ├── it/         # Italian App Store listing
    ├── es-ES/      # Spanish App Store listing
    ├── fr-FR/      # French App Store listing
    └── de-DE/      # German App Store listing
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

### Production Readiness
This app is **production-ready** and includes:
- Complete 5-language localization
- Fastlane automated deployment
- App Store metadata in all supported languages
- Production-grade error handling and logging
- HealthKit and notification permissions properly configured

### Running Tests
```bash
# Run unit tests
⌘+U in Xcode

# Run UI tests
Select UI test target and run

# Test files available:
# - SyncTests.md: Synchronization testing documentation
# - TestReport.md: Comprehensive test reports
```

### Deployment
### 🔄 Automated Release & Beta Pipeline (Fastlane)

The project includes a fully automated App Store pipeline:

Release lane (`fastlane release`) performs:
1. Git clean + branch check (master)
2. Match (certificates for app, watch, widget)
3. Version bump (NEW_VERSION or BUMP_TYPE=patch|minor|major, default patch)
4. Build number bump (timestamp if USE_TIMESTAMP_BUILD=1)
5. Optional tests (skip with FASTLANE_SKIP_TESTS=1)
6. Screenshot pipeline (skip with SKIP_SCREENSHOTS=1)
7. Precheck (if APP_STORE_CONNECT_API_KEY_PATH set)
8. Build IPA (app-store export)
9. Deliver: metadata + screenshots + binary + submit_for_review (manual release)
10. Commit, tag (v<version>), push

Beta lane (`fastlane beta`) performs:
- Git clean check
- Build number only bump (timestamp optional)
- Build + upload to TestFlight
- Commit version bump

Environment variables:
- NEW_VERSION=1.2.0 (explicit marketing version)
- BUMP_TYPE=minor (overrides default patch when NEW_VERSION absent)
- USE_TIMESTAMP_BUILD=1 (use YYYYMMDDHHMM as build)
- FASTLANE_SKIP_TESTS=1 (skip scan tests)
- SKIP_SCREENSHOTS=1 (skip screenshots generation in release)
- DRY_RUN=1 (skip deliver/upload + git push/tag)
- APP_STORE_CONNECT_API_KEY_PATH=fastlane/AuthKey_XXXX.p8 (enables precheck)

Example dry run:
```bash
BUNDLER_VERSION=2.7.1 bundle _2.7.1_ exec fastlane release DRY_RUN=1 FASTLANE_SKIP_TESTS=1 SKIP_SCREENSHOTS=1
```

Normal release:
```bash
bundle exec fastlane release
```

TestFlight beta:
```bash
bundle exec fastlane beta
```

```bash
# Install fastlane dependencies
bundle install

# Run tests and build
bundle exec fastlane test

# Deploy to TestFlight
bundle exec fastlane beta

# Deploy to App Store
bundle exec fastlane release
```

### Adding New Features
1. Follow the existing SwiftUI + SwiftData architecture
2. Add comprehensive unit and UI tests
3. Update all 5 localization files (en, it, es, fr, de)
4. Consider watch app compatibility and sync requirements
5. Update fastlane metadata if user-facing
6. Test AI Coach integration if applicable

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices with design system (DS)
- Implement comprehensive error handling
- Maintain privacy-first architecture
- Document AI Coach integrations
- Keep accessibility in mind (VoiceOver support)

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

## 🗺️ Current Status & Next Steps

### ✅ Production Features (September 2024)
- **Production Readiness**: Fully deployed with critical fixes and optimizations
- **Complete Localization**: 5 languages (EN, IT, ES, FR, DE) with App Store metadata
- **AI Coach System**: Complete implementation with multiple coaching personalities
- **Advanced Analytics**: Comprehensive statistics with pattern recognition
- **Premium Features**: In-app purchases with StoreKit integration
- **Health Integration**: HealthKit permissions and heart rate monitoring
- **Cross-Platform Sync**: iPhone, Apple Watch, and widget synchronization
- **Automated Deployment**: Fastlane integration with multi-language metadata
- **Design System**: Complete DS implementation with JetBrains Mono typography

### 🚀 Current Development Status
- **Current Branch**: `development` 
- **Main Branch**: `master`
- **Latest Release**: Production-ready (September 2024)
- **Total Codebase**: 147 Swift files with comprehensive features
- **Status**: App Store ready with complete localization and deployment automation

### 📋 Technical Documentation
- `ARCHITECTURE.md`: Complete technical architecture and design patterns
- `DEPLOYMENT.md`: Production deployment guide with Fastlane automation
- `AiCoach.md`: AI Coach implementation details and coaching algorithms
- `planSept5.md`: Development milestones and feature completion status
- `CONTRIBUTING.md`: Complete contributor guide with localization requirements
- `fastlane/metadata/`: 5-language App Store metadata (production-ready)

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

## 🎯 Development Status

**Current State (September 2024)**: Production-ready iOS app with critical fixes applied, featuring 147 Swift files of comprehensive functionality.

**Architecture**: Modern SwiftUI + SwiftData with CloudKit sync, complete AI Coach system, premium features, and privacy-first design.

**Recent Critical Fixes**: 
- HealthKit and notification permissions properly configured
- Complete localization fixes across all 5 languages
- Sync coordinator optimizations for cross-device reliability
- Production-ready deployment pipeline with automated metadata

**Deployment**: App Store ready with complete fastlane automation, 5-language metadata, and all critical issues resolved.

---

**Disclaimer**: This app is designed to help track smoking habits and should not replace professional medical advice. Please consult healthcare professionals for smoking cessation guidance.

*“We live in a twilight world, and there are no friends at dusk.”* - Tenet
