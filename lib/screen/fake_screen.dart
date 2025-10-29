import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'map_screen.dart';

class HackingScreen extends StatefulWidget {
  const HackingScreen({super.key});

  @override
  State<HackingScreen> createState() => _HackingScreenState();
}

class _HackingScreenState extends State<HackingScreen> {
  final List<String> _fakeCmds = const [
    "BOOT >> Initializing secure channel...",
    "KERNEL >> Loading exploit modules...",
    "NET >> Establishing uplink via sat-com relay...",
    "SATCOM >> Scanning orbital bands [#####] 100%",
    "AUTH >> Spoofing device identifiers...",
    "CRYPTO >> Brute forcing session keys...",
    "FIREWALL >> Injecting shellcode...",
    "LOADING MODULES [██████████] 100%...",
    "GPS DRIVER LOADED SUCCESSFULLY...",
    "SIGINT >> Capturing GPS packets...",
    "PARSER >> Decoding NMEA frames...",
    "AI-CORE >> Running Kalman filter...",
    "RESULT >> Coordinates locked",
    "TRACE >> Live tracking enabled...",
  ];

  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    for (int i = 0; i < _fakeCmds.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      setState(() => _currentIndex = i);

      // Auto scroll
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() => _isCompleted = true);

    // Navigate to map screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedLines = _fakeCmds.sublist(0, _currentIndex + 1);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SECURE NAVIGATION SYSTEM',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: displayedLines.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AnimatedTextKit(
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            displayedLines[index],
                            textStyle: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 14,
                              color: Colors.greenAccent,
                            ),
                            speed: const Duration(milliseconds: 30),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _currentIndex / _fakeCmds.length,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
              if (_isCompleted) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Redirecting to Map...',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
