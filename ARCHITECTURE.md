# 🏗️ MirrorSmoker - Technical Architecture

## 📋 Overview

MirrorSmoker is a production-ready iOS smoking cessation app built with modern Swift technologies. The app follows Clean Architecture principles with a privacy-first approach, featuring AI-powered coaching, comprehensive data synchronization, and full internationalization.

## 🎯 Core Architecture

### Technology Stack
- **UI Framework**: SwiftUI with iOS 17+ features
- **Data Persistence**: SwiftData (Core Data successor)
- **Cloud Sync**: CloudKit for seamless device synchronization
- **AI/ML**: CoreML with on-device processing
- **Localization**: 5 languages (EN, IT, ES, FR, DE)
- **Deployment**: Fastlane automation with App Store Connect integration
- **Testing**: XCTest with comprehensive unit and UI tests

### Design Patterns
- **MVVM**: Model-View-ViewModel architecture with SwiftUI
- **Repository Pattern**: Centralized data access through managers
- **Dependency Injection**: Clean separation of concerns
- **Observer Pattern**: Reactive UI updates with @Observable
- **Command Pattern**: User actions and undo/redo functionality

## 📱 App Architecture

### 1. Data Layer

#### Core Models (SwiftData)
```swift
@Model class Cigarette {
    var timestamp: Date
    var tags: [Tag]
    var location: String?
    var mood: String?
    var trigger: String?
}

@Model class Tag {
    var name: String
    var color: Color
    var category: TagCategory
    var isStandard: Bool
}

@Model class UserProfile {
    var preferences: UserPreferences
    var aiCoachSettings: AICoachSettings
    var journeyProgress: WellnessJourneyProgress
}
```

#### Data Managers
- **PersistenceController**: SwiftData container management
- **CloudKitManager**: iCloud synchronization
- **AppGroupManager**: Widget/app data sharing
- **TagManager**: Unified tag system management

### 2. Business Logic Layer

#### AI Coach System (Complete Implementation)
- **AICoachManager**: Central coaching coordinator with multiple personalities
- **BehavioralAnalyzer**: Advanced pattern recognition and trigger analysis
- **JITAINotificationManager**: Just-In-Time Adaptive Interventions
- **CoachEngine**: Multi-modal coaching with supportive, analytical, and motivational approaches
- **HeartRateCoachingEngine**: HealthKit integration for physiological insights
- **TipLibrary**: Contextual coaching tips and recommendations
- **QuitPlanOptimizer**: Personalized cessation strategy optimization
- **FeatureStore**: ML feature engineering for coaching algorithms

#### Analytics Engine
- **StatisticsManager**: Daily/weekly/monthly trend analysis
- **PatternRecognition**: ML-powered smoking pattern detection
- **ProgressTracker**: Goal setting and milestone tracking
- **InsightGenerator**: AI-generated personalized insights

### 3. Presentation Layer

#### View Architecture
```
Views/
├── Components/          # Reusable UI components
│   ├── Cards/          # Data display cards
│   ├── Charts/         # Statistics visualizations
│   ├── Forms/          # Input components
│   └── Navigation/     # Navigation elements
├── Screens/
│   ├── Today/          # Main dashboard
│   ├── Statistics/     # Analytics views
│   ├── Profile/        # User profile
│   ├── Settings/       # App configuration
│   ├── Journey/        # Wellness journey
│   └── Onboarding/     # Initial setup
```

#### Design System (DS)
- **Typography**: JetBrains Mono NL with system fallbacks
- **Color Palette**: Semantic color system with dark/light mode
- **Spacing**: 8pt grid system
- **Components**: Consistent UI patterns across the app
- **Accessibility**: Full VoiceOver support

### 4. Platform Extensions

#### HomeWidget Extension
- **Widget Types**: Small and Medium widgets
- **Real-time Sync**: App Group-based data sharing
- **Quick Actions**: One-tap cigarette logging
- **Localized**: Full 5-language support

#### Apple Watch App
- **Native Interface**: SwiftUI for watchOS
- **Connectivity**: Phone-watch real-time sync
- **Complications**: Watch face integration
- **Standalone**: Offline logging with sync when connected

#### Siri & Shortcuts
- **App Intents**: iOS 17+ integration
- **Voice Commands**: "Hey Siri, I smoked a cigarette"
- **Custom Shortcuts**: User-defined automation
- **Multilingual**: Support in all 5 languages

## 🔐 Privacy & Security

### Privacy-First Architecture
- **Local Processing**: AI/ML runs entirely on-device
- **iCloud Personal**: Data stays in user's personal iCloud
- **No Analytics**: Zero third-party tracking
- **Data Minimization**: Only essential data collection
- **User Control**: Complete data ownership and deletion

### Security Measures
- **App Transport Security**: HTTPS-only network communication
- **Keychain**: Secure credential storage
- **App Groups**: Sandboxed inter-app communication
- **CloudKit Encryption**: End-to-end encrypted sync
- **Biometric Auth**: Face ID/Touch ID for sensitive features

## 🌍 Internationalization

### Supported Languages
1. **English (en)** - Base language
2. **Italian (it)** - Full localization
3. **Spanish (es)** - Complete translation
4. **French (fr)** - Native localization  
5. **German (de)** - Full German support

### Localization Architecture
- **String Resources**: Localized .strings files
- **Pluralization**: Proper plural forms for all languages
- **Right-to-Left**: Prepared for RTL languages
- **Cultural Adaptation**: Date, time, number formats
- **App Store Metadata**: Fully localized store listings

## 🚀 Deployment Architecture

### Fastlane Integration
```ruby
# Fastfile structure
lane :test do
  run_tests(scheme: "MirrorSmokerStopper")
end

lane :beta do
  build_app(scheme: "MirrorSmokerStopper")
  upload_to_testflight
end

lane :release do
  build_app(scheme: "MirrorSmokerStopper") 
  upload_to_app_store
end
```

### CI/CD Pipeline
- **Automated Testing**: Unit and UI tests on every commit
- **Code Signing**: Automatic certificate management
- **Multi-language Builds**: Simultaneous deployment to all regions
- **Staged Deployment**: TestFlight → App Store progression

## 🧪 Testing Strategy

### Testing Pyramid
1. **Unit Tests**: Model logic, business rules, utilities
2. **Integration Tests**: Data persistence, sync, API integration
3. **UI Tests**: User flows, accessibility, localization
4. **Manual Testing**: Device compatibility, performance

### Test Coverage
- **Models**: 95%+ coverage of data logic
- **Managers**: 90%+ coverage of business logic
- **Views**: Key user flows and accessibility
- **Sync**: Comprehensive CloudKit and widget sync testing

## 📊 Performance Considerations

### Optimization Strategies
- **SwiftData**: Efficient local data persistence
- **Lazy Loading**: On-demand view and data loading
- **Image Caching**: Optimized asset management
- **Background Processing**: Non-blocking operations
- **Memory Management**: Proper lifecycle handling

### Scalability
- **Data Growth**: Efficient queries for large datasets
- **Feature Flags**: Gradual feature rollout
- **Modular Architecture**: Easy feature addition/removal
- **Platform Extensibility**: Ready for additional Apple platforms

## 🔄 Data Flow

### Synchronization Architecture
```
User Action → Local SwiftData → CloudKit Sync → Widget Update
     ↓              ↓               ↓            ↓
Watch Sync → Background Refresh → Push Notifications → AI Processing
```

### State Management
- **Single Source of Truth**: SwiftData as the primary data store
- **Reactive Updates**: SwiftUI automatic UI refresh
- **Consistent State**: App Group synchronization
- **Conflict Resolution**: CloudKit automatic merge strategies

## 🎯 Future Architecture Considerations

### Scalability Roadmap
- **Additional Platforms**: macOS, iPadOS optimizations
- **Advanced AI**: More sophisticated coaching algorithms
- **Social Features**: Anonymous community support
- **Health Integration**: Deeper HealthKit integration
- **Wearables**: Extended device support beyond Apple Watch

### Technical Debt Management
- **Regular Refactoring**: Continuous architecture improvements
- **Dependency Updates**: Staying current with Apple technologies
- **Performance Monitoring**: Proactive optimization
- **Documentation**: Maintained technical documentation

---

**Note**: This architecture document reflects the current production-ready state of MirrorSmoker as of September 2024.