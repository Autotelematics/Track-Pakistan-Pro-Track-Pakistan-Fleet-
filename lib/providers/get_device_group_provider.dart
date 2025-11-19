import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_device_group_model.dart';
import 'package:trackerapp/data/repositories/get_device_group_repository.dart';

class GetDeviceGroupProvider with ChangeNotifier {
  final GetDeviceGroupRepository _repository = GetDeviceGroupRepository();

  GetDeviceGroupModel? _model;
  GetDeviceGroupModel? _lastValidModel;
  List<ItemItem> _groups = [];

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isError = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  GetDeviceGroupModel? get model => _model;
  List<ItemItem> get groups => _groups;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isError => _isError;
  String? get error => _error;

  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
  }

  Future<void> fetchDeviceGroups({bool isRefresh = false,required BuildContext context}) async {
    print("📌 fetchDeviceGroups() called | isRefresh: $isRefresh | page: $_currentPage");

    if (isRefresh) {
      resetPagination();
      _model = null;
      _lastValidModel = null;
      _groups = [];
      notifyListeners();
    }

    if (_isLoading || (!_hasMore && !isRefresh)) {
      print("⛔ Prevented duplicate API call");
      return;
    }

    try {
      _isLoading = true;
      _isError = false;
      notifyListeners();

      print("🌍 Calling API... Page $_currentPage");

      final result = await _repository.getDeviceGroupApi(page: _currentPage, dialogContext: context);

      if (result != null && result.items != null) {
        print("✔ API Successful. Items count: ${result.items!.length}");

        _totalPages = 1; // backend does not give pages

        if (isRefresh) {
          _lastValidModel = result;
        } else {
          final existing = _lastValidModel?.items ?? [];
          _lastValidModel = _lastValidModel?.copyWith(
            items: [...existing, ...result.items!],
          ) ?? result;
        }

        _model = _lastValidModel!;

        // Flatten groups safely
        _groups = _model!.items!
            .expand((group) => group.items ?? [])
            .cast<ItemItem>()
            .toList();

        print("📌 Flattened Groups Count: ${_groups.length}");

        _error = null;
        _currentPage++;
      } else {
        print("❌ API returned empty or error");
        _isError = true;
        _error = "Failed to load device groups.";
      }

      _hasMore = _currentPage <= _totalPages;
    } catch (e) {
      print("🔥 Exception in fetchDeviceGroups: $e");
      _isError = true;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
