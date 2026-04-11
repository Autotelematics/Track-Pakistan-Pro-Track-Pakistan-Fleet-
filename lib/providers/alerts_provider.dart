import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/data/repositories/alerts_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/session_guard.dart';
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
  DateTime? _fromDateFilter;
  DateTime? _toDateFilter;
  String? _pendingAlertTypeLabel;

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
  String? get alertTypeFilter => _alertTypeFilter;
  DateTime? get fromDateFilter => _fromDateFilter;
  DateTime? get toDateFilter => _toDateFilter;
  String? get pendingAlertTypeLabel => _pendingAlertTypeLabel;

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

  void setDateFilter(DateTime? date) {
    if (date == null) {
      _fromDateFilter = null;
      _toDateFilter = null;
      return;
    }
    final normalized = DateTime(date.year, date.month, date.day);
    _fromDateFilter = normalized;
    _toDateFilter = normalized;
  }

  void setDateRangeFilter({
    DateTime? from,
    DateTime? to,
  }) {
    DateTime? normalize(DateTime? d) =>
        d == null ? null : DateTime(d.year, d.month, d.day);
    _fromDateFilter = normalize(from);
    _toDateFilter = normalize(to);
  }

  void setPendingAlertTypeLabel(String? label) {
    _pendingAlertTypeLabel = label;
    notifyListeners();
  }

  void clearPendingAlertTypeLabel() {
    _pendingAlertTypeLabel = null;
    notifyListeners();
  }

  void clearFilters() {
    _deviceIdFilter = null;
    _alertTypeFilter = null;
    _searchQuery = null;
    _fromDateFilter = null;
    _toDateFilter = null;
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
      final token = await _resolveUserToken();
      if (token.isEmpty) {
        throw Exception("Authentication token not ready. Please try again.");
      }

      final result = await _getAlertsWithRetry(
        page: _currentPage,
        deviceId: _deviceIdFilter,
        alertType: _alertTypeFilter,
        from:
            _fromDateFilter == null ? null : _startOfDayIso(_fromDateFilter!),
        to: _toDateFilter == null ? null : _endOfDayIso(_toDateFilter!),
        token: token,
      );
      if (result != null) {
        _totalPages = (result.total / result.perPage).ceil();

        // Grand total only when no filters
        if (_deviceIdFilter == null &&
            _alertTypeFilter == null &&
            _fromDateFilter == null &&
            _toDateFilter == null) {
          _grandTotal = result.total;
        }

        final existingItems = _lastValidModel?.items ?? const <Item>[];
        final newItems = isRefresh
            ? result.items
            : [
                ...existingItems,
                ...result.items.where(
                  (newItem) => !existingItems.any((old) => old.id == newItem.id),
                ),
              ];

        _lastValidModel = result.copyWith(items: newItems);
        _model = _lastValidModel;

        // Clean invalid selections
        _selectedAlertIds
            .removeWhere((id) => !newItems.any((item) => item.id == id));

        if (_currentPage < _totalPages) _currentPage++;
      } else {
        throw Exception("Unable to load alerts right now. Please try again.");
      }
    } catch (e) {
      if (SessionGuard.isSessionExpiredError(e)) {
        await SessionGuard.forceLogout(message: e.toString());
        return;
      }
      _errorMessage = _friendlyErrorMessage(e);
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
    _fromDateFilter = null;
    _toDateFilter = null;
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
      if (SessionGuard.isSessionExpiredError(e)) {
        await SessionGuard.forceLogout(message: e.toString());
        return false;
      }
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

  Future<String> _resolveUserToken() async {
    var token = MySharedPreferences.getString(authTokenKey).trim();
    if (token.isNotEmpty) return token;

    // First app entry after login can race with async preference writes.
    for (int i = 0; i < 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await MySharedPreferences.reload();
      token = MySharedPreferences.getString(authTokenKey).trim();
      if (token.isNotEmpty) return token;
    }
    return token;
  }

  Future<GetAlertsModel?> _getAlertsWithRetry({
    required int page,
    required String token,
    String? deviceId,
    String? alertType,
    String? from,
    String? to,
  }) async {
    const maxAttempts = 3;
    for (int i = 1; i <= maxAttempts; i++) {
      final result = await _repository.getAlerts(
        page: page,
        deviceId: deviceId,
        alertType: alertType,
        from: from,
        to: to,
        userApiHashKey: token,
      );
      if (result != null) return result;
      if (i < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 450 * i));
      }
    }
    return null;
  }

  String _startOfDayIso(DateTime date) {
    final d = DateTime(date.year, date.month, date.day, 0, 0, 0);
    return "${DateFormat('yyyy-MM-dd').format(d)}T00:00:00";
  }

  String _endOfDayIso(DateTime date) {
    final d = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return "${DateFormat('yyyy-MM-dd').format(d)}T23:59:59";
  }

  String _friendlyErrorMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('network is unreachable') ||
        text.contains('timed out') ||
        text.contains('clientexception')) {
      return "Network connection issue. Please check internet and try again.";
    }
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw;
  }
}
