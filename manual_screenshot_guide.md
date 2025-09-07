# Manual Screenshot Guide for MirrorSmoker

## Issue Summary
The automated screenshot functionality is not working due to a known issue with iOS 26 beta simulators where `xcrun simctl io screenshot` fails with "Error creating the image". 

## Current Status
✅ iOS App is successfully launched on RoberdanTests26 simulator (Process ID: 67188)
✅ Simulator.app is open and ready for manual screenshots
✅ Both simulators (iOS and Watch) are booted and ready

## Manual Screenshot Instructions

### iOS Screenshots (10 per language)
The app is currently running on the iOS simulator. Use Simulator.app to take screenshots:

1. **Method 1: Simulator Menu**
   - Device → Screenshot (Cmd+S)
   - Save to ~/Documents/screenshots/

2. **Method 2: macOS Screenshot**
   - Click on simulator window
   - Cmd+Shift+4 → Space → Click simulator
   - Drag files to ~/Documents/screenshots/

### Required Screenshots per Language:

#### English (en-US)
1. **01_MainDashboard** - Today's smoking count and main view
2. **02_Statistics** - Statistics tab with charts and data
3. **03_Settings** - Settings/profile page
4. **04_AddCigarette** - Add cigarette flow
5. **05_AICoach** - AI Coach feature screen
6. **06_AICoach_Dark** - AI Coach in dark mode (toggle in Settings)
7. **07_Tags** - Tag management screen
8. **08_Insights** - Insights/analytics view
9. **09_QuitPlan** - Quit plan feature
10. **10_Profile_Dark** - Profile screen in dark mode

#### Navigation Tips:
- **Statistics Tab**: Tap the second tab at bottom
- **Settings Tab**: Tap the third tab at bottom  
- **AI Coach**: Look for AI/Coach feature in main tab or settings
- **Dark Mode**: Settings → Display → Dark Mode
- **Add Cigarette**: Plus button or dedicated screen
- **Tags**: Usually in add cigarette flow or settings
- **Insights**: May be part of statistics or separate section

### Apple Watch Screenshots (5 total)
Boot the watch simulator and launch the watch app:

```bash
xcrun simctl boot C8EDC314-2FBD-43F9-A516-22FE58163E35
xcrun simctl launch C8EDC314-2FBD-43F9-A516-22FE58163E35 com.mirror-labs.MirrorSmokerStopper.watchkitapp
```

Take screenshots of:
1. **Watch_01_MainView** - Main watch face/app
2. **Watch_02_AddCigarette** - Add cigarette on watch
3. **Watch_03_TodayCount** - Today's count display
4. **Watch_04_Complications** - Watch complications if available
5. **Watch_05_Settings** - Watch settings/preferences

### Languages to Complete:
- ✅ English (en-US) - Complete manually first
- ⏳ Spanish (es-ES) - Change simulator language
- ⏳ French (fr-FR) - Change simulator language  
- ⏳ German (de-DE) - Change simulator language
- ⏳ Italian (it-IT) - Change simulator language

### Changing Simulator Language:
1. Settings app in simulator
2. General → Language & Region
3. Add Language → Select language
4. Restart app: `xcrun simctl launch 2911099D-669D-4DB6-8FB9-6DAD0DC0D945 com.mirror-labs.MirrorSmokerStopper`

## File Organization Script

Once manual screenshots are taken, use this script to organize them:

```bash
# Create language directories
mkdir -p ~/Documents/screenshots/en-US
mkdir -p ~/Documents/screenshots/es-ES  
mkdir -p ~/Documents/screenshots/fr-FR
mkdir -p ~/Documents/screenshots/de-DE
mkdir -p ~/Documents/screenshots/it-IT
mkdir -p ~/Documents/screenshots/watch

# Move screenshots to appropriate folders
# User will need to manually organize based on filename patterns
```

## Integration with Fastlane

Once we have working screenshots, we can integrate with Fastlane using the `snapshot` tool:

1. **Create Snapfile**:
```ruby
devices(["iPhone 15"])
languages(["en-US", "es-ES", "fr-FR", "de-DE", "it-IT"])
scheme("MirrorSmokerStopper")
output_directory("./screenshots")
```

2. **Use existing screenshots as reference** for automated version once iOS 26 simulator issues are resolved.

## Next Steps:
1. ✅ Take 10 English screenshots manually using Simulator.app
2. ⏳ Repeat for other 4 languages (40 more screenshots)
3. ⏳ Take 5 Watch screenshots
4. ⏳ Organize files properly
5. ⏳ Test Fastlane integration with working simulators

**Total Required**: 55 screenshots (50 iOS + 5 Watch)