#!/bin/bash

# Simple test to verify app launches and we can take screenshots

DEVICE_ID="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"
BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"

echo "🚀 Basic Screenshot Test"
echo "📱 Device: RoberdanTests26 ($DEVICE_ID)"
echo "📦 Bundle: $BUNDLE_ID"
echo ""

# Boot simulator
echo "🔄 Booting simulator..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "Already booted"
sleep 3

# Set status bar
echo "📊 Setting status bar..."
xcrun simctl status_bar "$DEVICE_ID" override \
  --time "9:41" \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100 \
  --operatorName "" >/dev/null 2>&1 || echo "⚠️  Status bar setup failed"

# Check if app is installed
echo "🔍 Checking if app is installed..."
if xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1; then
    echo "✅ App launched successfully!"
    sleep 5
    
    # Take a screenshot
    mkdir -p shots/test
    xcrun simctl io "$DEVICE_ID" screenshot "shots/test/app_screenshot.png" 2>/dev/null
    
    if [ -f "shots/test/app_screenshot.png" ]; then
        echo "📸 Screenshot taken: shots/test/app_screenshot.png"
        ls -lah shots/test/app_screenshot.png
    else
        echo "❌ Screenshot failed"
    fi
else
    echo "❌ App not installed or launch failed"
    echo "📱 Let's try to build and install first..."
    
    # Try to build and install a simple version
    echo "🔨 Building app for simulator..."
    xcodebuild build \
        -project MirrorSmokerStopper.xcodeproj \
        -scheme MirrorSmokerStopper \
        -configuration Debug \
        -destination "platform=iOS Simulator,name=RoberdanTests26" \
        -derivedDataPath ./test_build \
        CODE_SIGNING_ALLOWED=NO >/dev/null 2>&1
    
    APP_PATH="./test_build/Build/Products/Debug-iphonesimulator/MirrorSmokerStopper.app"
    
    if [ -d "$APP_PATH" ]; then
        echo "✅ Build successful: $APP_PATH"
        
        # Install app
        echo "📦 Installing app..."
        xcrun simctl install "$DEVICE_ID" "$APP_PATH" >/dev/null 2>&1
        
        echo "🚀 Launching app..."
        xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1
        sleep 5
        
        # Take screenshot
        mkdir -p shots/test
        xcrun simctl io "$DEVICE_ID" screenshot "shots/test/app_screenshot.png" 2>/dev/null
        
        if [ -f "shots/test/app_screenshot.png" ]; then
            echo "📸 Screenshot taken: shots/test/app_screenshot.png"
            ls -lah shots/test/app_screenshot.png
        else
            echo "❌ Screenshot failed"
        fi
    else
        echo "❌ Build failed"
        exit 1
    fi
fi

echo ""
echo "🎉 Basic test completed!"