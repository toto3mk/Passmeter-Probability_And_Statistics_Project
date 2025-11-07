#!/bin/bash

set -e

echo "Building Password Analyzer AppImage (JIT Mode)..."

# Clean up
rm -rf PasswordAnalyzer.AppDir Password_Strength_Analyzer-x86_64.AppImage

# Build in debug mode (JIT) instead of release (AOT)
echo "Step 1: Building Flutter application in debug mode..."
flutter build linux --debug

# Create AppDir structure
echo "Step 2: Creating AppDir structure..."
mkdir -p PasswordAnalyzer.AppDir/usr/bin
mkdir -p PasswordAnalyzer.AppDir/usr/lib
mkdir -p PasswordAnalyzer.AppDir/usr/share/icons/hicolor/256x256/apps
mkdir -p PasswordAnalyzer.AppDir/usr/share/applications

# Copy ALL files from debug build - FIXED PATH
echo "Step 3: Copying application files..."
cp -r build/linux/x64/debug/bundle/* PasswordAnalyzer.AppDir/

# Move the binary to the correct location and make executable
echo "Step 4: Setting up binary..."
if [ -f "PasswordAnalyzer.AppDir/passmeter" ]; then
    mv PasswordAnalyzer.AppDir/passmeter PasswordAnalyzer.AppDir/usr/bin/
    chmod +x PasswordAnalyzer.AppDir/usr/bin/passmeter
else
    echo "❌ Error: passmeter binary not found!"
    echo "Contents of debug bundle:"
    ls -la build/linux/x64/debug/bundle/
    exit 1
fi

# Move libraries if they exist
if [ -d "PasswordAnalyzer.AppDir/lib" ]; then
    mv PasswordAnalyzer.AppDir/lib/* PasswordAnalyzer.AppDir/usr/lib/ 2>/dev/null || true
    rmdir PasswordAnalyzer.AppDir/lib 2>/dev/null || true
fi

# Move data if it exists
if [ -d "PasswordAnalyzer.AppDir/data" ]; then
    mv PasswordAnalyzer.AppDir/data PasswordAnalyzer.AppDir/usr/share/ 2>/dev/null || true
fi

# Create AppRun for JIT mode
echo "Step 5: Creating AppRun..."
cat > PasswordAnalyzer.AppDir/AppRun << 'EOF'
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

# Set environment variables
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share:${XDG_DATA_DIRS}"

# Run in JIT mode
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
else
    echo "Creating placeholder icon..."
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > PasswordAnalyzer.AppDir/passmeter.png
fi
cp PasswordAnalyzer.AppDir/passmeter.png PasswordAnalyzer.AppDir/usr/share/icons/hicolor/256x256/apps/

# Build AppImage
echo "Step 8: Building AppImage..."
./appimagetool-x86_64.AppImage PasswordAnalyzer.AppDir

echo "✅ AppImage built successfully!"
find . -maxdepth 1 -name "*.AppImage" -type f -exec ls -la {} \;
