// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/key_analyzer.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Analyzer',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFFE64A19),
        scaffoldBackgroundColor: Color(0xFF121212),
        textTheme: GoogleFonts.robotoMonoTextTheme().copyWith(
          bodyMedium: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF5722)),
          ),
          labelStyle: GoogleFonts.robotoMono(color: Colors.white54),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: AnalysisScreen(),
    ),
  );
}

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _analysisResults = {};

  @override
  void initState() {
    super.initState();
    _analysisResults = KeyAnalyzer.analyzeKeyStrength("");
  }

  void _runAnalysis(String password) {
    setState(() {
      _analysisResults = KeyAnalyzer.analyzeKeyStrength(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color ratingColor = Color(
      int.parse(_analysisResults['color_hex'].toString()),
    );
    String ratingText = _analysisResults['rating'].toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Password Analyzer - Taha', style: GoogleFonts.exo2()),
        backgroundColor: Color(0xFF212121),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: _runAnalysis,
              style: GoogleFonts.exo2(fontSize: 18.0),
              decoration: InputDecoration(
                labelText: 'Enter The Password To Analyze',
                labelStyle: GoogleFonts.exo2(color: Colors.white54),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _controller.clear();
                    _runAnalysis("");
                  },
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
              'Analysis Report',
              style: GoogleFonts.exo2(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 34, 255, 0),
              ),
              textAlign: TextAlign.center,
            ),
            Divider(color: Colors.white30, height: 20),

            _buildInfoRow(
              'Key Length',
              '${_analysisResults['length']} characters',
            ),
            _buildInfoRow(
              'Charset Size (C)',
              '${_analysisResults['charset_size']} unique chars',
            ),
            _buildInfoRow(
              'Entropy (H)',
              '${_analysisResults['entropy_bits']} bits',
            ),

            SizedBox(height: 15),

            Text(
              'GPU Crack Estimated:',
              style: GoogleFonts.rajdhani(
                // Clean tech font
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${_analysisResults['years_to_crack_gpu_estimate']} years',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),

            SizedBox(height: 25),

            Text(
              ' Password Strength Rating ',
              textAlign: TextAlign.center,

              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ratingColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ratingColor, width: 2),
              ),
              child: Text(
                ratingText,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ratingColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.robotoMono(fontSize: 16, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
