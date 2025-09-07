# 🚀 Fastlane Commands for Fight The Smoke

## Setup Commands

```bash
# Install fastlane if not already installed
sudo gem install fastlane

# Navigate to project directory
cd /Users/roberdan/Desktop/MirrorSmoker

# Initialize fastlane (if needed)
fastlane init
```

## Main Deployment Commands

### 📝 Update App Store Metadata Only
```bash
fastlane update_metadata
```
Updates all App Store text, descriptions, keywords in 5 languages without touching screenshots or binary.

### 📱 Upload Screenshots Only  
```bash
fastlane upload_screenshots
```
Uploads screenshots from `./screenshots/` directory to App Store Connect.

### 🔨 Build App
```bash
fastlane build
```
Builds release version, increments build number.

### 🚀 Submit to TestFlight
```bash
fastlane beta
```
Builds app and submits to TestFlight with beta notes.

### 🏪 Submit to App Store
```bash
fastlane release
```
Full release: builds app, uploads screenshots, metadata, and submits for review.

### 🔄 Complete Deployment (All in One)
```bash
fastlane deploy
```
Does everything: info → metadata → screenshots → release submission.

## Utility Commands

### 📊 App Information
```bash
fastlane info
```
Shows current version, build number, and app details.

### 🧹 Clean Build Artifacts
```bash
fastlane clean
```
Removes build files and derived data.

## Before You Start

1. **Update Appfile**: Replace placeholder team IDs with your real ones
2. **Add Screenshots**: Put your manual screenshots in `./screenshots/` organized by language:
   ```
   screenshots/
   ├── en-US/
   ├── es-ES/
   ├── fr-FR/
   ├── de-DE/
   └── it-IT/
   ```
3. **App Store Connect**: Make sure app exists in App Store Connect
4. **Certificates**: Ensure you have valid certificates and provisioning profiles

## Screenshot Directory Structure

```
screenshots/
├── en-US/
│   ├── 01_MainDashboard.png
│   ├── 02_Statistics.png
│   ├── 03_Settings.png
│   ├── 04_AddCigarette.png
│   └── 05_AICoach.png
├── es-ES/
│   ├── 01_MainDashboard.png
│   └── ...
└── ... (other languages)
```

## Troubleshooting

- **Build fails**: Check certificates in Keychain Access
- **Metadata fails**: Verify App Store Connect app status
- **Upload fails**: Check internet connection and Apple system status
- **Screenshots fail**: Verify file format (PNG) and resolution

## What's Included

✅ **Metadata in 5 Languages**: EN, ES, FR, DE, IT  
✅ **App Store Categories**: Medical + Health & Fitness  
✅ **Age Rating**: Configured for medical/health app  
✅ **Export Compliance**: No encryption declarations  
✅ **Review Information**: Contact details and app description  
✅ **Release Notes**: AI Coach feature highlights  
✅ **Build Management**: Auto-increment build numbers  
✅ **Error Handling**: Comprehensive error reporting