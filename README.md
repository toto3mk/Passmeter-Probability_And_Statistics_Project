# Password Strength Analyzer

A Dart library for analyzing password strength using entropy calculation and modern cryptographic principles. This tool provides detailed metrics to help users create secure passwords.

## Features

- **Entropy Calculation**: Measures password complexity in bits
- **Crack Time Estimation**: Estimates time required to brute-force the password
- **Strength Rating**: Categorizes passwords from "WEAK" to "UNBREAKABLE"
- **Character Set Analysis**: Detects usage of uppercase, lowercase, digits, and symbols
- **Visual Feedback**: Color-coded ratings for easy interpretation

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

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  password_strength_analyzer: ^1.0.0
```

## Usage

```dart
import 'package:password_strength_analyzer/key_analyzer.dart';

void main() {
  // Analyze password strength
  var result = KeyAnalyzer.analyzeKeyStrength("MySecurePass123!");
  
  print("Password: ${"MySecurePass123!"}");
  print("Length: ${result['length']}");
  print("Character Set Size: ${result['charset_size']}");
  print("Entropy: ${result['entropy_bits']} bits");
  print("Time to Crack: ${result['years_to_crack_gpu_estimate']} years");
  print("Strength Rating: ${result['rating']}");
  print("Color: ${result['color_hex']}");
}
```

### Sample Output
```json
{
  "length": 15,
  "charset_size": 94,
  "entropy_bits": 98.28,
  "years_to_crack_gpu_estimate": "1.45e+15",
  "rating": "EXTREMELY STRONG",
  "color_hex": "0xFF8BC34A"
}
```

## Examples

| Password | Length | Charset | Entropy | Rating |
|----------|--------|---------|---------|---------|
| `password` | 8 | 26 | 37.60 bits | 🔴 WEAK |
| `Password123` | 11 | 62 | 65.50 bits | 🟠 MODERATE |
| `P@ssw0rd!2024` | 13 | 94 | 85.21 bits | 🟡 VERY STRONG |
| `CorrectHorseBatteryStaple` | 25 | 26 | 117.70 bits | 🟡 EXTREMELY STRONG |
| `V3ry$3cur3&P@ssw0rd!L0ng#` | 24 | 94 | 157.34 bits | 🟢 UNBREAKABLE |

## Technical Details

### Crack Time Calculation
- **Assumption**: 1 trillion guesses per second (modern GPU clusters)
- **Formula**: `(C^L) / guesses_per_second`
- **Conversion**: Seconds to years considering leap years

### Supported Symbols
```
!@#$%^&*()-_+=[]{}|;:,.<>?~/\\\"'`
```

## Security Notes

- 🔒 **No data leaves your device** - all analysis happens locally
- ⚡ **Real-time analysis** - instant feedback as users type
- 📱 **Framework agnostic** - works with Flutter, Dart web, and server-side

## Best Practices

1. **Length Matters**: Aim for at least 12-16 characters
2. **Character Variety**: Mix uppercase, lowercase, numbers, and symbols
3. **Avoid Patterns**: Don't use dictionary words or common sequences
4. **Unique Passwords**: Use different passwords for different services
5. **Consider Passphrases**: Long, memorable phrases can be very secure

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



**⭐ Star this repo if you found it helpful!**
