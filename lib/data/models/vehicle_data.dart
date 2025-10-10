import 'package:flutter/material.dart';

class VehicleData {
  final List<StatusData> statuses;
  final List<Vehicle> vehicles;

  VehicleData({
    required this.statuses,
    required this.vehicles,
  });
}

class StatusData {
  final String title;
  final int count;
  final Color color;

  StatusData({
    required this.title,
    required this.count,
    required this.color,
  });
}

class Vehicle {
  final String title;
  final String speed;
  final String update;
  final String address;
  final String image;
  final String status;

  Vehicle({
    required this.title,
    required this.speed,
    required this.update,
    required this.address,
    required this.image,
    required this.status,
  });
}