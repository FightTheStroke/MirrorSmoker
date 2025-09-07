#!/bin/bash

# Complete Professional Screenshot Generator
# Captures ALL app screens, light/dark mode, all languages

DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
WATCH_DEVICE_ID="RoberdanWatch26"  # Add Watch device support
BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"
OUTPUT_DIR="shots/complete"

LANGUAGES=("en_US" "es_ES" "fr_FR" "de_DE" "it_IT")
LANGUAGE_CODES=("en-US" "es-ES" "fr-FR" "de-DE" "it-IT")
APPEARANCES=("light" "dark")

echo "🎯 COMPLETE Professional iOS Screenshot Generation"
echo "📱 App: Fight The Smoke (MirrorSmokerStopper)"
echo "🌍 Languages: ${#LANGUAGES[@]}"
echo "🎨 Modes: light + dark"
echo "📱 Platforms: iOS + Widget + Apple Watch"
echo "📂 Output: $OUTPUT_DIR"
echo ""

# Boot simulators
echo "🔄 Preparing simulators..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "iOS simulator already booted"

# Try to boot watch simulator
echo "⌚ Preparing Apple Watch..."
WATCH_ID=$(xcrun simctl list devices -j | jq -r ".devices[] | .[] | select(.name == \"$WATCH_DEVICE_ID\" and .isAvailable == true) | .udid" | head -1)
if [[ -n "$WATCH_ID" ]]; then
    echo "  ✅ Found Apple Watch: $WATCH_ID"
    xcrun simctl boot "$WATCH_ID" 2>/dev/null || echo "Watch already booted"
else
    echo "  ⚠️  Apple Watch '$WATCH_DEVICE_ID' not found - skipping Watch screenshots"
fi

sleep 3

# Clean output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to simulate tab bar navigation
navigate_to_tab() {
    local tab_name="$1"
    local wait_time="${2:-2}"
    
    echo "    🧭 Navigating to $tab_name tab"
    
    # Use simctl UI automation to tap tab bar
    case "$tab_name" in
        "dashboard"|"home")
            # Tap first tab (usually home/dashboard)
            xcrun simctl ui "$DEVICE_ID" tap 95 812  # Bottom left area
            ;;
        "aicoach"|"coach")
            # Tap second tab
            xcrun simctl ui "$DEVICE_ID" tap 190 812  # Bottom second position
            ;;
        "statistics"|"stats")
            # Tap third tab
            xcrun simctl ui "$DEVICE_ID" tap 285 812  # Bottom third position
            ;;
        "settings")
            # Tap fourth tab (rightmost)
            xcrun simctl ui "$DEVICE_ID" tap 380 812  # Bottom right area
            ;;
        "add"|"plus")
            # Tap add button (usually center or specific location)
            xcrun simctl ui "$DEVICE_ID" tap 187.5 780  # Center bottom area
            ;;
    esac
    
    sleep "$wait_time"
}

# Function to take screenshot with proper naming
take_screenshot() {
    local device_id="$1"
    local output_path="$2"
    local screen_name="$3"
    
    local output_dir="$(dirname "$output_path")"
    mkdir -p "$output_dir"
    
    xcrun simctl io "$device_id" screenshot "$output_path" 2>/dev/null
    
    if [[ -f "$output_path" ]]; then
        local size=$(du -h "$output_path" | cut -f1)
        echo "      📸 $screen_name: $size"
        return 0
    else
        echo "      ❌ Failed: $screen_name"
        return 1
    fi
}

# Function to process complete app screenshots
process_app_screens() {
    local locale="$1"
    local lang_code="$2"
    local appearance="$3"
    local base_path="$4"
    
    echo "      📱 Capturing app screens..."
    
    # Launch app
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1
    sleep 4
    
    # Screen 1: Main Dashboard
    take_screenshot "$DEVICE_ID" "$base_path/01_MainDashboard.png" "Main Dashboard"
    
    # Screen 2: AI Coach
    navigate_to_tab "aicoach"
    take_screenshot "$DEVICE_ID" "$base_path/02_AICoach.png" "AI Coach"
    
    # Screen 3: Statistics
    navigate_to_tab "statistics"
    take_screenshot "$DEVICE_ID" "$base_path/03_Statistics.png" "Statistics"
    
    # Screen 4: Settings
    navigate_to_tab "settings"
    take_screenshot "$DEVICE_ID" "$base_path/04_Settings.png" "Settings"
    
    # Screen 5: Add Cigarette (back to main then add)
    navigate_to_tab "dashboard"
    sleep 1
    navigate_to_tab "add"
    take_screenshot "$DEVICE_ID" "$base_path/05_AddCigarette.png" "Add Cigarette"
    
    # Terminate app
    xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1
    sleep 1
}

# Function to setup device for specific language and appearance
setup_device() {
    local locale="$1"
    local lang_code="$2"
    local appearance="$3"
    
    echo "    🌍 Setting language: $lang_code"
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLanguages -array "$lang_code" >/dev/null 2>&1
    xcrun simctl spawn "$DEVICE_ID" defaults write .GlobalPreferences AppleLocale -string "$locale" >/dev/null 2>&1
    
    echo "    🎨 Setting appearance: $appearance"
    if [[ "$appearance" == "dark" ]]; then
        xcrun simctl ui "$DEVICE_ID" appearance dark >/dev/null 2>&1
    else
        xcrun simctl ui "$DEVICE_ID" appearance light >/dev/null 2>&1
    fi
    
    echo "    📊 Setting status bar"
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
    
    sleep 2
}

# Function to capture Home Widget screenshots
capture_widget_screenshots() {
    local locale="$1"
    local appearance="$2"
    local base_path="$3"
    
    echo "      📟 Capturing widget screenshots..."
    
    # Go to home screen
    xcrun simctl ui "$DEVICE_ID" pressButton home >/dev/null 2>&1
    sleep 2
    
    # Take widget screenshot
    take_screenshot "$DEVICE_ID" "$base_path/06_HomeWidget.png" "Home Widget"
    
    # Try to capture widget in edit mode (long press simulation)
    echo "        🔧 Attempting widget edit mode..."
    xcrun simctl ui "$DEVICE_ID" longPress 187.5 400  # Center of screen
    sleep 3
    take_screenshot "$DEVICE_ID" "$base_path/07_WidgetEdit.png" "Widget Edit Mode"
    
    # Exit edit mode
    xcrun simctl ui "$DEVICE_ID" pressButton home >/dev/null 2>&1
    sleep 1
}

# Function to capture Apple Watch screenshots
capture_watch_screenshots() {
    local locale="$1"
    local appearance="$2"
    local base_path="$3"
    
    if [[ -z "$WATCH_ID" ]]; then
        echo "      ⚠️  Skipping Watch screenshots (device not available)"
        return
    fi
    
    echo "      ⌚ Capturing Apple Watch screenshots..."
    
    # Set Watch appearance
    if [[ "$appearance" == "dark" ]]; then
        xcrun simctl ui "$WATCH_ID" appearance dark >/dev/null 2>&1
    else
        xcrun simctl ui "$WATCH_ID" appearance light >/dev/null 2>&1
    fi
    
    # Launch Watch app (if available)
    xcrun simctl launch "$WATCH_ID" "$BUNDLE_ID.watchkitapp" >/dev/null 2>&1 || \
    xcrun simctl launch "$WATCH_ID" "com.mirror-labs.MirrorSmokerStopper.watchkitapp" >/dev/null 2>&1
    sleep 3
    
    # Take Watch screenshots
    take_screenshot "$WATCH_ID" "$base_path/08_WatchMain.png" "Apple Watch Main"
    
    # Try to navigate in Watch app
    xcrun simctl ui "$WATCH_ID" tap 100 100  # Center tap
    sleep 2
    take_screenshot "$WATCH_ID" "$base_path/09_WatchFeature.png" "Apple Watch Feature"
    
    # Go back to Watch face
    xcrun simctl ui "$WATCH_ID" pressButton crown >/dev/null 2>&1
    sleep 1
}

# Main processing loop
total_combinations=$((${#LANGUAGES[@]} * ${#APPEARANCES[@]}))
current=0

for i in "${!LANGUAGES[@]}"; do
    locale="${LANGUAGES[$i]}"
    lang_code="${LANGUAGE_CODES[$i]}"
    
    echo ""
    echo "🌍 [$((i+1))/${#LANGUAGES[@]}] Processing language: $locale ($lang_code)"
    
    for appearance in "${APPEARANCES[@]}"; do
        current=$((current + 1))
        echo ""
        echo "  🎨 [$current/$total_combinations] Processing appearance: $appearance"
        
        # Setup device
        setup_device "$locale" "$lang_code" "$appearance"
        
        # Create output path
        base_path="$OUTPUT_DIR/$locale/$appearance"
        mkdir -p "$base_path"
        
        # Process all screenshots
        process_app_screens "$locale" "$lang_code" "$appearance" "$base_path"
        capture_widget_screenshots "$locale" "$appearance" "$base_path"
        capture_watch_screenshots "$locale" "$appearance" "$base_path"
        
        echo "    ✅ Completed $locale/$appearance"
    done
done

echo ""
echo "🎉 COMPLETE Professional Screenshot Generation Finished!"
echo ""

# Generate comprehensive report
echo "📊 FINAL RESULTS:"
total_screenshots=$(find "$OUTPUT_DIR" -name "*.png" -type f | wc -l | xargs)
total_size=$(du -sh "$OUTPUT_DIR" | cut -f1)
echo "  📸 Total screenshots: $total_screenshots"
echo "  💾 Total size: $total_size"
echo "  🌍 Languages: ${#LANGUAGES[@]}"
echo "  🎨 Modes: ${#APPEARANCES[@]} (light + dark)"
echo "  📱 Platforms: iOS + Widgets + Apple Watch"
echo ""

echo "📈 Screenshots by language and mode:"
for locale in "${LANGUAGES[@]}"; do
    for appearance in "${APPEARANCES[@]}"; do
        if [ -d "$OUTPUT_DIR/$locale/$appearance" ]; then
            count=$(find "$OUTPUT_DIR/$locale/$appearance" -name "*.png" -type f | wc -l | xargs)
            size=$(du -sh "$OUTPUT_DIR/$locale/$appearance" 2>/dev/null | cut -f1 || echo "0B")
            echo "  $locale/$appearance: $count screenshots ($size)"
        fi
    done
done

echo ""
echo "🏆 READY FOR APP STORE SUBMISSION!"
echo "📂 Screenshots location: $OUTPUT_DIR"
echo ""
echo "📋 All screenshots:"
find "$OUTPUT_DIR" -name "*.png" -type f | sort