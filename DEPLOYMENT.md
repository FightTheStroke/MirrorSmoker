# 🚀 MirrorSmoker - Deployment Guide

## 📋 Overview

This document covers the complete deployment process for MirrorSmoker, from development setup to App Store release. The app is production-ready with automated deployment pipelines.

## 🛠️ Development Environment Setup

### Prerequisites
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 17.0+
- **watchOS Deployment Target**: 10.0+
- **Ruby**: 2.7+ (for Fastlane)
- **Bundler**: For Ruby dependency management
- **Apple Developer Account**: Required for device testing and App Store deployment

### Initial Setup
```bash
# Clone repository
git clone https://github.com/yourusername/mirror-smoker.git
cd mirror-smoker

# Install Fastlane dependencies
bundle install

# Open project in Xcode
open MirrorSmokerStopper.xcodeproj
```

### Bundle Identifier Configuration
Update the following bundle identifiers in Xcode:
- **Main App**: `com.yourteam.mirrorsmoker`
- **Widget Extension**: `com.yourteam.mirrorsmoker.widget`
- **Watch App**: `com.yourteam.mirrorsmoker.watchapp`
- **Watch Extension**: `com.yourteam.mirrorsmoker.watchapp.extension`

### Required Capabilities
Enable the following capabilities in Xcode:
- **iCloud** (CloudKit)
- **App Groups** (for widget data sharing)
- **HealthKit** (for AI Coach features)
- **Push Notifications**
- **Siri & Shortcuts**

## 🔐 Code Signing & Certificates

### Fastlane Match Setup
The project uses Fastlane Match for certificate management:

```ruby
# Matchfile configuration
git_url("https://github.com/yourteam/certificates")
storage_mode("git")
type("appstore")
app_identifier(["com.yourteam.mirrorsmoker", 
               "com.yourteam.mirrorsmoker.widget",
               "com.yourteam.mirrorsmoker.watchapp"])
```

### Certificate Management
```bash
# Install certificates and provisioning profiles
bundle exec fastlane match appstore

# For development
bundle exec fastlane match development

# For ad-hoc distribution
bundle exec fastlane match adhoc
```

## 🏗️ Build Process

### Local Development Build
```bash
# Build and run on simulator
⌘+R in Xcode

# Build for device testing
1. Select your device in Xcode
2. Build and run (⌘+R)
```

### Automated Build with Fastlane
```bash
# Run all tests
bundle exec fastlane test

# Build for TestFlight
bundle exec fastlane beta

# Build for App Store
bundle exec fastlane release
```

## 🧪 Testing Pipeline

### Test Execution
```bash
# Run unit tests
bundle exec fastlane test

# Manual test execution in Xcode
# 1. Select test target
# 2. Press ⌘+U
```

### Test Coverage
The app includes comprehensive tests:
- **Unit Tests**: Model logic, data persistence, business rules
- **UI Tests**: User flows, accessibility, cross-device sync
- **Integration Tests**: CloudKit sync, widget functionality
- **Localization Tests**: All 5 supported languages

### Test Reports
Test results are documented in:
- `Tests/TestReport.md` - Comprehensive test documentation
- `Tests/SyncTests.md` - Synchronization testing specifics

## 📱 Multi-Platform Deployment

### Target Platforms
1. **iOS App** (iPhone)
2. **Widget Extension** (Home Screen widgets)
3. **Apple Watch App** (Native watchOS)
4. **Watch Extension** (Watch app extension)

### Build Configurations
- **Debug**: Development with full logging
- **Release**: Production-optimized build
- **TestFlight**: Beta testing configuration

## 🌍 Internationalization Deployment

### Supported Regions
The app is fully localized for:
- **United States** (English)
- **Italy** (Italian)
- **Spain** (Spanish) 
- **France** (French)
- **Germany** (German)

### Localization Files
```
Resources/
├── en.lproj/Localizable.strings    # English (base)
├── it.lproj/Localizable.strings    # Italian
├── es.lproj/Localizable.strings    # Spanish
├── fr.lproj/Localizable.strings    # French
└── de.lproj/Localizable.strings    # German
```

### App Store Metadata
Complete localization in `fastlane/metadata/`:
```
metadata/
├── en-US/          # English App Store listing
├── it/             # Italian App Store listing
├── es-ES/          # Spanish App Store listing
├── fr-FR/          # French App Store listing
└── de-DE/          # German App Store listing
```

## 📦 App Store Deployment

### TestFlight Beta Deployment
```bash
# Upload to TestFlight
bundle exec fastlane beta

# Manual steps:
# 1. Open App Store Connect
# 2. Navigate to TestFlight
# 3. Add external testers (optional)
# 4. Submit for review
```

### Production Release
```bash
# Upload to App Store
bundle exec fastlane release

# Manual steps in App Store Connect:
# 1. Complete app information
# 2. Add screenshots for all device types
# 3. Set pricing and availability
# 4. Submit for App Store review
```

### App Store Connect Configuration

#### App Information
- **Name**: MirrorSmoker Tracker (localized in all languages)
- **Category**: Health & Fitness
- **Age Rating**: 17+ (due to smoking content)
- **Privacy Policy**: Required (link to your privacy policy)

#### Required Screenshots
For each supported language:
- **iPhone**: 6.7", 6.5", 5.5" displays
- **Apple Watch**: 45mm and 41mm Series 7+
- **App Previews**: Optional but recommended

#### App Store Review Information
- **Demo Account**: Not required (app works without account)
- **Review Notes**: Highlight AI Coach features, privacy-first approach
- **Contact Information**: Valid email and phone number

## 🔄 Continuous Integration

### GitHub Actions (Recommended)
```yaml
# .github/workflows/ios.yml
name: iOS CI

on:
  push:
    branches: [master, development]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v2
    - name: Run tests
      run: bundle exec fastlane test
      
  deploy:
    runs-on: macos-latest
    if: github.ref == 'refs/heads/master'
    steps:
    - uses: actions/checkout@v2
    - name: Deploy to TestFlight
      run: bundle exec fastlane beta
      env:
        FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
```

## 📊 Release Management

### Version Numbering
- **Marketing Version**: Semantic versioning (1.0.0, 1.1.0, etc.)
- **Build Number**: Incremental (1, 2, 3, etc.)
- **Automated**: Fastlane automatically increments build numbers

### Release Branches
- **master**: Production-ready code
- **development**: Active development
- **feature/**: Feature-specific branches
- **hotfix/**: Critical bug fixes

### Release Process
1. **Development**: Feature development on `development` branch
2. **Testing**: Comprehensive testing on feature branches
3. **Staging**: Merge to `development`, deploy to TestFlight
4. **Production**: Merge to `master`, deploy to App Store

## 🚨 Emergency Deployment

### Hotfix Process
```bash
# Create hotfix branch from master
git checkout master
git checkout -b hotfix/critical-fix

# Make fixes
# Test thoroughly
# Merge to master
git checkout master
git merge hotfix/critical-fix

# Emergency deployment
bundle exec fastlane release
```

### Rollback Strategy
- **App Store**: Submit updated version (no direct rollback)
- **TestFlight**: Remove problematic build, revert to previous
- **Development**: Revert commits, deploy fixed version

## 📈 Monitoring & Analytics

### Deployment Monitoring
- **App Store Connect**: Download and crash analytics
- **TestFlight**: Beta testing feedback and crash reports
- **Xcode Organizer**: Crash logs and performance metrics

### Privacy-Compliant Monitoring
The app follows privacy-first principles:
- **No third-party analytics**: All data stays on device/iCloud
- **Crash reporting**: Only through Apple's built-in systems
- **Performance monitoring**: Xcode Metrics and App Store analytics

## 🔧 Troubleshooting

### Common Deployment Issues

#### Code Signing Problems
```bash
# Clean and regenerate certificates
bundle exec fastlane match nuke development
bundle exec fastlane match nuke appstore
bundle exec fastlane match appstore
```

#### Build Failures
```bash
# Clean build folder
⌘+Shift+K in Xcode

# Reset simulator
xcrun simctl erase all

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### Localization Issues
- Verify all .strings files have matching keys
- Check for special characters and escaping
- Test on devices set to each supported language

#### CloudKit Sync Issues
- Verify iCloud capability is enabled
- Check CloudKit container configuration
- Test with multiple iCloud accounts

## 📝 Deployment Checklist

### Pre-Release Checklist
- [ ] All tests passing
- [ ] Localization complete for all 5 languages
- [ ] App Store metadata updated
- [ ] Screenshots current for all device types
- [ ] Privacy policy updated
- [ ] Version numbers incremented
- [ ] Release notes prepared
- [ ] TestFlight testing completed

### Post-Release Checklist
- [ ] Monitor App Store Connect for crashes
- [ ] Check initial user feedback
- [ ] Verify all device types working correctly
- [ ] Monitor CloudKit dashboard for sync issues
- [ ] Update internal documentation

---

**Note**: This deployment guide reflects the current production-ready state of MirrorSmoker (September 2024) with 147 Swift files, complete AI Coach implementation, premium features, and full automation pipeline ready for App Store deployment.