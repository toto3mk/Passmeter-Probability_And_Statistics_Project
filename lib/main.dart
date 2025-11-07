import 'package:flutter/material.dart';
import 'utils/key_analyzer.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: PasswordAnalyzerScreen(),
    );
  }
}

class PasswordAnalyzerScreen extends StatefulWidget {
  @override
  _PasswordAnalyzerScreenState createState() => _PasswordAnalyzerScreenState();
}

class _PasswordAnalyzerScreenState extends State<PasswordAnalyzerScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic> _result = KeyAnalyzer.analyzeKeyStrength("");

  // NEW: whether the password is obscured (hidden)
  bool _obscure = true;

  void _onChanged(String value) {
    setState(() {
      _result = KeyAnalyzer.analyzeKeyStrength(value);
    });
  }

  Color _colorFromHex(String hex) {
    // hex like "0xFF00C853"
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
            // Strength bar + label
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
            // Tiles
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
