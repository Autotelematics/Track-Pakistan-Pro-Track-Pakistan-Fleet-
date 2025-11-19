import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/data/repositories/dashboard_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
class DashboardProvider with ChangeNotifier {

  final DashboardRepository _repository = DashboardRepository();
  DashboardData? _dashboardData;
  int _selectedStatusIndex = -1;
  int get selectedStatusIndex => _selectedStatusIndex;

  void setSelectedStatusIndex(int index) {
    _selectedStatusIndex = index;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStatusIndex = -1;
    notifyListeners();
  }
  String? _error;
  bool _isLoading = false;
  GetDashboardModel? _dashboardModel;

  int _touchedIndex = -1;
  // Getters
  GetDashboardModel? get dashboardModel => _dashboardModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final token=MySharedPreferences.getString(authTokenKey);

  Future<void> getDashboardProvider() async {
    // Loading sirf tab ho jab model NULL ho
    if (_dashboardModel == null) {
      _isLoading = true;
      notifyListeners();
    }

    _error = null;

    try {
      final response = await _repository.getDashboardData(token: token);

      if (response != null) {
        AppSnackBar.show(message: "Data Fetch Successfully");
        _dashboardModel = response;
      } else {
        _error = "Failed to fetch dashboard data.";
      }
    } catch (e) {
      _error = e.toString();
      AppSnackBar.show(message: e.toString(), isError: true);
    }

    // Loading false sirf tab karenge jab pehle true kiya tha
    if (_isLoading == true) {
      _isLoading = false;
      notifyListeners();
    }
  }

  //check the Time-period
  String getTimePeriod() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 20) {
      return "Good Evening";
    } else {
      return "Night";
    }
  }


  DashboardData? get dashboardData => _dashboardData;
  int get touchedIndex => _touchedIndex;

  DashboardProvider() {
    fetchData();
  }

  Future<void> fetchData() async {


    try {
      _dashboardData = await _repository.fetchDashboardData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void setTouchedIndex(int index) {
    _touchedIndex = index;
    notifyListeners();
  }
}
