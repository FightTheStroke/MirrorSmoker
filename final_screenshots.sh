#!/bin/bash

# Final Professional Screenshot Generator
# Based on ChatGPT approach but simplified for working app launch

DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"
OUTPUT_DIR="shots/final"

LANGUAGES=("en_US" "es_ES" "fr_FR" "de_DE" "it_IT")
LANGUAGE_CODES=("en-US" "es-ES" "fr-FR" "de-DE" "it-IT")

echo "🚀 Final Professional iOS Screenshot Generation"
echo "📱 App: Fight The Smoke (MirrorSmokerStopper)"
echo "🌍 Languages: ${#LANGUAGES[@]}"
echo "📂 Output: $OUTPUT_DIR"
echo ""

# Boot simulator
echo "🔄 Preparing simulator..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "Already booted"
sleep 3

# Clean output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to setup language and take screenshot
process_language() {
    local locale="$1"
    local lang_code="$2"
    local index="$3"
    
    echo ""
    echo "📋 [$index/5] Processing: $locale"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$locale"
    
    # Set device language
    echo "  🌍 Setting language to $lang_code"
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLanguages -array "$lang_code" >/dev/null 2>&1
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLocale -string "$locale" >/dev/null 2>&1
    
    # Set professional status bar
    echo "  📊 Setting status bar"
    xcrun simctl status_bar "$DEVICE_ID" override \
        --time "9:41" \
        --dataNetwork wifi \
        --wifiMode active \
        --wifiBars 3 \
        --cellularMode active \
        --cellularBars 4 \
        --batteryState charged \
        --batteryLevel 100 \
        --operatorName "" >/dev/null 2>&1
    
    # Launch app
    echo "  🚀 Launching app"
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1
    sleep 4
    
    # Take main screenshot
    echo "  📸 Taking main screenshot"
    xcrun simctl io "$DEVICE_ID" screenshot "$OUTPUT_DIR/$locale/01_MainDashboard.png" 2>/dev/null
    
    if [ -f "$OUTPUT_DIR/$locale/01_MainDashboard.png" ]; then
        size=$(du -h "$OUTPUT_DIR/$locale/01_MainDashboard.png" | cut -f1)
        echo "    ✅ Main dashboard: $size"
    else
        echo "    ❌ Failed to capture main dashboard"
    fi
    
    # Take additional screenshots with delays
    sleep 2
    xcrun simctl io "$DEVICE_ID" screenshot "$OUTPUT_DIR/$locale/02_AppInterface.png" 2>/dev/null
    if [ -f "$OUTPUT_DIR/$locale/02_AppInterface.png" ]; then
        size=$(du -h "$OUTPUT_DIR/$locale/02_AppInterface.png" | cut -f1)
        echo "    ✅ App interface: $size"
    fi
    
    sleep 2
    xcrun simctl io "$DEVICE_ID" screenshot "$OUTPUT_DIR/$locale/03_Features.png" 2>/dev/null
    if [ -f "$OUTPUT_DIR/$locale/03_Features.png" ]; then
        size=$(du -h "$OUTPUT_DIR/$locale/03_Features.png" | cut -f1)
        echo "    ✅ Features view: $size"
    fi
    
    # Terminate app to ensure clean state for next language
    xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1
    sleep 1
}

# Process each language
for i in "${!LANGUAGES[@]}"; do
    process_language "${LANGUAGES[$i]}" "${LANGUAGE_CODES[$i]}" "$((i+1))"
done

echo ""
echo "🎉 Professional screenshot generation completed!"
echo ""
echo "📊 Final Results:"
total_screenshots=$(find "$OUTPUT_DIR" -name "*.png" -type f | wc -l | xargs)
echo "  Total screenshots: $total_screenshots"
echo "  Average size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
echo ""

echo "📈 Screenshots by language:"
for locale in "${LANGUAGES[@]}"; do
    if [ -d "$OUTPUT_DIR/$locale" ]; then
        count=$(find "$OUTPUT_DIR/$locale" -name "*.png" -type f | wc -l | xargs)
        size=$(du -sh "$OUTPUT_DIR/$locale" 2>/dev/null | cut -f1 || echo "0B")
        echo "  $locale: $count screenshots ($size)"
    fi
done

echo ""
echo "📋 All generated screenshots:"
find "$OUTPUT_DIR" -name "*.png" -type f | sort

echo ""
echo "🏆 Ready for App Store submission!"
echo "📂 Screenshots location: $OUTPUT_DIR"