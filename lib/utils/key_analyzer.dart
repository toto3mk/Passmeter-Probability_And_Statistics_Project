// lib/utils/key_analyzer.dart
// Lightweight password analyzer used by the app.
// Estimates entropy, rating and crack times (GPU & CPU).


import 'dart:math';

class KeyAnalyzer {
  // Rating labels and color hex (as Flutter `Color` hex string)
  static const Map<String, String> _judgmentColors = {
    "UNBREAKABLE": "0xFF00C853", // bright green
    "VERY STRONG": "0xFF8BC34A",
    "MODERATE": "0xFFFFC107",
    "WEAK": "0xFFFF9800",
    "VERY WEAK": "0xFFF44336",
    "VOID": "0xFF757575",
  };

  /// Analyze the provided [password].
  ///
  /// Returns a map with:
  /// - length: int
  /// - entropy_bits: String (2 decimal places)
  /// - rating: String
  /// - crack_time_gpu_formatted: String
  /// - crack_time_cpu_formatted: String
  /// - color_hex: String (e.g. "0xFF00C853")
  static Map<String, dynamic> analyzeKeyStrength(String password) {
    if (password.isEmpty) return _getVoidResult();

    final length = password.length;
    final entropy = _estimateEntropyBits(password);
    final rating = _ratingFromEntropy(entropy);
    final guesses = pow(2, entropy);

    // Attacker rates: GPU (high), CPU (lower)
    const gpuGuessesPerSecond = 1e10; // 10 billion guesses/sec (example GPU cluster)
    const cpuGuessesPerSecond = 1e3;   // 1000 guesses/sec (single CPU)

    final secondsGpu = guesses / gpuGuessesPerSecond;
    final secondsCpu = guesses / cpuGuessesPerSecond;

    return {
      'length': length,
      'entropy_bits': entropy.toStringAsFixed(2),
      'rating': rating,
      'crack_time_gpu_formatted': _formatDuration(secondsGpu),
      'crack_time_cpu_formatted': _formatDuration(secondsCpu),
      'color_hex': _judgmentColors[rating] ?? _judgmentColors['VOID']!,
    };
  }

  static Map<String, dynamic> _getVoidResult() {
    return {
      "length": 0,
      "entropy_bits": "0.00",
      "rating": "VOID",
      "crack_time_gpu_formatted": "N/A",
      "crack_time_cpu_formatted": "N/A",
      "color_hex": _judgmentColors["VOID"]!,
    };
  }



  // Estimate entropy bits using character-set heuristic + penalize common patterns
  static double _estimateEntropyBits(String s) {
    if (s.isEmpty) return 0.0;

    // Determine which character classes are used
    final hasLower = RegExp(r'[a-z]').hasMatch(s);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    final hasDigits = RegExp(r'\d').hasMatch(s);
    final hasSymbols = RegExp(r'[^A-Za-z0-9]').hasMatch(s);

    // Rough charset size estimation
    double charset = 0;
    if (hasLower) charset += 26;
    if (hasUpper) charset += 26;
    if (hasDigits) charset += 10;
    if (hasSymbols) {
      // Common printable symbols count (approx)
      charset += 33;
    }

    // Fallback: if none matched (shouldn't happen), treat as ASCII
    if (charset == 0) charset = 94;

    // Basic entropy estimate: bits = length * log2(charset)
    final bits = s.length * (log(charset) / ln2);

    // Penalize repeated characters or common sequences slightly
    final repetitionPenalty = _repetitionPenalty(s);
    final sequencePenalty = _sequencePenalty(s);

    final adjusted = bits - repetitionPenalty - sequencePenalty;
    return max(0.0, adjusted);
  }

  static double _repetitionPenalty(String s) {
    // If many repeated chars, reduce entropy a bit
    final runs = <int>[];
    var last = s[0];
    var runLen = 1;
    for (var i = 1; i < s.length; i++) {
      if (s[i] == last) {
        runLen++;
      } else {
        runs.add(runLen);
        runLen = 1;
        last = s[i];
      }
    }
    runs.add(runLen);

    // If average run length is >1.5, apply small penalty
    final avg = runs.reduce((a, b) => a + b) / runs.length;
    if (avg <= 1.5) return 0.0;
    // penalty grows with average run length
    return (avg - 1.5) * 1.5; // small number of bits
  }

  static double _sequencePenalty(String s) {
    // Detect ascending or descending sequences of length >=3 and penalize
    var penalty = 0.0;
    for (var i = 0; i < s.length - 2; i++) {
      final a = s.codeUnitAt(i);
      final b = s.codeUnitAt(i + 1);
      final c = s.codeUnitAt(i + 2);
      if ((b == a + 1 && c == b + 1) || (b == a - 1 && c == b - 1)) {
        penalty += 1.5; // small penalty per sequence found
      }
    }
    return penalty;
  }

  static String _ratingFromEntropy(double bits) {
    // Heuristics:
    // < 28 bits: VERY WEAK
    // 28-35: WEAK
    // 36-59: MODERATE
    // 60-127: VERY STRONG
    // >=128: UNBREAKABLE
    if (bits < 28) return "VERY WEAK";
    if (bits < 36) return "WEAK";
    if (bits < 60) return "MODERATE";
    if (bits < 128) return "VERY STRONG";
    return "UNBREAKABLE";
  }

  static String _formatDuration(num seconds) {
    if (seconds.isNaN || seconds.isInfinite) return "∞";

    // Very quick checks:
    if (seconds < 1) return "${(seconds * 1000).round()} ms";
    if (seconds < 60) return "${seconds.round()} s";

    final minutes = seconds / 60.0;
    if (minutes < 60) return "${minutes.round()} min";

    final hours = minutes / 60.0;
    if (hours < 24) return "${hours.round()} h";

    final days = hours / 24.0;
    if (days < 365) return "${days.round()} days";

    final years = days / 365.0;
    if (years < 1000) return "${years.round()} years";

    final millennia = years / 1000.0;
    return "${millennia.toStringAsFixed(1)}k years";
  }
}
