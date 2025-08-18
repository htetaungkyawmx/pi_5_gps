import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../state/tracker_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(16.8409, 96.1735);
  double _currentZoom = 14.0;
  double _radarRange = 1000.0;

  late AnimationController _radarController;
  late Animation<double> _radarAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _blinkAnimation;
  late AnimationController _sweepController;
  late Animation<double> _sweepAnimation;
  late AnimationController _jammerController;
  late Animation<double> _jammerProgress;
  late AnimationController _waveformController;
  late Animation<double> _waveformAnimation;

  List<Map<String, dynamic>> _hackedTargets = [];
  List<Map<String, dynamic>> _interceptedSignals = [];
  List<Map<String, dynamic>> _intrudedDevices = [];
  bool _showCyberOverlay = true;
  bool _trafficJammerActive = false;
  bool _signalInterceptorActive = false;
  bool _deviceIntrusionActive = false;
  String _alertMessage = '';

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    _scanAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeInOut),
    );

    _blinkAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeInOut),
    );

    _sweepController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _sweepAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.linear),
    );

    _jammerController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _jammerProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _jammerController, curve: Curves.easeIn),
    );

    _waveformController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _waveformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveformController, curve: Curves.easeInOut),
    );

    Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      setState(() {
        final alerts = [
          'DATA BREACH DETECTED',
          'SIGNAL INTERCEPTED',
          'UNAUTHORIZED ACCESS',
          'NETWORK INTRUSION',
          'ENCRYPTION CRACKED',
        ];
        _alertMessage = alerts[math.Random().nextInt(alerts.length)];
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _alertMessage = '');
      });
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _hackedTargets.isEmpty) return;
      setState(() {
        final random = math.Random();
        _hackedTargets = _hackedTargets.map((target) {
          final offsetLat = (random.nextDouble() - 0.5) * 0.001;
          final offsetLon = (random.nextDouble() - 0.5) * 0.001;
          return {
            ...target,
            'position': LatLng(
              target['position'].latitude + offsetLat,
              target['position'].longitude + offsetLon,
            ),
            'speed': random.nextDouble() * 120,
            'status': ['Active', 'Idle', 'Compromised'][random.nextInt(3)],
          };
        }).toList();
      });
    });

    _radarController.addListener(() => setState(() {}));
    _sweepController.addListener(() => setState(() {}));
    _jammerController.addListener(() => setState(() {}));
    _waveformController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _radarController.dispose();
    _sweepController.dispose();
    _jammerController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _performHackScan() {
    final tracker = context.read<TrackerProvider>();
    final current = tracker.current ?? _defaultCenter;
    _hackedTargets.clear();
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
      final offsetLat = (random.nextDouble() - 0.5) * 0.02;
      final offsetLon = (random.nextDouble() - 0.5) * 0.02;
      _hackedTargets.add({
        'position': LatLng(current.latitude + offsetLat, current.longitude + offsetLon),
        'id': 'VEH${random.nextInt(1000).toString().padLeft(3, '0')}',
        'speed': random.nextDouble() * 120,
        'status': ['Active', 'Idle', 'Compromised'][random.nextInt(3)],
      });
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hack Scan Complete: 6 Targets Acquired', style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleTrafficJammer() {
    setState(() {
      _trafficJammerActive = !_trafficJammerActive;
      if (_trafficJammerActive) {
        _jammerController.forward(from: 0.0);
      } else {
        _jammerController.reset();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _trafficJammerActive ? 'Traffic Grid Hack Activated' : 'Traffic Grid Hack Deactivated',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleSignalInterceptor() {
    setState(() {
      _signalInterceptorActive = !_signalInterceptorActive;
      if (_signalInterceptorActive) {
        final tracker = context.read<TrackerProvider>();
        final current = tracker.current ?? _defaultCenter;
        _interceptedSignals.clear();
        final random = math.Random();
        for (int i = 0; i < 4; i++) {
          final offsetLat = (random.nextDouble() - 0.5) * 0.01;
          final offsetLon = (random.nextDouble() - 0.5) * 0.01;
          _interceptedSignals.add({
            'position': LatLng(current.latitude + offsetLat, current.longitude + offsetLon),
            'id': 'SIG${random.nextInt(1000).toString().padLeft(3, '0')}',
            'type': ['Radio', 'GPS', 'Cellular'][random.nextInt(3)],
          });
        }
      } else {
        _interceptedSignals.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _signalInterceptorActive ? 'Signal Interceptor Activated' : 'Signal Interceptor Deactivated',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleDeviceIntrusion() {
    setState(() {
      _deviceIntrusionActive = !_deviceIntrusionActive;
      if (_deviceIntrusionActive) {
        final tracker = context.read<TrackerProvider>();
        final current = tracker.current ?? _defaultCenter;
        _intrudedDevices.clear();
        final random = math.Random();
        for (int i = 0; i < 3; i++) {
          final offsetLat = (random.nextDouble() - 0.5) * 0.015;
          final offsetLon = (random.nextDouble() - 0.5) * 0.015;
          _intrudedDevices.add({
            'position': LatLng(current.latitude + offsetLat, current.longitude + offsetLon),
            'id': 'DEV${random.nextInt(1000).toString().padLeft(3, '0')}',
            'type': ['Camera', 'Drone', 'Sensor'][random.nextInt(3)],
            'data': 'STREAM_${random.nextInt(10000)}',
          });
        }
      } else {
        _intrudedDevices.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _deviceIntrusionActive ? 'Device Intrusion Activated' : 'Device Intrusion Deactivated',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleCyberOverlay() {
    setState(() => _showCyberOverlay = !_showCyberOverlay);
  }

  void _adjustRadarRange(bool increase) {
    setState(() {
      _radarRange = increase ? _radarRange + 200 : _radarRange - 200;
      _radarRange = _radarRange.clamp(500.0, 2000.0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Radar Range: ${_radarRange.toInt()}m',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showTargetDetails(Map<String, dynamic> target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent.withOpacity(0.9)),
        ),
        content: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INTERCEPTED DATA // VEHICLE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text('ID: ${target['id']}'),
              Text('LAT: ${target['position'].latitude.toStringAsFixed(5)}'),
              Text('LON: ${target['position'].longitude.toStringAsFixed(5)}'),
              Text('SPD: ${target['speed'].toStringAsFixed(1)} km/h'),
              Text('STATUS: ${target['status']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignalDetails(Map<String, dynamic> signal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent.withOpacity(0.9)),
        ),
        content: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INTERCEPTED SIGNAL // DATA',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text('ID: ${signal['id']}'),
              Text('LAT: ${signal['position'].latitude.toStringAsFixed(5)}'),
              Text('LON: ${signal['position'].longitude.toStringAsFixed(5)}'),
              Text('TYPE: ${signal['type']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent.withOpacity(0.9)),
        ),
        content: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INTRUDED DEVICE // DATA',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text('ID: ${device['id']}'),
              Text('LAT: ${device['position'].latitude.toStringAsFixed(5)}'),
              Text('LON: ${device['position'].longitude.toStringAsFixed(5)}'),
              Text('TYPE: ${device['type']}'),
              Text('DATA: ${device['data']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final current = tracker.current;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (current != null && tracker.follow) {
        _mapController.move(current, _currentZoom);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _currentZoom,
              minZoom: 3,
              maxZoom: 20,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pi_5_gps',
              ),
              if (tracker.trail.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: tracker.trail, strokeWidth: 5, color: Colors.greenAccent.withOpacity(0.9)),
                  ],
                ),
              if (_trafficJammerActive && current != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: current,
                      radius: 1500,
                      color: Colors.redAccent.withOpacity(0.2),
                      borderColor: Colors.redAccent.withOpacity(0.5),
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
              if (_signalInterceptorActive && current != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: current,
                      radius: 1000,
                      color: Colors.cyanAccent.withOpacity(0.1),
                      borderColor: Colors.cyanAccent.withOpacity(0.3),
                      borderStrokeWidth: 1,
                      useRadiusInMeter: true,
                      // Note: flutter_map CircleMarker does not have a 'painter' property.
                      // If custom painting is needed, consider using a Marker with CustomPaint instead.
                    ),
                  ],
                ),
              if (current != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: current,
                      radius: 100 + _radarAnimation.value * (_radarRange - 100),
                      color: Colors.greenAccent.withOpacity(0.3 - _radarAnimation.value * 0.3),
                      borderColor: Colors.greenAccent,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                    ),
                    CircleMarker(
                      point: current,
                      radius: 300 + _radarAnimation.value * (_radarRange - 300),
                      color: Colors.transparent,
                      borderColor: Colors.greenAccent.withOpacity(0.5 - _radarAnimation.value * 0.5),
                      borderStrokeWidth: 1,
                      useRadiusInMeter: true,
                    ),
                    CircleMarker(
                      point: current,
                      radius: _radarRange,
                      color: Colors.transparent,
                      borderColor: Colors.greenAccent.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      // Note: flutter_map CircleMarker does not have a 'painter' property.
                      // If custom painting is needed, consider using a Marker with CustomPaint instead.
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (current != null)
                    Marker(
                      point: current,
                      width: 30,
                      height: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/icon.png'),
                          CustomPaint(
                            painter: _CrosshairPainter(),
                            size: const Size(30, 30),
                          ),
                        ],
                      ),
                    ),
                  ..._hackedTargets.map((target) => Marker(
                    point: target['position'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showTargetDetails(target),
                      child: ScaleTransition(
                        scale: _scanAnimation,
                        child: Icon(
                          Icons.local_taxi,
                          color: target['status'] == 'Compromised' ? Colors.redAccent : Colors.yellowAccent,
                          size: 30,
                        ),
                      ),
                    ),
                  )),
                  ..._interceptedSignals.map((signal) => Marker(
                    point: signal['position'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showSignalDetails(signal),
                      child: ScaleTransition(
                        scale: _scanAnimation,
                        child: const Icon(Icons.signal_wifi_4_bar, color: Colors.cyanAccent, size: 25),
                      ),
                    ),
                  )),
                  ..._intrudedDevices.map((device) => Marker(
                    point: device['position'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showDeviceDetails(device),
                      child: ScaleTransition(
                        scale: _scanAnimation,
                        child: Icon(
                          device['type'] == 'Camera'
                              ? Icons.videocam
                              : device['type'] == 'Drone'
                              ? Icons.air
                              : Icons.sensors,
                          color: Colors.purpleAccent,
                          size: 25,
                        ),
                      ),
                    ),
                  )),
                  if (_trafficJammerActive)
                    ...[
                      Marker(
                        point: LatLng(_defaultCenter.latitude + 0.005, _defaultCenter.longitude + 0.005),
                        width: 30,
                        height: 30,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) => Opacity(
                            opacity: _blinkAnimation.value,
                            child: Icon(Icons.traffic, color: Colors.redAccent, size: 25),
                          ),
                        ),
                      ),
                      Marker(
                        point: LatLng(_defaultCenter.latitude - 0.005, _defaultCenter.longitude - 0.005),
                        width: 30,
                        height: 30,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) => Opacity(
                            opacity: _blinkAnimation.value,
                            child: Icon(Icons.traffic, color: Colors.greenAccent, size: 25),
                          ),
                        ),
                      ),
                      Marker(
                        point: LatLng(_defaultCenter.latitude + 0.007, _defaultCenter.longitude - 0.007),
                        width: 30,
                        height: 30,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) => Opacity(
                            opacity: _blinkAnimation.value,
                            child: Icon(Icons.traffic, color: Colors.yellowAccent, size: 25),
                          ),
                        ),
                      ),
                      Marker(
                        point: LatLng(_defaultCenter.latitude - 0.007, _defaultCenter.longitude + 0.007),
                        width: 30,
                        height: 30,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) => Opacity(
                            opacity: _blinkAnimation.value,
                            child: Icon(Icons.traffic, color: Colors.blueAccent, size: 25),
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _GridOverlay(),
              size: MediaQuery.of(context).size,
            ),
          ),
          if (_showCyberOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.15,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 50,
                      itemBuilder: (context, index) {
                        final phrases = [
                          'HACK INITIATED 0x${math.Random().nextInt(65536).toRadixString(16).toUpperCase()}',
                          'TARGET ACQUIRED ID${math.Random().nextInt(1000)}',
                          'ENCRYPTION BYPASSED 101010',
                          'FIREWALL BREACHED 0x${math.Random().nextInt(256).toRadixString(16).toUpperCase()}',
                          'DATA STREAM INTERCEPTED',
                          'NETWORK OVERRIDE 0x${math.Random().nextInt(4096).toRadixString(16).toUpperCase()}',
                          'SYSTEM COMPROMISED 0x${math.Random().nextInt(8192).toRadixString(16).toUpperCase()}',
                        ];
                        return AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) => Opacity(
                            opacity: _blinkAnimation.value,
                            child: Text(
                              phrases[index % phrases.length],
                              style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (_showCyberOverlay)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (context, child) => Opacity(
                  opacity: _blinkAnimation.value * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withOpacity(0.08),
                          Colors.black.withOpacity(0.08),
                          Colors.greenAccent.withOpacity(0.04),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _ScanlinePainter(),
                      size: MediaQuery.of(context).size,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _HudPanel(
              blinkAnimation: _blinkAnimation,
              alertMessage: _alertMessage,
              jammerProgress: _jammerProgress,
              threatLevel: _hackedTargets.length + _interceptedSignals.length + _intrudedDevices.length,
              targetCount: _hackedTargets.length,
              signalCount: _interceptedSignals.length,
              deviceCount: _intrudedDevices.length,
              radarRange: _radarRange,
              trafficJammerActive: _trafficJammerActive,
            ),
          ),
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                _ControlButton(
                  heroTag: 'follow',
                  icon: tracker.follow ? Icons.gps_fixed : Icons.gps_not_fixed,
                  onPressed: tracker.toggleFollow,
                  active: tracker.follow,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'clear',
                  icon: Icons.clear_all,
                  onPressed: tracker.clearTrail,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'scan',
                  icon: Icons.search,
                  onPressed: _performHackScan,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'jammer',
                  icon: Icons.wifi_off,
                  onPressed: _toggleTrafficJammer,
                  active: _trafficJammerActive,
                  activeColor: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'interceptor',
                  icon: Icons.signal_wifi_4_bar,
                  onPressed: _toggleSignalInterceptor,
                  active: _signalInterceptorActive,
                  activeColor: Colors.cyanAccent,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'intrusion',
                  icon: Icons.security,
                  onPressed: _toggleDeviceIntrusion,
                  active: _deviceIntrusionActive,
                  activeColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'overlay',
                  icon: Icons.layers,
                  onPressed: _toggleCyberOverlay,
                  active: _showCyberOverlay,
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'range_up',
                  icon: Icons.add_circle_outline,
                  onPressed: () => _adjustRadarRange(true),
                ),
                const SizedBox(height: 8),
                _ControlButton(
                  heroTag: 'range_down',
                  icon: Icons.remove_circle_outline,
                  onPressed: () => _adjustRadarRange(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    const gridSize = 40.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += gridSize) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const scanlineSpacing = 10.0;
    for (double y = 0; y < size.height; y += scanlineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawCircle(center, 5, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ControlButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;
  final Color activeColor;

  const _ControlButton({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.activeColor = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: active ? activeColor : Colors.grey[800],
      foregroundColor: Colors.white,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _HudPanel extends StatelessWidget {
  final Animation<double> blinkAnimation;
  final String alertMessage;
  final Animation<double> jammerProgress;
  final int threatLevel;
  final int targetCount;
  final int signalCount;
  final int deviceCount;
  final double radarRange;
  final bool trafficJammerActive;

  const _HudPanel({
    required this.blinkAnimation,
    required this.alertMessage,
    required this.jammerProgress,
    required this.threatLevel,
    required this.targetCount,
    required this.signalCount,
    required this.deviceCount,
    required this.radarRange,
    required this.trafficJammerActive,
  });

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final lat = tracker.current?.latitude;
    final lon = tracker.current?.longitude;

    String fmt(double? v, {int dp = 5}) => v == null ? "--" : v.toStringAsFixed(dp);
    String threatStatus = threatLevel > 8 ? 'CRITICAL' : threatLevel > 4 ? 'HIGH' : threatLevel > 0 ? 'MODERATE' : 'LOW';
    Color threatColor = threatLevel > 8
        ? Colors.redAccent
        : threatLevel > 4
        ? Colors.orangeAccent
        : threatLevel > 0
        ? Colors.yellowAccent
        : Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      Text("LAT:${fmt(lat)}"),
                      Text("LON:${fmt(lon)}"),
                      Text("SPD:${tracker.speed != null ? tracker.speed!.toStringAsFixed(1) + ' km/h' : '--'}"),
                      Text("HDG:${tracker.heading?.toStringAsFixed(0) ?? '--'}°"),
                      Text("TS:${tracker.lastTs?.toUtc().toIso8601String() ?? '--'}"),
                      Text("RNG:${radarRange.toInt()}m"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) => Opacity(
                opacity: blinkAnimation.value,
                child: Text(
                  tracker.current != null ? "TARGET LOCKED" : "SCANNING...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.greenAccent.withOpacity(0.9), blurRadius: 10)],
                  ),
                ),
              ),
            ),
            if (alertMessage.isNotEmpty)
              AnimatedBuilder(
                animation: blinkAnimation,
                builder: (context, child) => Opacity(
                  opacity: blinkAnimation.value,
                  child: Text(
                    alertMessage,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.redAccent.withOpacity(0.9), blurRadius: 10)],
                    ),
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) => Opacity(
                opacity: blinkAnimation.value,
                child: Text(
                  'THREAT: $threatStatus',
                  style: TextStyle(
                    color: threatColor,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: threatColor.withOpacity(0.9), blurRadius: 10)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('TGT: $targetCount', style: const TextStyle(color: Colors.yellowAccent)),
                const SizedBox(width: 10),
                Text('SIG: $signalCount', style: const TextStyle(color: Colors.cyanAccent)),
                const SizedBox(width: 10),
                Text('DEV: $deviceCount', style: const TextStyle(color: Colors.purpleAccent)),
              ],
            ),
            if (trafficJammerActive)
              AnimatedBuilder(
                animation: jammerProgress,
                builder: (context, child) => LinearProgressIndicator(
                  value: jammerProgress.value,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}