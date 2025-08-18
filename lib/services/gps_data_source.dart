// lib/services/gps_data_source.dart
import 'dart:async';
import '../models/position_update.dart';

abstract class GpsDataSource {
  Stream<PositionUpdate> get stream;
  Future<void> dispose();
}
