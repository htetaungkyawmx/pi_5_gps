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

  late AnimationController _radarController;
  late Animation<double> _radarAnimation;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  void _performScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning area...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final currentPosition = tracker.current;

    // Auto follow if enabled
    if (currentPosition != null && tracker.follow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentPosition, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 15.0,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pi5_gps_tracker',
              ),

              // Trail polyline
              if (tracker.trail.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: tracker.trail,
                      strokeWidth: 4,
                      color: Colors.greenAccent.withOpacity(0.7),
                    ),
                  ],
                ),

              // Radar circle
              if (currentPosition != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: currentPosition,
                      radius: 100 + _radarAnimation.value * 400,
                      color: Colors.greenAccent.withOpacity(0.2 - _radarAnimation.value * 0.2),
                      borderColor: Colors.greenAccent,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),

              // Current position marker
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Control buttons
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                _ControlButton(
                  icon: tracker.follow ? Icons.gps_fixed : Icons.gps_not_fixed,
                  onPressed: tracker.toggleFollow,
                  isActive: tracker.follow,
                ),
                const SizedBox(height: 12),
                _ControlButton(
                  icon: Icons.clear_all,
                  onPressed: tracker.clearTrail,
                ),
                const SizedBox(height: 12),
                _ControlButton(
                  icon: Icons.search,
                  onPressed: _performScan,
                ),
                const SizedBox(height: 12),
                _ControlButton(
                  icon: Icons.layers,
                  onPressed: _toggleOverlay,
                  isActive: _showOverlay,
                ),
              ],
            ),
          ),

          // Status overlay
          if (_showOverlay)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: _StatusOverlay(tracker: tracker),
            ),

          // Bottom HUD
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _HudPanel(tracker: tracker),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      backgroundColor: isActive ? Colors.greenAccent : Colors.grey[800],
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  final TrackerProvider tracker;

  const _StatusOverlay({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'STATUS: ${tracker.current != null ? 'TRACKING' : 'SEARCHING'}',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'GPS: ${tracker.current != null ? 'LOCKED' : 'NO SIGNAL'}',
            style: TextStyle(
              color: tracker.current != null ? Colors.greenAccent : Colors.redAccent,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}

class _HudPanel extends StatelessWidget {
  final TrackerProvider tracker;

  const _HudPanel({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POSITION DATA',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'LAT: ${tracker.current?.latitude.toStringAsFixed(6) ?? '--'}',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                ),
              ),
              Expanded(
                child: Text(
                  'LON: ${tracker.current?.longitude.toStringAsFixed(6) ?? '--'}',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'SPD: ${tracker.speed?.toStringAsFixed(1) ?? '--'} km/h',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                ),
              ),
              Expanded(
                child: Text(
                  'HDG: ${tracker.heading?.toStringAsFixed(0) ?? '--'}°',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
