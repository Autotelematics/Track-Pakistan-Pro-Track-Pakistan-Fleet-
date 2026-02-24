import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/geofence_model.dart';
import 'package:trackerapp/data/repositories/geofence_repository.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/utils/preference_keys.dart';

class GeofenceProvider with ChangeNotifier {
  final GeofenceRepository _repository = GeofenceRepository();

  GetGeofencesModel? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchQuery;

  // Public getters
  GetGeofencesModel? get model => _model;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Geofence> get filteredGeofence {
    final list = _model?.geofences ?? [];

    if (_searchQuery == null || _searchQuery!.trim().isEmpty) {
      return list;
    }

    final query = _searchQuery!.toLowerCase().trim();
    return list.where((g) => g.name.toLowerCase().contains(query)).toList();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchGeofence({
    bool isRefresh = false,
    required BuildContext context,
  }) async {
    if (isRefresh) {
      _model = null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getGeofence(
        userApiHashKey: MySharedPreferences.getString(authTokenKey),
      );

      if (result != null) {
        _model = result;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleGeofenceActive(int id) async {
    final geofence = _model?.geofences?.firstWhere((g) => g.id == id);
    if (geofence == null) return false;
    final newActive = !geofence.active;
    geofence.active = newActive;
    notifyListeners();
    final success = await _repository.changeGeofenceActive(
      id: id,
      active: newActive,
      userApiHashKey: MySharedPreferences.getString(authTokenKey),
    );
    if (!success) {
      geofence.active = !newActive;
      notifyListeners();
    }

    return success;
  }
}