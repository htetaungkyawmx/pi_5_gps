import 'dart:async';
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
  DateTime? lastUpdate;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isDisposed = false;

  TrackerProvider(String wsUrl) {
    _connect(wsUrl);
  }

  void _connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) => _handleError(error),
        onDone: () => _reconnect(url),
      );
    } catch (e) {
      _reconnect(url);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final lat = data['lat'] as double?;
      final lon = data['lon'] as double?;

      if (lat != null && lon != null) {
        current = LatLng(lat, lon);
        trail.add(current!);

        // Keep trail manageable
        if (trail.length > 1000) {
          trail = trail.sublist(trail.length - 500);
        }

        speed = data['speed'] != null ? (data['speed'] * 3.6) : null;
        heading = data['heading']?.toDouble();
        lastUpdate = DateTime.now();

        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      debugPrint('Parse error: $e');
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
  }

  void _reconnect(String url) {
    if (_isDisposed) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (!_isDisposed) _connect(url);
    });
  }

  void toggleFollow() {
    follow = !follow;
    if (!_isDisposed) notifyListeners();
  }

  void clearTrail() {
    trail.clear();
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
