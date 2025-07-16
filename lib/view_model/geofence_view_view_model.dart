import 'package:flutter/foundation.dart';
import 'package:trackerapp/data/response/api_response.dart';
import 'package:trackerapp/models/geo_fence_model.dart';
import 'package:trackerapp/repository/geo_fence_list_repository.dart';
import 'package:trackerapp/utils/utils.dart';

import 'userlogin_view_model.dart';

class GeoFenceViewViewModel with ChangeNotifier {
  final _geofencerepo = GeoFenceListRepository();
  bool _disposed = false;

  ApiResponse<GeoFenceModel> geoFenceListResponse = ApiResponse.loading();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    if (kDebugMode) {
      print('GeoFenceViewViewModel disposed');
    }
  }

  void setGeoFenceListResponse(ApiResponse<GeoFenceModel> response) {
    if (!_disposed) {
      geoFenceListResponse = response;
      notifyListeners();
      if (kDebugMode) {
        print('State updated: ${response.status}');
      }
    } else {
      if (kDebugMode) {
        print('State update skipped: ViewModel disposed');
      }
    }
  }

  Future<void> fetchGeoFenceFromApi() async {
    if (_disposed) return;
    try {
      setGeoFenceListResponse(ApiResponse.loading());
      final userApiKeyString = await UserLoginViewModel().getUserApiHashString();
      if (kDebugMode) {
        print('User API Key: $userApiKeyString');
      }
      final value = await _geofencerepo.geoFenceListFromAPI(userApiKeyString);
      if (kDebugMode) {
        for (var element in value.items.geofences) {
          print('Geofence: ${element.name}');
        }
      }
      setGeoFenceListResponse(ApiResponse.complete(value));
    } catch (error) {
      if (!_disposed) {
        setGeoFenceListResponse(ApiResponse.error(error.toString()));
        Utils.toastMessage(error.toString());
        if (kDebugMode) {
          print('Fetch Error: $error');
        }
      }
    }
  }

  Future<void> deleteGeoFenceFromAPI(String fenceID) async {
    if (_disposed) return;
    try {
      setGeoFenceListResponse(ApiResponse.loading());
      final userApiKeyString = await UserLoginViewModel().getUserApiHashString();
      await _geofencerepo.deleteGeoFenceActivationStatus(userApiKeyString, fenceID);
      if (!_disposed) {
        Utils.toastMessage('Geofence deleted successfully');
        await fetchGeoFenceFromApi();
      }
    } catch (error) {
      if (!_disposed) {
        setGeoFenceListResponse(ApiResponse.error(error.toString()));
        // Utils.toastMessage(error.toString( ));
        if (kDebugMode) {
          print('Delete Error: $error');
        }
      }
    }
  }

  Future<void> changeGeoFenceStatusFromAPI(String fenceID, int fenceStatus) async {
    if (_disposed) return;
    try {
      setGeoFenceListResponse(ApiResponse.loading());
      final userApiKeyString = await UserLoginViewModel().getUserApiHashString();
      await _geofencerepo.changeGeoFenceActivationStatus(userApiKeyString, fenceID, fenceStatus);
      if (!_disposed) {
        Utils.toastMessage('Geofence status updated');
        await fetchGeoFenceFromApi();
      }
    } catch (error) {
      if (!_disposed) {
        setGeoFenceListResponse(ApiResponse.error(error.toString()));
        Utils.toastMessage(error.toString());
        if (kDebugMode) {
          print('Status Change Error: $error');
        }
      }
    }
  }
}