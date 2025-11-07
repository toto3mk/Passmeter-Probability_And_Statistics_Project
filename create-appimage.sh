#!/bin/bash

set -e

echo "Building Password Analyzer AppImage (Fixed Version)..."

# Clean up
rm -rf PasswordAnalyzer.AppDir Password_Strength_Analyzer-x86_64.AppImage

# Build Flutter app
echo "Step 1: Building Flutter application..."
flutter build linux --release

# Check if AOT files exist
echo "Step 2: Checking for AOT data files..."
if [ -f "build/linux/x64/release/bundle/lib/libapp.so" ]; then
    echo "✅ Found libapp.so"
else
    echo "❌ Missing libapp.so - this might cause issues"
fi

# Create AppDir structure
echo "Step 3: Creating AppDir structure..."
mkdir -p PasswordAnalyzer.AppDir/usr/bin
mkdir -p PasswordAnalyzer.AppDir/usr/lib
mkdir -p PasswordAnalyzer.AppDir/usr/share/icons/hicolor/256x256/apps
mkdir -p PasswordAnalyzer.AppDir/usr/share/applications

# Copy ALL application files
echo "Step 4: Copying application files..."
cp build/linux/x64/release/bundle/passmeter PasswordAnalyzer.AppDir/usr/bin/
cp -r build/linux/x64/release/bundle/lib/* PasswordAnalyzer.AppDir/usr/lib/ 2>/dev/null || true
cp -r build/linux/x64/release/bundle/data/* PasswordAnalyzer.AppDir/usr/share/ 2>/dev/null || true

# Copy AOT data files specifically
if [ -f "build/linux/x64/release/bundle/lib/libapp.so" ]; then
    cp build/linux/x64/release/bundle/lib/libapp.so PasswordAnalyzer.AppDir/usr/lib/
fi

# Make executable
chmod +x PasswordAnalyzer.AppDir/usr/bin/passmeter

# Create AppRun with proper AOT data path
echo "Step 5: Creating AppRun..."
cat > PasswordAnalyzer.AppDir/AppRun << 'EOF'
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

# Set environment variables
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share:${XDG_DATA_DIRS}"
export FLUTTER_ASSETS="${HERE}/usr/share/flutter_assets"

# Set AOT library path if it exists
if [ -f "${HERE}/usr/lib/libapp.so" ]; then
    export FLUTTER_AOT_LIBRARY_PATH="${HERE}/usr/lib/libapp.so"
fi

# Execute the application
cd "${HERE}"
exec "./usr/bin/passmeter" "$@"
EOF
chmod +x PasswordAnalyzer.AppDir/AppRun

# Create desktop file
echo "Step 6: Creating desktop file..."
cat > PasswordAnalyzer.AppDir/passmeter.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Password Strength Analyzer
GenericName=Password Security Tool
Comment=Analyze and evaluate password strength using entropy calculation
Exec=passmeter
Icon=passmeter
Terminal=false
Categories=Utility;Security;
Keywords=password;security;analyzer;entropy;
StartupNotify=true
X-AppImage-Version=1.0.0
EOF

# Create icon
echo "Step 7: Creating icon..."
if command -v convert &> /dev/null; then
    convert -size 256x256 xc:#2196F3 -fill white -pointsize 80 -gravity center -annotate +0+0 "🔐" PasswordAnalyzer.AppDir/passmeter.png
    cp PasswordAnalyzer.AppDir/passmeter.png PasswordAnalyzer.AppDir/usr/share/icons/hicolor/256x256/apps/
else
    echo "Creating placeholder icon..."
    # Create a simple blue square as fallback
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > PasswordAnalyzer.AppDir/passmeter.png
    cp PasswordAnalyzer.AppDir/passmeter.png PasswordAnalyzer.AppDir/usr/share/icons/hicolor/256x256/apps/
fi

# Build AppImage
echo "Step 8: Building AppImage..."
./appimagetool-x86_64.AppImage PasswordAnalyzer.AppDir

echo "✅ AppImage built successfully!"

# Show the created file
find . -maxdepth 1 -name "*.AppImage" -type f -exec ls -la {} \;
