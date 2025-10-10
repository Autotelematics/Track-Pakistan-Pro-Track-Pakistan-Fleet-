import 'package:flutter/material.dart';

// Provider for managing live tracking state
class LiveTrackingProvider with ChangeNotifier {
  double _speed = 65.0; // Mock speed in KM/H
  bool _isLocked = false;
  bool _isStopped = false;
  DateTime _lastUpdated = DateTime.now();

  double get speed => _speed;
  bool get isLocked => _isLocked;
  bool get isStopped => _isStopped;
  DateTime get lastUpdated => _lastUpdated;

  void toggleLock() {
    _isLocked = !_isLocked;
    notifyListeners();
  }

  void toggleStopStart() {
    _isStopped = !_isStopped;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  void updateSpeed(double newSpeed) {
    _speed = newSpeed;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }
}
