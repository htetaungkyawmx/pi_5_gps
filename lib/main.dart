// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pi_5_gps/ui/f&f_screen.dart';
import 'package:provider/provider.dart';
import 'state/tracker_provider.dart';
import 'ui/hacking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace with your Pi hostname or IP
  const wsUrl = 'ws://192.168.0.206:8765';

  runApp(
    ChangeNotifierProvider(
      create: (_) => TrackerProvider(wsUrl),
      child: const GpsApp(),
    ),
  );
}

class GpsApp extends StatelessWidget {
  const GpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pi 5 GPS",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
      ),
      home: const HackingScreen(),
    );
  }
}