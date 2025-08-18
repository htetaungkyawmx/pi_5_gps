// lib/screen/map_screen.dart
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

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(16.8409, 96.1735);
  double _currentZoom = 14.0;

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
              maxZoom: 18,
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
              if (current != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: current,
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/icon.png'),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(left: 12, right: 12, bottom: 12, child: _HudPanel()),
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'follow',
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  onPressed: tracker.toggleFollow,
                  child: Icon(tracker.follow ? Icons.gps_fixed : Icons.gps_not_fixed),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: 'clear',
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  onPressed: tracker.clearTrail,
                  child: const Icon(Icons.clear_all),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final lat = tracker.current?.latitude;
    final lon = tracker.current?.longitude;

    String fmt(double? v, {int dp = 5}) => v == null ? "--" : v.toStringAsFixed(dp);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.9)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13),
        child: Row(
          children: [
            const Icon(Icons.terminal, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  Text("LAT:${fmt(lat)}"),
                  Text("LON:${fmt(lon)}"),
                  Text("SPD:${tracker.speed != null ? tracker.speed!.toStringAsFixed(1) + ' km/h' : '--'}"),
                  Text("HDG:${tracker.heading?.toStringAsFixed(0) ?? '--'}°"),
                  Text("TS:${tracker.lastTs?.toUtc().toIso8601String() ?? '--'}"),
                  Text(
                    "ACCESS GRANTED",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.greenAccent.withOpacity(0.9), blurRadius: 14)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}