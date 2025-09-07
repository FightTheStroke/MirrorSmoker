#!/bin/bash

# Direct iOS screenshots using xcrun simctl
# This script launches the app and takes screenshots directly

set -e

echo "🎯 Starting direct iOS screenshot capture..."

# Configuration
IOS_SIMULATOR_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
WATCH_SIMULATOR_ID="C8EDC314-2FBD-43F9-A516-22FE58163E35" 
APP_BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"
WATCH_APP_BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper.watchkitapp"

# Output directory
OUTPUT_DIR="$HOME/Documents/screenshots"
WATCH_OUTPUT_DIR="$HOME/Documents/watch-screenshots"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$WATCH_OUTPUT_DIR"

echo "📱 iOS Simulator: $IOS_SIMULATOR_ID"
echo "⌚ Watch Simulator: $WATCH_SIMULATOR_ID"
echo "📂 iOS Output: $OUTPUT_DIR"
echo "📂 Watch Output: $WATCH_OUTPUT_DIR"

# Function to take iOS screenshot
take_ios_screenshot() {
    local filename="$1"
    local description="$2"
    
    echo "📸 Taking iOS screenshot: $description"
    sleep 2
    
    xcrun simctl io "$IOS_SIMULATOR_ID" screenshot "$OUTPUT_DIR/${filename}.png"
    echo "✅ Saved: $OUTPUT_DIR/${filename}.png"
}

# Function to take Watch screenshot
take_watch_screenshot() {
    local filename="$1"
    local description="$2"
    
    echo "📸 Taking Watch screenshot: $description"
    sleep 2
    
    xcrun simctl io "$WATCH_SIMULATOR_ID" screenshot "$WATCH_OUTPUT_DIR/${filename}.png"
    echo "✅ Saved: $WATCH_OUTPUT_DIR/${filename}.png"
}

echo ""
echo "🚀 Starting iOS app..."
xcrun simctl launch "$IOS_SIMULATOR_ID" "$APP_BUNDLE_ID"

# Wait for app to launch and settle
sleep 5

# Take iOS screenshots
take_ios_screenshot "01_MainDashboard" "Main Dashboard - Today's smoking count"

echo ""
echo "📋 iOS screenshot capture completed!"
echo "Generated $(ls -1 "$OUTPUT_DIR" | wc -l | tr -d ' ') iOS screenshots"

echo ""
echo "🚀 Starting Watch app..."
xcrun simctl launch "$WATCH_SIMULATOR_ID" "$WATCH_APP_BUNDLE_ID"

# Wait for watch app to launch
sleep 5

# Take Watch screenshots
take_watch_screenshot "Watch_01_MainView" "Watch Main View"

echo ""
echo "📋 Watch screenshot capture completed!"
echo "Generated $(ls -1 "$WATCH_OUTPUT_DIR" | wc -l | tr -d ' ') Watch screenshots"

echo ""
echo "✅ All screenshots completed!"
echo "📂 iOS screenshots: $OUTPUT_DIR"
echo "📂 Watch screenshots: $WATCH_OUTPUT_DIR"

# List all created files
echo ""
echo "📋 Created files:"
echo "iOS:"
for file in "$OUTPUT_DIR"/*.png; do
    if [ -f "$file" ]; then
        echo "   • $(basename "$file")"
    fi
done

echo "Watch:"
for file in "$WATCH_OUTPUT_DIR"/*.png; do
    if [ -f "$file" ]; then
        echo "   • $(basename "$file")"
    fi
done

echo ""
echo "🎉 Screenshot generation complete!"