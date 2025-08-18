// lib/screen/hacking_screen.dart
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
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
    "AUTH >> Spoofing device IMEI & IMSI identifiers...",
    "CRYPTO >> Brute forcing AES-256 session keys...",
    "CRYPTO >> Key fragment [OK] (2048-bit RSA bypass)",
    "FIREWALL >> Injecting shellcode into secure gateway...",
    "SIGINT >> Capturing GPS L1/L2/L5 packets...",
    "SIGINT >> Reconstructing ephemeris & almanac data...",
    "PARSER >> Decoding NMEA/RMC/GGA frames...",
    "AI-CORE >> Running Kalman filter anomaly correction...",
    "ML >> Predictive model trained (97.2% accuracy)",
    "DB >> Cross-referencing location against transport logs...",
    "OSINT >> Pulling nearby CCTV and traffic cam feeds...",
    "HACK >> GPS signal spoofing countermeasures bypassed",
    "SYS >> Overriding encrypted coordinates buffer...",
    "RESULT >> Coordinates locked → LAT: 16.8713 | LNG: 96.1994",
    "RESULT >> Target rendered on tactical map.",
    "TRACE >> Continuous live tracking enabled...",
  ];

  int _index = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _runScript();
  }

  Future<void> _runScript() async {
    for (int i = 0; i < _fakeCmds.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _index = i);

      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MapScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = _index < 0 ? <String>[] : _fakeCmds.sublist(0, _index + 1);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: "monospace",
              fontSize: 16,
              color: Colors.greenAccent,
              height: 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PI5 GPS TRACE // v1.0",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: lines.length,
                    itemBuilder: (ctx, i) => AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TyperAnimatedText(lines[i],
                            speed: const Duration(milliseconds: 28)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.white12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}