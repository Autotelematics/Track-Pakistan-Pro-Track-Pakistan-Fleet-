// lib/data/models/vehicle_data.dart
import 'dart:ui';

class StatusData {
  final String title;
  final int count;
  final Color color;
  StatusData({required this.title, required this.count, required this.color});
}

class Vehicle {
  final String title, speed, update, address, image, status;
  Vehicle({required this.title, required this.speed, required this.update,
    required this.address, required this.image, required this.status});
}