import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_device_group_model.dart';
import 'package:trackerapp/data/repositories/get_device_group_repository.dart';

class GetDeviceGroupProvider with ChangeNotifier {
  final GetDeviceGroupRepository _repository = GetDeviceGroupRepository();

  GetDeviceGroupModel? _model;
  GetDeviceGroupModel? _lastValidModel;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isError = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  GetDeviceGroupModel? get model => _model;
  List<GetDeviceGroupModelItem> get groups => _model?.items ?? [];

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isError => _isError;
  String? get error => _error;

  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
  }

  Future<void> fetchDeviceGroups({bool isRefresh = false, required BuildContext context}) async {
    print("fetchDeviceGroups() called | isRefresh: $isRefresh | page: $_currentPage");

    if (isRefresh) {
      resetPagination();
      _model = null;
      _lastValidModel = null;
      notifyListeners();
    }

    if (_isLoading || (!_hasMore && !isRefresh)) {
      return;
    }

    try {
      _isLoading = true;
      _isError = false;
      notifyListeners();
      final result = await _repository.getDeviceGroupApi(page: _currentPage, dialogContext: context);
      if (result != null && result.items.isNotEmpty) {
        _totalPages = 1;
        if (isRefresh) {
          _lastValidModel = result;
        } else {
          final existing = _lastValidModel?.items ?? [];
          _lastValidModel = GetDeviceGroupModel(
            status: result.status,
            items: [...existing, ...result.items],
          );
        }
        _model = _lastValidModel!;
        _error = null;
        _currentPage++;
      } else {
        _isError = true;
        _error = "Failed to load device groups.";
      }

      _hasMore = _currentPage <= _totalPages;
    } catch (e) {
      _isError = true;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}