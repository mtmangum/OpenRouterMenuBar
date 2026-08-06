#!/bin/bash
set -euo pipefail

APP_NAME="OpenRouterMenuBar"
APP_BUNDLE="${APP_NAME}.app"
INSTALL_PATH="/Applications/${APP_BUNDLE}"

echo "Building..."
./build_app.sh

echo "Stopping running instance..."
osascript -e 'quit app "OpenRouterMenuBar"' 2>/dev/null || true
sleep 1

echo "Installing to /Applications..."
rm -rf "$INSTALL_PATH"
cp -R "$APP_BUNDLE" "$INSTALL_PATH"

echo "Signing..."
codesign --force --deep --sign - "$INSTALL_PATH"

echo "Launching..."
open "$INSTALL_PATH"

echo "Done."
