import 'package:flutter/material.dart';

class VehicleTrackingProvider extends ChangeNotifier {
  bool engineOn = false;
  double distance = 10.8;
  double speed = 100;
  double temperature = 20;

  void toggleEngine() {
    engineOn = !engineOn;
    notifyListeners();
  }

  void updateDistance(double newDistance) {
    distance = newDistance;
    notifyListeners();
  }

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
    notifyListeners();
  }

  void updateTemperature(double newTemp) {
    temperature = newTemp;
    notifyListeners();
  }
}
