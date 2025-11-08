import 'package:flutter/material.dart';
import '../../data/models/vehicle_data.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleListProvider with ChangeNotifier {
  final VehicleRepository _repository;
  bool _isFilterOpen = false;
  List<String> filterGroups = [];

  bool get isFilterOpen => _isFilterOpen;

  void toggleFilter() {
    _isFilterOpen = !_isFilterOpen;
    notifyListeners();
  }

  VehicleData? _vehicleData;
  String? _error;
  bool _isLoading = false;
  final Set<String> _selectedGroups = {};
  String _searchQuery = '';
  List<String> filterItems=["Group A", "Group B", "Group C", "Group D"];

  VehicleData? get vehicleData => _vehicleData;
  String? get error => _error;
  bool get isLoading => _isLoading;
  Set<String> get selectedGroups => _selectedGroups;
  String get searchQuery => _searchQuery;

  VehicleListProvider({VehicleRepository? repository})
      : _repository = repository ?? VehicleRepository() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicleData = await _repository.fetchVehicleData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleGroupSelection(String group) {
    if (_selectedGroups.contains(group)) {
      _selectedGroups.remove(group);
    } else {
      _selectedGroups.add(group);
    }
    notifyListeners();
  }

  List<Vehicle> get filteredVehicles {
    if (_vehicleData == null) return [];
    var vehicles = _vehicleData!.vehicles;
    if (_searchQuery.isNotEmpty) {
      vehicles = vehicles
          .where((vehicle) =>
          vehicle.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_selectedGroups.isNotEmpty) {
      vehicles = vehicles
          .where((vehicle) => _selectedGroups.contains(vehicle.status))
          .toList();
    }
    return vehicles;
  }
}