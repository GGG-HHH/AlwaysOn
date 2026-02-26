#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="AlwaysOn"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
INSTALL_DIR="/Applications"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run ./build.sh first."
    exit 1
fi

echo "Installing $APP_NAME to $INSTALL_DIR..."

# Kill running instance if any
pkill -x "$APP_NAME" 2>/dev/null || true
sleep 1

# Copy to /Applications
rm -rf "$INSTALL_DIR/$APP_NAME.app"
cp -R "$APP_BUNDLE" "$INSTALL_DIR/"

echo "Installed to $INSTALL_DIR/$APP_NAME.app"
echo ""
echo "Launch with:"
echo "  open /Applications/$APP_NAME.app"
