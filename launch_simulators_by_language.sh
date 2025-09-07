#!/bin/bash

# Script per avviare simulatori per lingua e prendere screenshot

APP_BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper"
WATCH_APP_BUNDLE_ID="com.mirror-labs.MirrorSmokerStopper.watchkitapp"

# IDs dei simulatori
EN_IOS="2911099D-669D-4DB6-8FB9-6DAD0DC0D945"     # Già bootato
ES_IOS="F830F326-6AC8-49D2-BC37-63DCDA0ED5CC"
FR_IOS="664BC3E2-557E-4922-816C-EC3F0726EE48" 
DE_IOS="DFB8A890-04EF-4FA3-A37D-D61CC923D170"
IT_IOS="D456F855-EE54-4300-907A-B07CB45C0F3D"

EN_WATCH="C8EDC314-2FBD-43F9-A516-22FE58163E35"   # Originale
ES_WATCH="119425E5-9EA1-42A1-B422-82AE842D0B18"
FR_WATCH="38D624E6-A99D-44E6-BE5F-3FC9BE5D521C"
DE_WATCH="094EBDE4-7CD7-4A5A-A68D-F443D38655B5"
IT_WATCH="98E0D96B-07BA-4FC3-9279-EAAFEA298F38"

# Funzione per lanciare simulatore per lingua
launch_language() {
    local lang=$1
    local ios_id=$2
    local watch_id=$3
    
    echo ""
    echo "🌍 === $lang LANGUAGE SIMULATORS ==="
    echo "📱 iOS: $ios_id"
    echo "⌚ Watch: $watch_id"
    
    # Boot simulators
    echo "🚀 Booting simulators..."
    xcrun simctl boot "$ios_id"
    xcrun simctl boot "$watch_id"
    
    # Wait for boot
    sleep 8
    
    # Launch apps
    echo "📱 Launching iOS app..."
    xcrun simctl launch "$ios_id" "$APP_BUNDLE_ID"
    
    echo "⌚ Launching Watch app..."
    xcrun simctl launch "$watch_id" "$WATCH_APP_BUNDLE_ID"
    
    echo "✅ $lang simulators ready!"
    echo "📂 Save screenshots to: /Users/roberdan/Desktop/MirrorSmoker/screenshots/${lang,,}/"
    
    # Create directory
    mkdir -p "/Users/roberdan/Desktop/MirrorSmoker/screenshots/${lang,,}"
    
    echo ""
    echo "🎯 MANUAL STEPS:"
    echo "1. Open Simulator app"
    echo "2. Change language: Settings > General > Language & Region > Add $lang"
    echo "3. Take screenshots with Cmd+S"
    echo "4. Save to: /Users/roberdan/Desktop/MirrorSmoker/screenshots/${lang,,}/"
    echo ""
    
    read -p "⏸️  Press ENTER when done with $lang screenshots..."
}

# Menu di scelta
echo "📱 SIMULATORI DISPONIBILI PER SCREENSHOT:"
echo ""
echo "1. 🇺🇸 English (EN) - ALREADY RUNNING"
echo "2. 🇪🇸 Spanish (ES)"  
echo "3. 🇫🇷 French (FR)"
echo "4. 🇩🇪 German (DE)"
echo "5. 🇮🇹 Italian (IT)"
echo "6. 🚀 ALL LANGUAGES (one by one)"
echo ""

read -p "Choose language (1-6): " choice

case $choice in
    1)
        echo "✅ English already running on $EN_IOS"
        mkdir -p "/Users/roberdan/Desktop/MirrorSmoker/screenshots/en"
        open -a Simulator
        ;;
    2)
        launch_language "Spanish" "$ES_IOS" "$ES_WATCH"
        ;;
    3)
        launch_language "French" "$FR_IOS" "$FR_WATCH"  
        ;;
    4)
        launch_language "German" "$DE_IOS" "$DE_WATCH"
        ;;
    5)
        launch_language "Italian" "$IT_IOS" "$IT_WATCH"
        ;;
    6)
        echo "🚀 Launching ALL languages one by one..."
        launch_language "Spanish" "$ES_IOS" "$ES_WATCH"
        launch_language "French" "$FR_IOS" "$FR_WATCH"
        launch_language "German" "$DE_IOS" "$DE_WATCH"
        launch_language "Italian" "$IT_IOS" "$IT_WATCH"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "✅ Screenshot session completed!"