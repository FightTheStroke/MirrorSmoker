#!/bin/bash

# Manual Screenshot Script for MirrorSmokerStopper
# This script manually captures screenshots by launching the app and navigating through tabs

SIMULATOR_ID="RoberdanTests26"
DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
APP_BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"
OUTPUT_DIR="./manual_screenshots"

echo "📱 Starting manual screenshot capture..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Reset simulator
echo "🔄 Resetting simulator..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
sleep 2
xcrun simctl boot "$SIMULATOR_ID"
sleep 3

# Build and install the app
echo "🔨 Building and installing app..."
xcodebuild -project MirrorSmokerStopper.xcodeproj \
    -scheme MirrorSmokerStopper \
    -destination "platform=iOS Simulator,name=$SIMULATOR_ID" \
    -configuration Debug \
    build 2>/dev/null

# Install the app
xcrun simctl install "$SIMULATOR_ID" ~/Library/Developer/Xcode/DerivedData/MirrorSmokerStopper-*/Build/Products/Debug-iphonesimulator/MirrorSmokerStopper.app 2>/dev/null || true

# Launch the app
echo "🚀 Launching app..."
xcrun simctl launch "$SIMULATOR_ID" "$APP_BUNDLE_ID"
sleep 4

# Screenshot 1: Main Dashboard
echo "📸 Capturing Main Dashboard..."
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_DIR/01_MainDashboard.png"
sleep 1

# Navigate to Statistics tab (middle tab - chart icon)
echo "📊 Navigating to Statistics..."
xcrun simctl ui "$SIMULATOR_ID" tap 589 2535
sleep 3
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_DIR/02_Statistics.png"
sleep 1

# Navigate to Settings tab (right tab - gear icon) 
echo "⚙️ Navigating to Settings..."
xcrun simctl ui "$SIMULATOR_ID" tap 884 2535
sleep 2
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_DIR/03_Settings.png"
sleep 1

# Go back to main tab
echo "🏠 Back to Main tab..."
xcrun simctl ui "$SIMULATOR_ID" tap 294 2535
sleep 2

# Try to find and tap FAB or Add button (center-bottom area where FAB usually is)
echo "➕ Looking for Add Cigarette button..."
xcrun simctl ui "$SIMULATOR_ID" tap 187 650  # Try center-bottom area first
sleep 2
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_DIR/04_AddCigarette.png"
sleep 1

# Final screenshot - App Interface
echo "📱 Final app interface..."
xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_DIR/05_AppInterface.png"

echo "✅ Manual screenshots completed!"
echo "📂 Screenshots saved to: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"/*.png 2>/dev/null || echo "No screenshots found"