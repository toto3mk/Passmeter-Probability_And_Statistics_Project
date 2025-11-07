import 'dart:math';

class KeyAnalyzer {
  static const String _symbolSet = r"""!@#$%^&*()-_+=[]{}|;:,.<>?~/\\\"'`""";

  static const Map<String, String> _judgmentColors = {
    "UNBREAKABLE": "0xFF4CAF50", // Green
    "EXTREMELY STRONG": "0xFF8BC34A", // Light Green
    "VERY STRONG": "0xFFFFC107", // Amber
    "MODERATE": "0xFFFF9800", // Orange
    "WEAK": "0xFFF44336", // Red
    "VOID": "0xFF757575", // Grey
  };

  /// Calculates the entropy, crack time, and strength rating of a key.
  /// Returns a Map<String, dynamic> containing all analyzed metrics.
  static Map<String, dynamic> analyzeKeyStrength(String password) {
    int length = password.length;
    int charsetSize = 0;

    if (length == 0) {
      return _getVoidResult();
    }

    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));

    bool hasSymbol = password.contains(
      RegExp(r'[' + RegExp.escape(_symbolSet) + r']'),
    );

    // Determine the Character Set Size (C)
    if (hasUpper) charsetSize += 26;
    if (hasLower) charsetSize += 26;
    if (hasDigit) charsetSize += 10;
    if (hasSymbol) charsetSize += _symbolSet.length;

    if (charsetSize == 0) {
      return _getVoidResult();
    }

    // 1. Entropy Calculation: H = L * log2(C)
    double entropyBits = length * (log(charsetSize) / log(2));

    // 2. Time to Crack
    double guessesPerSecond = pow(10, 12).toDouble();
    double totalPossibilities = pow(charsetSize, length).toDouble();
    double secondsToCrack = totalPossibilities / guessesPerSecond;
    double yearsToCrack = secondsToCrack / (60 * 60 * 24 * 365.25);

    // 3. Strength Rating Logic
    String rating;
    if (entropyBits >= 128) {
      rating = "UNBREAKABLE";
    } else if (entropyBits >= 96) {
      rating = "EXTREMELY STRONG";
    } else if (entropyBits >= 80) {
      rating = "VERY STRONG";
    } else if (entropyBits >= 64) {
      rating = "MODERATE";
    } else {
      rating = "WEAK";
    }
    
    String sciNotation = yearsToCrack.toStringAsExponential(2);

    return {
      "length": length,
      "charset_size": charsetSize,
      "entropy_bits": double.parse(entropyBits.toStringAsFixed(2)),
      "years_to_crack_gpu_estimate": sciNotation,
      "rating": rating,
      "color_hex": _judgmentColors[rating],
    };
  }

  static Map<String, dynamic> _getVoidResult() {
    return {
      "length": 0,
      "charset_size": 0,
      "entropy_bits": 0.0,
      "rating": "VOID",
      "years_to_crack_gpu_estimate": "0.00e+00",
      "color_hex": _judgmentColors["VOID"],
    };
  }
}