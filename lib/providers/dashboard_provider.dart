import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/data/repositories/dashboard_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  // Dashboard data
  DashboardData? _dashboardData;
  GetDashboardModel? _dashboardModel;

  // Dashboard History data
  GetDashboardHistoryModel? _dashboardHistoryModel;

  int _selectedStatusIndex = -1;
  int _touchedIndex = -1;

  bool _isLoading = false;
  String? _error;

  // Getters
  DashboardData? get dashboardData => _dashboardData;
  GetDashboardModel? get dashboardModel => _dashboardModel;
  GetDashboardHistoryModel? get dashboardHistoryModel => _dashboardHistoryModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedStatusIndex => _selectedStatusIndex;
  int get touchedIndex => _touchedIndex;

  final token = MySharedPreferences.getString(authTokenKey);

  DashboardProvider()
  {
    fetchData();
  }

  void setSelectedStatusIndex(int index)
  {
    _selectedStatusIndex = index;
    notifyListeners();
  }

  void clearSelection()
  {
    _selectedStatusIndex = -1;
    notifyListeners();
  }

  void setTouchedIndex(int index)
  {
    _touchedIndex = index;
    notifyListeners();
  }

  // Fetch Dashboard main data
  Future<void> getDashboardProvider()
  async {
    if (_dashboardModel == null) {
      _isLoading = true;
      notifyListeners();
    }
    _error = null;
    try {
      final response = await _repository.getDashboardData(token: token);
      if (response != null) {
        AppSnackBar.success(message: "Data fetched successfully");
        _dashboardModel = response;
      } else {
        _error = "Failed to fetch dashboard data.";
      }
    } catch (e) {
      _error = e.toString();
      AppSnackBar.error(message: e.toString());
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Fetch Dashboard history data
  Future<void> getDashboardHistoryProvider()
  async {
    if (_dashboardHistoryModel != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getDashboardHistoryData(token: token);
      if (response != null) {
        _dashboardHistoryModel = response;
        AppSnackBar.success(message: "History fetched successfully");
      } else {
        _error = "Failed to fetch dashboard history.";
      }
    } catch (e) {
      _error = e.toString();
      AppSnackBar.error(message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Dashboard dummy data
  Future<void> fetchData()
  async {
    try {
      _dashboardData = await _repository.fetchDashboardData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Get greeting based on time
  String getTimePeriod()
  {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 17) return "Good Afternoon";
    if (hour >= 17 && hour < 20) return "Good Evening";
    return "Night";
  }
}
