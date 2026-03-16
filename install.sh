#!/bin/bash
# install.sh -- Build OpenRightClick (Release) and install to /Applications

set -euo pipefail

XCODEBUILD="/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
PROJECT="OpenRightClick.xcodeproj"
SCHEME="OpenRightClick"
CONFIG="Release"
APP_NAME="OpenRightClick.app"
INSTALL_DIR="/Applications"

echo "Building ${SCHEME} (${CONFIG})..."
"$XCODEBUILD" \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath ".build" \
    build 2>&1 | grep -E "(error:|Build succeeded|Build FAILED|Signing Identity)" || true

APP_SRC=".build/Build/Products/${CONFIG}/${APP_NAME}"
if [ ! -d "$APP_SRC" ]; then
    echo "ERROR: Build failed -- ${APP_SRC} not found."
    exit 1
fi

echo "Installing to ${INSTALL_DIR}/${APP_NAME}..."
if [ -d "${INSTALL_DIR}/${APP_NAME}" ]; then
    echo "Removing old version..."
    rm -rf "${INSTALL_DIR}/${APP_NAME}"
fi
cp -R "$APP_SRC" "${INSTALL_DIR}/${APP_NAME}"

echo "Removing quarantine attribute..."
xattr -rd com.apple.quarantine "${INSTALL_DIR}/${APP_NAME}" 2>/dev/null || true

echo ""
echo "Done! Installed to ${INSTALL_DIR}/${APP_NAME}"
echo ""
echo "Next steps:"
echo "  1. Open /Applications/OpenRightClick.app"
echo "  2. Click 'Open System Settings' to enable the Finder extension"
echo "  3. Right-click in Finder to see the menu"
echo ""

read -r -p "Open OpenRightClick now? [y/N] " REPLY
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    open "${INSTALL_DIR}/${APP_NAME}"
fi
