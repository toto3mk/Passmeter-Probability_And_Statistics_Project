#!/bin/bash

set -e

APP_NAME="PasswordAnalyzer"
BINARY_NAME="passmeter"

APP_DIR="${APP_NAME}.AppDir"
APPIMAGE_NAME="${APP_NAME}-x86_64.AppImage"

echo "🔧 Building $APP_NAME AppImage (JIT Mode)..."

# Clean up
rm -rf "$APP_DIR" "$APPIMAGE_NAME"

# Step 1: Build Flutter Linux app (debug JIT mode)
echo "🚧 Step 1: Building Flutter application in debug mode..."
flutter build linux --debug

# Step 2: Create AppDir structure
echo "📁 Step 2: Creating AppDir structure..."
mkdir -p "$APP_DIR/usr/bin"
mkdir -p "$APP_DIR/usr/lib"
mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APP_DIR/usr/share/applications"

# Step 3: Copy Flutter build output
echo "📦 Step 3: Copying build output..."
cp -r build/linux/x64/debug/bundle/* "$APP_DIR/usr/bin/"

# Step 4: Verify binary
if [ ! -f "$APP_DIR/usr/bin/$BINARY_NAME" ]; then
    echo "❌ Error: Binary not found at $APP_DIR/usr/bin/$BINARY_NAME"
    echo "Check your binary name. Listing available files:"
    ls -la "$APP_DIR/usr/bin"
    exit 1
fi
chmod +x "$APP_DIR/usr/bin/$BINARY_NAME"

# Step 5: Create AppRun
echo "⚙️ Step 5: Creating AppRun..."
cat > "$APP_DIR/AppRun" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export PATH="\${HERE}/usr/bin:\${PATH}"
export LD_LIBRARY_PATH="\${HERE}/usr/lib:\${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="\${HERE}/usr/share:\${XDG_DATA_DIRS}"
cd "\${HERE}/usr/bin"
exec "./$BINARY_NAME" "\$@"
EOF
chmod +x "$APP_DIR/AppRun"

# Step 6: Desktop entry
echo "🖥️ Step 6: Creating desktop entry..."
cat > "$APP_DIR/$BINARY_NAME.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Password Strength Analyzer
GenericName=Password Security Tool
Comment=Analyze and evaluate password strength using entropy calculation
Exec=$BINARY_NAME
Icon=$BINARY_NAME
Terminal=false
Categories=Utility;Security;
Keywords=password;security;analyzer;entropy;
StartupNotify=true
X-AppImage-Version=1.0.0
EOF

# Step 7: Icon
echo "🎨 Step 7: Creating icon..."
ICON_PATH="$APP_DIR/usr/share/icons/hicolor/256x256/apps/$BINARY_NAME.png"
if command -v convert &>/dev/null; then
    convert -size 256x256 xc:#2196F3 -fill white -pointsize 80 -gravity center -annotate +0+0 "🔐" "$ICON_PATH"
else
    echo "Using base64 fallback icon..."
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$ICON_PATH"
fi

# Step 8: Build AppImage
echo "📦 Step 8: Building AppImage..."
if [ ! -f "./appimagetool-x86_64.AppImage" ]; then
    echo "❌ appimagetool-x86_64.AppImage not found in current directory!"
    echo "Download it from: https://github.com/AppImage/AppImageKit/releases"
    exit 1
fi

chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage "$APP_DIR" "$APPIMAGE_NAME"

echo "✅ AppImage built successfully: $APPIMAGE_NAME"
ls -lh "$APPIMAGE_NAME"

