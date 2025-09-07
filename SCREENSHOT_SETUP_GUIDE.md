# Automated Screenshot Generation Setup Guide

Complete setup for automated App Store screenshot generation using Fastlane for MirrorSmokerStopper.

## 🎯 What's Included

### Files Created
- ✅ **SnapshotHelper.swift** - Fastlane screenshot helper (added to UI test target)
- ✅ **ScreenshotTests.swift** - Main screenshot test suite
- ✅ **AICoachScreenshotTests.swift** - AI Coach feature screenshots
- ✅ **Fastfile** - Complete Fastlane automation lanes
- ✅ **Snapfile** - Screenshot generation configuration
- ✅ **Setup Scripts** - Automated setup and execution scripts

### Screenshots Generated
1. **Main Dashboard** - Home screen with cigarette tracking
2. **AI Coach Dashboard** - Heart rate monitoring and insights  
3. **Statistics** - Progress analytics and charts
4. **Settings** - User profile and configuration
5. **Add Cigarette with Tags** - Tag selection interface
6. **Heart Rate Monitoring** - Cardiovascular wellness features
7. **Predictive Analysis** - AI pattern recognition
8. **AI Insights** - Personalized recommendations

### Supported Devices
- iPhone 15 Pro Max
- iPhone 15 Pro
- iPhone 15
- iPhone SE (3rd generation)  
- iPad Pro (12.9-inch) (6th generation)
- iPad Pro (11-inch) (4th generation)

### Supported Languages
- English (en-US)
- Spanish (es-ES)
- French (fr-FR)
- German (de-DE)
- Italian (it-IT)

## 🚀 Quick Start

### 1. Initial Setup
```bash
cd /Users/roberdan/Desktop/MirrorSmoker
chmod +x scripts/setup_screenshots.sh
./scripts/setup_screenshots.sh
```

### 2. Configure Apple Developer Account
Edit `fastlane/Appfile`:
```ruby
apple_id("your-apple-id@example.com")
team_id("YOUR_TEAM_ID")
app_identifier("com.fightthestroke.MirrorSmokerStopper")
```

### 3. Generate Screenshots

#### Quick Test (English only, iPhone 15 Pro Max)
```bash
./scripts/take_screenshots.sh
```

#### Full Production Screenshots (All devices & languages)
```bash
./scripts/take_all_screenshots.sh
```

#### Using Fastlane Directly
```bash
# Quick screenshots
fastlane screenshots_quick

# Full screenshots  
fastlane screenshots

# Screenshots + App Store Connect upload
fastlane screenshots_and_upload
```

## 📝 Configuration Files

### Fastfile Lanes
- `screenshots` - Full screenshot generation for all devices/languages
- `screenshots_quick` - Fast generation (English only, iPhone 15 Pro Max)
- `screenshots_and_upload` - Generate + upload to App Store Connect
- `test` - Run UI tests
- `beta` - Build and upload to TestFlight
- `release` - Full App Store release process
- `cleanup` - Clean build artifacts and old screenshots

### Snapfile Settings
- Device configurations
- Language settings  
- Launch arguments
- Status bar override
- Output directory configuration

## 🧪 Test Classes

### ScreenshotTests.swift
Main screenshot test class covering:
- Main dashboard navigation
- Statistics view
- Settings configuration  
- Add cigarette workflow
- Tag management

### AICoachScreenshotTests.swift
Specialized tests for AI Coach features:
- AI Coach dashboard
- Heart rate monitoring setup
- Predictive analysis views
- Personalized recommendations
- Health data integration

## 🔧 Customization

### Adding New Screenshots
1. Add `snapshot("ScreenshotName")` calls in test methods
2. Navigate to the desired screen state
3. Ensure UI elements are properly loaded
4. Call `snapshot()` with descriptive name

### Modifying Device List
Edit both `Fastfile` and `Snapfile`:
```ruby
devices([
  "iPhone 15 Pro Max",
  "iPad Air (5th generation)",
  # Add new devices here
])
```

### Adding Languages
Update language arrays in configuration files:
```ruby
languages([
  "en-US",
  "pt-BR",  # Add Portuguese
  # Add more languages
])
```

### Screenshot Naming Convention
Screenshots are automatically named: `{Device}-{ScreenshotName}.png`

Examples:
- `iPhone 15 Pro Max-01-MainDashboard.png`
- `iPhone 15 Pro-02-AICoachDashboard.png`
- `iPad Pro (12.9-inch) (6th generation)-03-Statistics.png`

## 📱 App-Specific Features

### AI Coach Integration
The screenshot tests are designed to showcase MirrorSmokerStopper's unique AI coaching capabilities:

1. **Heart Rate Monitoring** - Cardiovascular wellness tracking
2. **Predictive Analysis** - Craving prediction algorithms  
3. **Personalized Actions** - Context-aware recommendations
4. **Focus Mode Integration** - Intelligent notification management
5. **Progress Tracking** - Visual recovery metrics

### Demo Mode
Tests include `AI_COACH_DEMO_MODE` launch argument to populate the interface with representative data for better screenshots.

## 🐛 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
xcodebuild clean -project MirrorSmokerStopper.xcodeproj -scheme MirrorSmokerStopper
```

#### Missing Simulators
Install required simulators via Xcode:
- Xcode → Settings → Platforms → iOS → Install additional simulators

#### UI Test Timeouts
Increase timeout values in test files:
```swift
XCTAssertTrue(element.waitForExistence(timeout: 10))
```

#### Screenshot Quality Issues
- Ensure app is fully loaded before taking screenshots
- Add `sleep()` calls between navigation and screenshots
- Use `waitForExistence()` for dynamic content

#### Fastlane Permission Issues
```bash
# Reset Fastlane credentials
fastlane fastlane-credentials remove --username your-apple-id@example.com
```

### Debug Mode
Run with verbose logging:
```bash
fastlane screenshots_quick --verbose
```

### Project Structure Verification
Ensure SnapshotHelper.swift is properly added to the UI test target in Xcode.

## 📈 CI/CD Integration

### GitHub Actions Example
```yaml
name: Generate Screenshots
on: [push]
jobs:
  screenshots:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate Screenshots
        run: fastlane screenshots_quick
      - name: Upload Screenshots
        uses: actions/upload-artifact@v3
        with:
          name: screenshots
          path: fastlane/screenshots/
```

## 📊 Performance Optimization

### Concurrent Execution
- Multiple simulators run in parallel
- Faster screenshot generation
- Configurable via `max_concurrent_simulators`

### Selective Generation
- Use `screenshots_quick` for development
- Full generation only for releases
- Language-specific generation available

## 🛡️ Security Considerations

- App Store Connect credentials via Fastlane Match
- Secure keychain handling
- No sensitive data in screenshots
- Automated status bar sanitization

## 📚 Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Snapshot Documentation](https://docs.fastlane.tools/actions/snapshot/)
- [App Store Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [UI Testing in Xcode](https://developer.apple.com/documentation/xctest/user_interface_tests)

## 🎉 Success Metrics

After setup completion, you should have:
- ✅ Automated screenshot generation for 6+ devices
- ✅ Multi-language support (5 languages)
- ✅ 8+ distinct app feature screenshots
- ✅ AI Coach feature showcase
- ✅ App Store-ready assets
- ✅ CI/CD integration capabilities

## 📞 Support

For issues specific to MirrorSmokerStopper's screenshot generation:
1. Check this guide's troubleshooting section
2. Verify Xcode project configuration  
3. Test manual UI test execution
4. Review Fastlane logs for specific errors

---

🚀 **Ready to showcase your AI-powered smoking cessation app with professional App Store screenshots!**