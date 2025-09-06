#!/bin/bash

# Generate placeholder screenshots for App Store submission
# These are the required sizes for iOS App Store

echo "🎨 Generating placeholder screenshots for App Store..."

# Create temporary directory
mkdir -p temp_screenshots

# Define screenshot sizes
# iPhone 6.7" (iPhone 16 Pro Max, iPhone 15 Pro Max, etc.)
IPHONE_67_WIDTH=1320
IPHONE_67_HEIGHT=2868

# iPhone 6.5" (iPhone 11 Pro Max, XS Max)  
IPHONE_65_WIDTH=1284
IPHONE_65_HEIGHT=2778

# iPhone 5.5" (iPhone 8 Plus, 7 Plus, 6s Plus)
IPHONE_55_WIDTH=1242
IPHONE_55_HEIGHT=2208

# iPad Pro 12.9"
IPAD_129_WIDTH=2048
IPAD_129_HEIGHT=2732

# Languages
LANGUAGES=("en-US" "de-DE" "es-ES" "fr-FR" "it")

# Screenshot names (Apple requires at least 1, max 10)
SCREENSHOTS=(
    "01_MainDashboard"
    "02_AICoach" 
    "03_Statistics"
    "04_Settings"
    "05_AddCigarette"
)

# Generate screenshots for each language
for LANG in "${LANGUAGES[@]}"; do
    echo "📱 Generating screenshots for $LANG..."
    mkdir -p "fastlane/screenshots/$LANG"
    
    # Generate iPhone 6.7" screenshots (required)
    for SCREENSHOT in "${SCREENSHOTS[@]}"; do
        # Create a simple colored rectangle with text using ImageMagick
        # If ImageMagick not installed, create empty files as placeholders
        if command -v convert &> /dev/null; then
            convert -size ${IPHONE_67_WIDTH}x${IPHONE_67_HEIGHT} \
                -background '#1C1C1E' \
                -fill white \
                -gravity center \
                -pointsize 72 \
                label:"MirrorSmokerStopper\n$SCREENSHOT\n$LANG" \
                "fastlane/screenshots/$LANG/iPhone_67_$SCREENSHOT.png"
        else
            # Create empty placeholder files
            touch "fastlane/screenshots/$LANG/iPhone_67_$SCREENSHOT.png"
        fi
    done
    
    # Generate iPad screenshots (optional but recommended)
    for SCREENSHOT in "${SCREENSHOTS[@]}"; do
        if command -v convert &> /dev/null; then
            convert -size ${IPAD_129_WIDTH}x${IPAD_129_HEIGHT} \
                -background '#1C1C1E' \
                -fill white \
                -gravity center \
                -pointsize 96 \
                label:"MirrorSmokerStopper\n$SCREENSHOT\n$LANG" \
                "fastlane/screenshots/$LANG/iPad_129_$SCREENSHOT.png"
        else
            touch "fastlane/screenshots/$LANG/iPad_129_$SCREENSHOT.png"
        fi
    done
done

echo "✅ Placeholder screenshots generated!"
echo "📍 Location: fastlane/screenshots/"
echo ""
echo "⚠️  Note: These are placeholder screenshots."
echo "    Replace them with actual app screenshots before final submission."