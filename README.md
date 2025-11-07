




#  Password Strength Analyzer (Passmeter)

A cross-platform **Flutter desktop app** that analyzes password strength using entropy-based metrics.  
It provides a clean UI, evaluates password complexity in real time, and helps users understand password security.

---

##  Features

-  Real-time password strength analysis**
-  Calculates **entropy** and **complexity scores**
-  Toggle **show/hide password** visibility
-  Modern Flutter UI (GTK-based on Linux)
-  Distributable as **AppImage** for easy installation on any Linux distro

---
## How It Works

The analyzer uses information theory to calculate password strength:

### Entropy Formula
```
H = L × log₂(C)
```
Where:
- **H** = Entropy (bits)
- **L** = Password length
- **C** = Character set size

### Character Sets
- **Lowercase letters**: 26 characters
- **Uppercase letters**: 26 characters  
- **Digits**: 10 characters
- **Symbols**: 32 special characters

### Strength Ratings
| Rating | Entropy Range | Color | Description |
|--------|---------------|-------|-------------|
| 🟢 UNBREAKABLE | 128+ bits | Green | Virtually uncrackable |
| 🟡 EXTREMELY STRONG | 96-127 bits | Light Green | Extremely secure |
| 🟡 VERY STRONG | 80-95 bits | Amber | Very secure |
| 🟠 MODERATE | 64-79 bits | Orange | Reasonably secure |
| 🔴 WEAK | <64 bits | Red | Easily crackable |
| ⚫ VOID | 0 bits | Grey | Empty password |

---
## Examples

| Password | Length | Charset | Entropy | Rating |
|----------|--------|---------|---------|---------|
| `password` | 8 | 26 | 37.60 bits | 🔴 WEAK |
| `Password123` | 11 | 62 | 65.50 bits | 🟠 MODERATE |
| `P@ssw0rd!2024` | 13 | 94 | 85.21 bits | 🟡 VERY STRONG|
| `CorrectHorseBatteryStaple` | 25 | 26 | 117.70 bits | 🟡 EXTREMELY STRONG |
| `V3ry$3cur3&P@ssw0rd!L0ng#` | 24 | 94 | 157.34 bits | 🟢 UNBREAKABLE |

---

## Requirements

Before building or running:

```bash
sudo apt update
sudo apt install flutter clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
````

Ensure Flutter is installed and configured for Linux:

```bash
flutter doctor
flutter config --enable-linux-desktop
```

---

## Run the App (Development)

To run the app in debug mode:

```bash
flutter run -d linux
```

---

## Build Release Version

To build an optimized native binary:

```bash
flutter build linux --release
```

The binary will be located at:

```
build/linux/x64/release/bundle/passmeter
```

---

## Build AppImage

This project includes a ready-to-use **AppImage build script**.

1. Make the script executable:

   ```bash
   chmod +x build_appimage.sh
   ```

2. Run it:

   ```bash
   ./build_appimage.sh
   ```

3. When done, your AppImage will appear as:

   ```
   Password_Strength_Analyzer-x86_64.AppImage
   ```

---

## Running the AppImage

Copy the file to another Linux system and run:

```bash
chmod +x Password_Strength_Analyzer-x86_64.AppImage
./Password_Strength_Analyzer-x86_64.AppImage
```

No installation required!

---

## Troubleshooting

* **`Gtk-WARNING` about theme parsing:**
  Safe to ignore; caused by GTK theme differences.

* **`Failed to create AOT data`:**
  Make sure you’re using `flutter build linux --release`, not `--debug`.

* **No AppImage created:**
  Ensure `appimagetool-x86_64.AppImage` is executable:

  ```bash
  chmod +x appimagetool-x86_64.AppImage
  ```

---

## Project Structure

```
passmeter/
 ├── lib/
 │   ├── main.dart
 │   └── key_analyzer.dart
 ├── assets/
 ├── build_appimage.sh
 ├── pubspec.yaml
 └── README.md
```

---

## Future Plans

* Add password generation options
* Support Windows and macOS builds
* Export reports as text or CSV
* Implement dark/light theme toggle

---

## 🧑‍💻 Author

**Taha Fadhil**
🖥️ Linux Flutter Developer
📫 [https://github.com/toto3mk]

---



