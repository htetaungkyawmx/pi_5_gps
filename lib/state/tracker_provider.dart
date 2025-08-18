// lib/state/tracker_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrackerProvider extends ChangeNotifier {
  LatLng? current;
  List<LatLng> trail = [];
  bool follow = true;
  double? speed;
  double? heading;
  DateTime? lastTs;

  late final WebSocketChannel _channel;

  TrackerProvider(String wsUrl) {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel.stream.listen((event) {
      try {
        final data = json.decode(event);
        final lat = data['lat'];
        final lon = data['lon'];
        if (lat != null && lon != null) {
          current = LatLng(lat, lon);
          trail.add(current!);
          speed = data['speed'] != null ? (data['speed'] * 3.6) : null; // m/s -> km/h
          heading = data['heading']?.toDouble();
          lastTs = DateTime.tryParse(data['ts'] ?? '');
          notifyListeners();
        }
      } catch (e) {
        debugPrint('WebSocket parse error: $e');
      }
    }, onDone: () {
      debugPrint('WebSocket closed');
    }, onError: (err) {
      debugPrint('WebSocket error: $err');
    });
  }

  void toggleFollow() {
    follow = !follow;
    notifyListeners();
  }

  void clearTrail() {
    trail.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}