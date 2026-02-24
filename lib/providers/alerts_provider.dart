import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/data/repositories/alerts_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AlertsProvider with ChangeNotifier {
  final AlertsRepository _repository = AlertsRepository();

  // State variables
  GetAlertsModel? _model;
  GetAlertsModel? _lastValidModel;
  bool _isLoading = false;
  bool _isLoadMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int? _grandTotal;

  // Filters
  String? _deviceIdFilter;
  String? _alertTypeFilter;
  String? _searchQuery;

  // Selection
  final Set<int> _selectedAlertIds = {};

  // Public getters
  GetAlertsModel? get model => _model ?? _lastValidModel;
  bool get isLoading => _isLoading;
  bool get isLoadMore => _isLoadMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Set<int> get selectedAlertIds => _selectedAlertIds;
  bool get hasMore => _currentPage < _totalPages;

  // Filtered items based on search query
  List<Item> get filteredItems {
    final items = model?.items ?? [];

    if (_searchQuery == null || _searchQuery!.trim().isEmpty) {
      return items;
    }

    final query = _searchQuery!.toLowerCase().trim();
    return items.where((item) {
      return item.deviceName.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query);
    }).toList();
  }

  List<String> get alertTypeList {
    final counts = model?.counts ?? {};
    final types = counts.keys.toList();
    return ['All', ...types];
  }

  Map<String, int> get alertTypeCounts {
    final map = Map<String, int>.from(model?.counts ?? {});
    map['All'] = _grandTotal ?? model?.total ?? 0;
    return map;
  }

  // Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set filters (without notifyListeners - will be called when fetchAlerts is triggered)
  void setDeviceFilter(int? deviceId) {
    _deviceIdFilter = deviceId?.toString();
  }

  void setAlertTypeFilter(String? type) {
    _alertTypeFilter = type == "All" ? null : type;
  }

  void clearFilters() {
    _deviceIdFilter = null;
    _alertTypeFilter = null;
    _searchQuery = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedAlertIds.clear();
    notifyListeners();
  }

  void toggleSelection(int alertId) {
    if (_selectedAlertIds.contains(alertId)) {
      _selectedAlertIds.remove(alertId);
    } else {
      _selectedAlertIds.add(alertId);
    }
    notifyListeners();
  }

  // Main fetch method
  Future<void> fetchAlerts({
    bool isRefresh = false,
    required BuildContext context,
  }) async {
    if (isRefresh) {
      _currentPage = 1;
      _lastValidModel = null;
      _model = null;
      _grandTotal = null;
    }

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAlerts(
        page: _currentPage,
        deviceId: _deviceIdFilter,
        alertType: _alertTypeFilter,
        userApiHashKey: MySharedPreferences.getString(authTokenKey),
      );
      if (result != null) {
        _totalPages = (result.total / result.perPage).ceil();

        // Grand total only when no filters
        if (_deviceIdFilter == null && _alertTypeFilter == null) {
          _grandTotal = result.total;
        }

        final newItems = isRefresh
            ? result.items
            : [
          ...?_lastValidModel?.items,
          ...result.items.where((newItem) =>
          !_lastValidModel!.items.any((old) => old.id == newItem.id))
        ];

        _lastValidModel = result.copyWith(items: newItems);
        _model = _lastValidModel;

        // Clean invalid selections
        _selectedAlertIds
            .removeWhere((id) => !newItems.any((item) => item.id == id));

        if (_currentPage < _totalPages) _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadMore = false;
      notifyListeners();
    }
  }
  /// Resets only the filters (device + alert type) and refreshes alerts
  void resetFiltersOnly(BuildContext context) {
    _deviceIdFilter = null;
    _alertTypeFilter = null;
    _currentPage = 1;
    _lastValidModel = null;
    _model = null;
    _grandTotal = null;
    _selectedAlertIds.clear();
    fetchAlerts(isRefresh: true, context: context);
    notifyListeners();
  }

  // Delete alerts
  Future<bool> deleteSelectedAlerts() async {
    if (_selectedAlertIds.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteAlerts(
          alertIds: List.from(_selectedAlertIds),
          userApiHashKey: MySharedPreferences.getString(authTokenKey));
      if (success && _lastValidModel != null) {
        final remaining = _lastValidModel!.items
            .where((item) => !_selectedAlertIds.contains(item.id))
            .toList();

        _lastValidModel = _lastValidModel!.copyWith(
          items: remaining,
          total: _lastValidModel!.total - _selectedAlertIds.length,
        );
        _model = _lastValidModel;
        _selectedAlertIds.clear();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load more
  Future<void> loadMore(BuildContext context) async {
    if (_isLoadMore || !hasMore || _isLoading) return;
    await fetchAlerts(context: context);
  }
}