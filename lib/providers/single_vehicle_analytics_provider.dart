import 'package:flutter/material.dart';

class SingleVehicleAnalyticsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _vehicleData;
  int _currentTabIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get vehicleData => _vehicleData;
  int get currentTabIndex => _currentTabIndex;

  SingleVehicleAnalyticsProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _vehicleData = {
        'plateNumber': 'AAT-289',
        'driverName': 'Alex Bahadur Nepali',
      };
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}