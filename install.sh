#!/bin/bash
# install.sh — Build OpenRightClick (Release) and install to /Applications

set -euo pipefail

XCODEBUILD="/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
PROJECT="OpenRightClick.xcodeproj"
SCHEME="OpenRightClick"
CONFIG="Release"
APP_NAME="OpenRightClick.app"
INSTALL_DIR="/Applications"

echo "▶  Building $SCHEME ($CONFIG)…"
"$XCODEBUILD" \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath ".build" \
    build 2>&1 | grep -E "(error:|warning:|Build succeeded|Build FAILED|Signing)" || true

# Confirm the build succeeded
APP_SRC=".build/Build/Products/$CONFIG/$APP_NAME"
if [ ! -d "$APP_SRC" ]; then
    echo "❌  Build failed — $APP_SRC not found."
    echo "    Run: $XCODEBUILD -project $PROJECT -scheme $SCHEME -configuration $CONFIG build"
    echo "    to see the full error output."
    exit 1
fi

echo "▶  Installing to $INSTALL_DIR/$APP_NAME…"
# Remove old version if present
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
    echo "   Removing old version…"
    rm -rf "$INSTALL_DIR/$APP_NAME"
fi
cp -R "$APP_SRC" "$INSTALL_DIR/$APP_NAME"

echo "▶  Removing quarantine attribute…"
xattr -rd com.apple.quarantine "$INSTALL_DIR/$APP_NAME" 2>/dev/null || true

echo ""
echo "✅  Done! OpenRightClick installed to $INSTALL_DIR/$APP_NAME"
echo ""
echo "Next steps:"
echo "  1. Open $INSTALL_DIR/$APP_NAME"
echo "  2. Click 'Open System Settings' to enable the Finder extension"
echo "  3. Right-click in Finder to see the menu"
echo ""

# Optionally open the app right away
read -r -p "Open OpenRightClick now? [y/N] " REPLY
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    open "$INSTALL_DIR/$APP_NAME"
fi
