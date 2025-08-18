// lib/services/websocket_data_source.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/position_update.dart';
import 'gps_data_source.dart';

class WebSocketGpsDataSource implements GpsDataSource {
  final Uri uri;
  final Duration reconnectDelay;
  WebSocketChannel? _channel;
  final _controller = StreamController<PositionUpdate>.broadcast();
  StreamSubscription? _sub;
  bool _closed = false;

  WebSocketGpsDataSource(
      this.uri, {
        this.reconnectDelay = const Duration(seconds: 3),
      }) {
    _connect();
  }

  void _connect() {
    if (_closed) return;
    try {
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen((event) {
        try {
          final raw = event;
          final data = jsonDecode(raw);
          if (data is Map<String, dynamic>) {
            final pu = PositionUpdate.fromJson(Map<String, dynamic>.from(data));
            _controller.add(pu);
          }
        } catch (e) {
          // ignore malformed payloads
        }
      }, onDone: _scheduleReconnect, onError: (_, __) => _scheduleReconnect());
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_closed) return;
    Future.delayed(reconnectDelay, () {
      if (!_closed) _connect();
    });
  }

  @override
  Stream<PositionUpdate> get stream => _controller.stream;

  @override
  Future<void> dispose() async {
    _closed = true;
    await _sub?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    await _controller.close();
  }
}
