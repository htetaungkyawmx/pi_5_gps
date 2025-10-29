import 'package:flutter/material.dart';
import 'package:pi5_gps_tracker/screen/fake_screen.dart';
import 'package:pi5_gps_tracker/state/tracker_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GpsApp());
}

class GpsApp extends StatelessWidget {
  const GpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackerProvider('ws://192.168.0.206:8765'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pi 5 GPS Tracker',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
        ),
        home: const HackingScreen(),
      ),
    );
  }
}
