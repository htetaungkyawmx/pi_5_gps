// lib/models/position_update.dart
class PositionUpdate {
  final double lat;
  final double lon;
  final double? alt;
  final double? speed; // m/s from GPSD
  final double? heading;
  final DateTime timestamp;

  PositionUpdate({
    required this.lat,
    required this.lon,
    required this.timestamp,
    this.alt,
    this.speed,
    this.heading,
  });

  factory PositionUpdate.fromJson(Map<String, dynamic> j) {
    final tsString = j['ts'] ?? j['timestamp'] ?? '';
    DateTime ts = DateTime.now().toUtc();
    try {
      if (tsString is String && tsString.isNotEmpty) {
        ts = DateTime.parse(tsString).toUtc();
      }
    } catch (_) {
      ts = DateTime.now().toUtc();
    }

    return PositionUpdate(
      lat: (j['lat'] as num).toDouble(),
      lon: (j['lon'] as num).toDouble(),
      alt: j['alt'] == null ? null : (j['alt'] as num).toDouble(),
      speed: j['speed'] == null ? null : (j['speed'] as num).toDouble(),
      heading: j['heading'] == null ? null : (j['heading'] as num).toDouble(),
      timestamp: ts,
    );
  }
}
