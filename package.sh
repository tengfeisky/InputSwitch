#!/bin/bash

set -e

APP_NAME="InputSwitch"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building ${APP_NAME}..."
swift build -c release

echo "Creating App Bundle structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

echo "Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Icon generation
ICON_SOURCE="Sources/InputSwitch/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png"
if [ -f "$ICON_SOURCE" ]; then
    echo "Generating App Icon..."
    ICONSET_DIR="InputSwitch.iconset"
    mkdir -p "$ICONSET_DIR"
    
    sips -z 16 16     "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
    sips -z 32 32     "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
    sips -z 32 32     "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
    sips -z 64 64     "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
    sips -z 128 128   "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
    sips -z 256 256   "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
    sips -z 512 512   "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
    sips -z 1024 1024 "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null
    
    iconutil -c icns "$ICONSET_DIR" -o "${RESOURCES_DIR}/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
else
    echo "Warning: Icon source not found at $ICON_SOURCE"
fi

echo "Creating Info.plist..."
cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Optional: Create a PkgInfo file
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# Ad-hoc signing
echo "Signing app..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "Done! ${APP_BUNDLE} created."
