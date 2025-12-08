import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // REQUIRED PACKAGE
import 'utils/key_analyzer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

void main() {
  runApp(PasswordAnalyzerApp());
}

class PasswordAnalyzerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        primaryColor: Color(0xFFE64A19),
        textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
      ),
      home: BiometricLockScreen(), // CORRECTED: Starts with the lock screen
    );
  }
}

// =======================================================
// BIOMETRIC LOCK SCREEN IMPLEMENTATION
// =======================================================

class BiometricLockScreen extends StatefulWidget {
  @override
  _BiometricLockScreenState createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Start authentication immediately when the screen loads
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your finger or face to access the password analyzer.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Uses any strong biometric (Fingerprint, Face, etc.)
        ),
      );
    } catch (e) {
      print("Authentication error: $e");
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticated = authenticated;
    });

    if (!_isAuthenticated) {
      // Show failure message if authentication is required but failed
      Future.delayed(Duration(milliseconds: 500), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Platform.isAndroid || Platform.isIOS 
                ? "Authentication failed or biometrics not available."
                : "Biometrics not supported on this platform.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      // If authenticated, show the main app screen
      return PasswordAnalyzerScreen();
    } else {
      // If not authenticated, show a locked splash screen
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 80, color: Colors.white70),
              SizedBox(height: 20),
              Text(
                'Access Locked',
                style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: Icon(Icons.fingerprint),
                label: Text('RETRY AUTHENTICATION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE64A19),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// =======================================================
// PASSWORD ANALYZER SCREEN (Uses original logic)
// =======================================================

class PasswordAnalyzerScreen extends StatefulWidget {
  @override
  _PasswordAnalyzerScreenState createState() => _PasswordAnalyzerScreenState();
}

class _PasswordAnalyzerScreenState extends State<PasswordAnalyzerScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic> _result = KeyAnalyzer.analyzeKeyStrength("");

  bool _obscure = true;

  void _onChanged(String value) {
    setState(() {
      _result = KeyAnalyzer.analyzeKeyStrength(value);
    });
  }

  Color _colorFromHex(String hex) {
    return Color(int.parse(hex));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _infoTile(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.white70))),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = _result['rating'] as String;
    final color = _colorFromHex(_result['color_hex'] as String);

    final entropy = double.tryParse(_result['entropy_bits']?.toString() ?? "0") ?? 0.0;
    final progress = (entropy / 128.0).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Password Analyzer', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              obscureText: _obscure, 
              decoration: InputDecoration(
                hintText: 'Type a password to analyze',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                ),
              ),
              style: TextStyle(fontSize: 16, letterSpacing: 1.0),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 16,
                      value: progress,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rating,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            SizedBox(height: 18),
            _infoTile('Length', (_result['length'] ?? 0).toString()),
            _infoTile('Entropy (bits)', _result['entropy_bits']?.toString() ?? '0.00'),
            _infoTile('Crack time (GPU)', _result['crack_time_gpu_formatted'] ?? 'N/A'),
            _infoTile('Crack time (CPU)', _result['crack_time_cpu_formatted'] ?? 'N/A'),
            SizedBox(height: 12),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Tip: increase length and add mixed character classes (upper, lower, digits, symbols). Avoid repeated or sequential characters',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}