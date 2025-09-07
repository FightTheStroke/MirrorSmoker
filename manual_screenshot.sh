#!/bin/bash

# Manual screenshot script - no complex building required
# Just captures simulator screenshots directly

DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
SCREENSHOTS_DIR="/Users/roberdan/Desktop/MirrorSmoker/fastlane/screenshots"
LANGUAGES=("en-US" "es-ES" "fr-FR" "de-DE" "it-IT")

echo "🚀 Manual iOS Screenshot Generation"
echo "📱 Device: RoberdanTests26 ($DEVICE_ID)"

# Boot simulator
echo "🔄 Booting simulator..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "Simulator already booted"
sleep 5

# Open Simulator app to make it visible
echo "👁️  Opening Simulator app..."
open -a Simulator

# Wait a moment for Simulator to open
sleep 3

# Create screenshot directories for all languages
for lang in "${LANGUAGES[@]}"; do
    mkdir -p "$SCREENSHOTS_DIR/$lang"
    echo "📁 Created directory for $lang"
done

echo ""
echo "📸 Ready to take screenshots!"
echo "Instructions:"
echo "1. Open your MirrorSmokerStopper app manually in the simulator"
echo "2. Navigate to different screens"
echo "3. Press ENTER after each navigation to capture screenshot"
echo ""

# Function to take screenshot
take_screenshot() {
    local name=$1
    local description=$2
    
    echo "📸 Taking screenshot: $description"
    
    for lang in "${LANGUAGES[@]}"; do
        local file_path="$SCREENSHOTS_DIR/$lang/iPhone_67_${name}.png"
        xcrun simctl io "$DEVICE_ID" screenshot "$file_path" 2>/dev/null
        if [ -f "$file_path" ]; then
            echo "  ✅ $lang: $(basename "$file_path")"
        else
            echo "  ❌ $lang: Failed"
        fi
    done
    echo ""
}

echo "📱 Navigate to the main dashboard and press ENTER"
read -p "Press ENTER when ready..."
take_screenshot "01_MainDashboard" "Main Dashboard Screen"

echo "📱 Navigate to AI Coach tab and press ENTER"
read -p "Press ENTER when ready..."
take_screenshot "02_AICoach" "AI Coach Screen"

echo "📱 Navigate to Statistics tab and press ENTER"
read -p "Press ENTER when ready..."
take_screenshot "03_Statistics" "Statistics Screen"

echo "📱 Navigate to Settings tab and press ENTER"
read -p "Press ENTER when ready..."
take_screenshot "04_Settings" "Settings Screen"

echo "📱 Go to add cigarette screen and press ENTER"
read -p "Press ENTER when ready..."
take_screenshot "05_AddCigarette" "Add Cigarette Screen"

echo ""
echo "🎉 Manual screenshot capture completed!"
echo "📋 Generated screenshots:"
find "$SCREENSHOTS_DIR" -name "*.png" -type f | sort

echo ""
echo "📊 Screenshot count per language:"
for lang in "${LANGUAGES[@]}"; do
    count=$(find "$SCREENSHOTS_DIR/$lang" -name "*.png" -type f | wc -l | xargs)
    echo "  $lang: $count screenshots"
done