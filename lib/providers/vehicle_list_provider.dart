import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/repositories/vehicle_repository.dart';

class GetDevicesListProvider with ChangeNotifier {
  final VehicleRepository repository;
  BuildContext? _context;
// In GetDevicesListProvider
  bool _isFilterOpen = false;
  bool get isFilterOpen => _isFilterOpen;

  void toggleFilter() {
    _isFilterOpen = !_isFilterOpen;
    notifyListeners();
  }
  // State
  bool _isLoading = false;
  bool _showLoading = true;
  String? _error;
  GetDevicesListModel? _model;
  List<Item> _filteredVehicles = [];

  // Filters
  String _filterStatus = 'all';
  String? _groupFilter;
  String? _groupName = 'All';
  String _searchQuery = '';

  // Cache & Timer
  GetDevicesListModel? _lastValidModel;
  Timer? _timer;

  // Getters
  bool get isLoading => _isLoading;
  bool get showLoading => _showLoading;
  String? get error => _error;
  GetDevicesListModel? get vehicleData => _model;
  List<Item> get filteredVehicles => _filteredVehicles;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String? get groupName => _groupName;

  GetDevicesListProvider(this.repository);

  void init(BuildContext context) {
    _context = context;
    startPeriodicUpdates();
    fetchData();
  }

  void startPeriodicUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchData(isPeriodic: true);
    });
  }

  Future<void> fetchData({bool isPeriodic = false}) async {
    final context = _context;
    if (context == null) return;

    final hasValidData = _lastValidModel?.items?.isNotEmpty == true;
    final shouldShowLoading = !isPeriodic && !hasValidData;

    if (shouldShowLoading) {
      _showLoading = true;
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await repository.fetchVehicleData(dialogContext: context);
      if (data != null && data.items != null && data.items!.isNotEmpty) {
        _lastValidModel = data;
        _model = data;
        _error = null;
        _applyFilters();
      } else {
        _model = _lastValidModel;
        _filteredVehicles = hasValidData ? _filteredVehicles : [];
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _filteredVehicles = hasValidData ? _filteredVehicles : [];
      notifyListeners();
    } finally {
      _isLoading = false;
      _showLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void setFilter(String status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    _applyFilters();
  }

  void setGroupFilter(String? groupId, String? groupName) {
    _groupFilter = groupId;
    _groupName = groupName ?? 'All';
    _filterStatus = 'all';
    _applyFilters();
  }

  void _applyFilters() {
    if (_lastValidModel?.items == null) {
      _filteredVehicles = [];
      notifyListeners();
      return;
    }

    List<Item> filtered = List.from(_lastValidModel!.items!);

    // Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((v) =>
      v.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
    } else {
      // Status Filter
      switch (_filterStatus) {
        case 'running': filtered = filtered.where((v) => v.online == 'online').toList(); break;
        case 'stopped': filtered = filtered.where((v) => v.online == 'ack').toList(); break;
        case 'idle': filtered = filtered.where((v) => v.online == 'engine').toList(); break;
        case 'offline': filtered = filtered.where((v) =>
        v.online == 'offline' &&
            v.time?.toLowerCase() != 'not connected' &&
            v.time?.toLowerCase() != 'expired').toList(); break;
        case 'nodata': filtered = filtered.where((v) =>
        v.online == 'offline' && v.time?.toLowerCase() == 'not connected').toList(); break;
        case 'expired': filtered = filtered.where((v) =>
        v.online == 'offline' && v.time?.toLowerCase() == 'expired').toList(); break;
        case 'parked': filtered = filtered.where((v) => v.online == 'black').toList(); break;
      }
    }

    _filteredVehicles = filtered;
    notifyListeners();
  }

  int getCountForStatus(String status) {
    final items = _lastValidModel?.items ?? [];
    if (items.isEmpty) return 0;

    switch (status) {
      case 'all': return items.length;
      case 'running': return items.where((i) => i.online == 'online').length;
      case 'stopped': return items.where((i) => i.online == 'ack').length;
      case 'idle': return items.where((i) => i.online == 'engine').length;
      case 'offline': return items.where((i) =>
      i.online == 'offline' &&
          i.time?.toLowerCase() != 'not connected' &&
          i.time?.toLowerCase() != 'expired').length;
      case 'nodata': return items.where((i) =>
      i.online == 'offline' && i.time?.toLowerCase() == 'not connected').length;
      case 'expired': return items.where((i) =>
      i.online == 'offline' && i.time?.toLowerCase() == 'expired').length;
      case 'parked': return items.where((i) => i.online == 'black').length;
      default: return 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}