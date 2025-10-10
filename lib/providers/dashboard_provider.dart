import 'package:flutter/material.dart';
import '../../data/models/dashboard_data.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();
  DashboardData? _dashboardData;
  String? _error;
  bool _isLoading = false;
  int _touchedIndex = -1;

  DashboardData? get dashboardData => _dashboardData;
  String? get error => _error;
  bool get isLoading => _isLoading;
  int get touchedIndex => _touchedIndex;

  DashboardProvider() {
    fetchData(); // Initialize data fetching on creation
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners(); // Notify UI to show loading state

    try {
      _dashboardData = await _repository.fetchDashboardData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to update with data or error
    }
  }

  void setTouchedIndex(int index) {
    _touchedIndex = index;
    notifyListeners(); // Notify UI to update pie chart
  }
}