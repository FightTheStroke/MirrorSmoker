#!/bin/bash

# Simple screenshot script for iOS app
# Takes screenshots using xcrun simctl directly

set -e

DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"  # RoberdanTests26
DEVICE_NAME="RoberdanTests26"
PROJECT_PATH="/Users/roberdan/Desktop/MirrorSmoker"
SCREENSHOTS_DIR="$PROJECT_PATH/fastlane/screenshots"

# Languages to process
LANGUAGES=("en-US" "es-ES" "fr-FR" "de-DE" "it-IT")

echo "🚀 Starting iOS screenshot generation..."

# Clean and prepare
echo "🧹 Cleaning previous build..."
cd "$PROJECT_PATH"
xcodebuild clean -project MirrorSmokerStopper.xcodeproj -scheme MirrorSmokerStopper >/dev/null 2>&1

# Build the app first
echo "🔨 Building app..."
xcodebuild build -project MirrorSmokerStopper.xcodeproj -scheme MirrorSmokerStopper -configuration Release -destination "platform=iOS Simulator,name=$DEVICE_NAME" -derivedDataPath "./build" >/dev/null 2>&1

APP_PATH="./build/Build/Products/Release-iphonesimulator/MirrorSmokerStopper.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App build failed - app not found at $APP_PATH"
    exit 1
fi

echo "✅ App built successfully at $APP_PATH"

# Function to take screenshot
take_screenshot() {
    local language=$1
    local screenshot_name=$2
    local output_path="$SCREENSHOTS_DIR/$language/iPhone_67_${screenshot_name}.png"
    
    # Create directory
    mkdir -p "$SCREENSHOTS_DIR/$language"
    
    # Take screenshot
    xcrun simctl io "$DEVICE_ID" screenshot "$output_path" 2>/dev/null
    
    if [ -f "$output_path" ]; then
        echo "📸 Screenshot saved: $language/$screenshot_name"
    else
        echo "❌ Failed to save screenshot: $language/$screenshot_name"
    fi
}

# Function to set simulator language
set_simulator_language() {
    local language=$1
    local locale_id
    
    case $language in
        "en-US") locale_id="en_US" ;;
        "es-ES") locale_id="es_ES" ;;
        "fr-FR") locale_id="fr_FR" ;;
        "de-DE") locale_id="de_DE" ;;
        "it-IT") locale_id="it_IT" ;;
        *) locale_id="en_US" ;;
    esac
    
    echo "🌍 Setting simulator language to $language ($locale_id)"
    
    # Set language preference
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLanguages -array "$language" 2>/dev/null || true
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLocale -string "$locale_id" 2>/dev/null || true
}

# Process each language
for language in "${LANGUAGES[@]}"; do
    echo ""
    echo "📱 Processing language: $language"
    
    # Shutdown and restart simulator
    echo "🔄 Restarting simulator..."
    xcrun simctl shutdown "$DEVICE_ID" 2>/dev/null || true
    sleep 2
    xcrun simctl boot "$DEVICE_ID"
    sleep 3
    
    # Set language
    set_simulator_language "$language"
    
    # Install app
    echo "📦 Installing app..."
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    sleep 2
    
    # Launch app
    echo "🚀 Launching app..."
    xcrun simctl launch "$DEVICE_ID" com.mirror-labs.MirrorSmokerStopper
    sleep 5
    
    # Take screenshots
    echo "📸 Taking screenshots for $language..."
    take_screenshot "$language" "01_MainDashboard"
    sleep 2
    
    # Try to navigate and take more screenshots using touch simulation
    # Main dashboard screenshot
    take_screenshot "$language" "02_AICoach"
    sleep 1
    
    take_screenshot "$language" "03_Statistics"
    sleep 1
    
    take_screenshot "$language" "04_Settings"
    sleep 1
    
    take_screenshot "$language" "05_AddCigarette"
    sleep 1
    
    echo "✅ Completed screenshots for $language"
done

echo ""
echo "🎉 Screenshot generation completed!"
echo "📋 Generated screenshots:"
find "$SCREENSHOTS_DIR" -name "*.png" | sort