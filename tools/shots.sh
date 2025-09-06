#!/bin/bash

# Professional iOS Screenshot Generator
# Based on ChatGPT's superior solution - NO FASTLANE
# Uses only Apple native tools: simctl, xcrun, xcodebuild

set -euo pipefail

CONFIG_FILE="${1:-tools/shots.json}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "🚀 Professional iOS Screenshot Generator"
echo "📋 Config: $CONFIG_FILE"
echo "📂 Project: $PROJECT_ROOT"
echo ""

# Parse JSON config
BUNDLE_ID=$(jq -r '.bundleId' "$CONFIG_FILE")
DEEPLINK_SCHEME=$(jq -r '.deeplinkScheme' "$CONFIG_FILE")
OUTPUT_DIR=$(jq -r '.outputDir' "$CONFIG_FILE")
WAIT_TIME=$(jq -r '.waitTime' "$CONFIG_FILE")
BUILD_FIRST=$(jq -r '.buildFirst' "$CONFIG_FILE")
PROJECT=$(jq -r '.project' "$CONFIG_FILE")
SCHEME=$(jq -r '.scheme' "$CONFIG_FILE")
CONFIGURATION=$(jq -r '.configuration' "$CONFIG_FILE")

# Status bar config
STATUS_TIME=$(jq -r '.statusBar.time' "$CONFIG_FILE")
BATTERY_LEVEL=$(jq -r '.statusBar.batteryLevel' "$CONFIG_FILE")
WIFI_BARS=$(jq -r '.statusBar.wifiBars' "$CONFIG_FILE")
CELLULAR_BARS=$(jq -r '.statusBar.cellularBars' "$CONFIG_FILE")

cd "$PROJECT_ROOT"

echo "📱 App: $BUNDLE_ID"
echo "🔗 Deep Link Scheme: $DEEPLINK_SCHEME"
echo ""

# Build app first if requested
if [[ "$BUILD_FIRST" == "true" ]]; then
    echo "🔨 Building app..."
    xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "generic/platform=iOS Simulator" \
        -quiet || {
            echo "❌ Build failed, trying without Watch app..."
            # Try building without problematic targets
            xcodebuild build \
                -project "$PROJECT" \
                -scheme "$SCHEME" \
                -configuration "$CONFIGURATION" \
                -destination "generic/platform=iOS Simulator" \
                -skipPackagePluginValidation \
                CODE_SIGNING_ALLOWED=NO \
                -quiet || {
                echo "❌ Build failed completely"
                exit 1
            }
    }
    echo "✅ Build completed"
    echo ""
fi

# Function to setup status bar
setup_status_bar() {
    local device_id="$1"
    echo "📊 Setting up status bar for device $device_id"
    
    xcrun simctl status_bar "$device_id" override \
        --time "$STATUS_TIME" \
        --dataNetwork wifi \
        --wifiMode active \
        --wifiBars "$WIFI_BARS" \
        --cellularMode active \
        --cellularBars "$CELLULAR_BARS" \
        --batteryState charged \
        --batteryLevel "$BATTERY_LEVEL" \
        --operatorName "" \
        >/dev/null 2>&1 || echo "⚠️  Status bar setup failed (continuing anyway)"
}

# Function to set device locale and appearance
setup_device() {
    local device_id="$1"
    local locale="$2"
    local appearance="$3"
    
    echo "🌍 Setting up device: locale=$locale, appearance=$appearance"
    
    # Set locale
    xcrun simctl spawn "$device_id" defaults write .GlobalPreferences AppleLanguages -array "${locale/_/-}" >/dev/null 2>&1 || true
    xcrun simctl spawn "$device_id" defaults write .GlobalPreferences AppleLocale -string "$locale" >/dev/null 2>&1 || true
    
    # Set appearance (light/dark mode)
    if [[ "$appearance" == "dark" ]]; then
        xcrun simctl ui "$device_id" appearance dark >/dev/null 2>&1 || true
    else
        xcrun simctl ui "$device_id" appearance light >/dev/null 2>&1 || true
    fi
    
    setup_status_bar "$device_id"
}

# Function to take screenshot
take_screenshot() {
    local device_id="$1"
    local device_name="$2"
    local locale="$3"
    local appearance="$4"
    local screen_name="$5"
    
    local safe_device_name=$(echo "$device_name" | sed 's/[^a-zA-Z0-9]/_/g')
    local output_path="$OUTPUT_DIR/${safe_device_name}/${locale}/${appearance}/${screen_name}.png"
    local output_dir="$(dirname "$output_path")"
    
    mkdir -p "$output_dir"
    
    echo "📸 Taking screenshot: $screen_name"
    xcrun simctl io "$device_id" screenshot "$output_path" >/dev/null 2>&1
    
    if [[ -f "$output_path" ]]; then
        local size=$(du -h "$output_path" | cut -f1)
        echo "  ✅ $output_path ($size)"
    else
        echo "  ❌ Failed: $output_path"
    fi
}

# Function to launch app with marketing screen
launch_app_screen() {
    local device_id="$1"
    local screen_config="$2"
    
    local screen_name=$(echo "$screen_config" | jq -r '.name')
    local deeplink=$(echo "$screen_config" | jq -r '.deeplink')
    local fallback=$(echo "$screen_config" | jq -r '.fallback')
    
    echo "🚀 Launching app for screen: $screen_name"
    
    # Try deeplink first, then fallback to launch arguments
    if [[ "$deeplink" != "null" ]] && [[ "$DEEPLINK_SCHEME" != "null" ]]; then
        echo "  🔗 Using deeplink: $deeplink"
        xcrun simctl openurl "$device_id" "$deeplink" >/dev/null 2>&1 || {
            echo "  ⚠️  Deeplink failed, trying launch arguments"
            if [[ "$fallback" != "null" ]]; then
                xcrun simctl launch "$device_id" "$BUNDLE_ID" "$fallback" >/dev/null 2>&1
            else
                xcrun simctl launch "$device_id" "$BUNDLE_ID" >/dev/null 2>&1
            fi
        }
    else
        echo "  📱 Using launch arguments"
        if [[ "$fallback" != "null" ]]; then
            xcrun simctl launch "$device_id" "$BUNDLE_ID" "$fallback" >/dev/null 2>&1
        else
            xcrun simctl launch "$device_id" "$BUNDLE_ID" >/dev/null 2>&1
        fi
    fi
    
    sleep "$WAIT_TIME"
}

# Get available simulators
get_device_id() {
    local device_name="$1"
    xcrun simctl list devices -j | jq -r ".devices[] | .[] | select(.name == \"$device_name\" and .isAvailable == true) | .udid" | head -1
}

# Main execution
echo "🧹 Cleaning output directory: $OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Process each device
jq -r '.devices[]' "$CONFIG_FILE" | while read -r device_name; do
    echo ""
    echo "📱 Processing device: $device_name"
    
    device_id=$(get_device_id "$device_name")
    if [[ -z "$device_id" ]]; then
        echo "  ❌ Device not available: $device_name"
        continue
    fi
    
    echo "  🆔 Device ID: $device_id"
    
    # Boot device if needed
    xcrun simctl boot "$device_id" >/dev/null 2>&1 || true
    sleep 3
    
    # Process each locale
    jq -r '.locales[]' "$CONFIG_FILE" | while read -r locale; do
        echo ""
        echo "  🌍 Processing locale: $locale"
        
        # Process each appearance
        jq -r '.appearances[]' "$CONFIG_FILE" | while read -r appearance; do
            echo ""
            echo "    🎨 Processing appearance: $appearance"
            
            # Setup device for this locale/appearance
            setup_device "$device_id" "$locale" "$appearance"
            sleep 2
            
            # Process each screen
            jq -c '.screens[]' "$CONFIG_FILE" | while read -r screen_config; do
                screen_name=$(echo "$screen_config" | jq -r '.name')
                
                echo ""
                echo "      📋 Processing screen: $screen_name"
                
                # Launch app with specific screen
                launch_app_screen "$device_id" "$screen_config"
                
                # Take screenshot
                take_screenshot "$device_id" "$device_name" "$locale" "$appearance" "$screen_name"
                
                sleep 1
            done
        done
    done
    
    # Shutdown device
    xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true
done

echo ""
echo "🎉 Screenshot generation completed!"
echo ""
echo "📊 Summary:"
total_screenshots=$(find "$OUTPUT_DIR" -name "*.png" -type f | wc -l | xargs)
echo "  Total screenshots: $total_screenshots"
echo "  Output directory: $OUTPUT_DIR"
echo ""
echo "📋 Generated screenshots:"
find "$OUTPUT_DIR" -name "*.png" -type f | sort

# Generate summary by language
echo ""
echo "📈 Screenshots by language:"
jq -r '.locales[]' "$CONFIG_FILE" | while read -r locale; do
    count=$(find "$OUTPUT_DIR" -path "*/$locale/*" -name "*.png" -type f | wc -l | xargs)
    echo "  $locale: $count screenshots"
done