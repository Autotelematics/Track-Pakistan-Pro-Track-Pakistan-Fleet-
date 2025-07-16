import 'package:flutter/foundation.dart';
import 'package:trackerapp/data/network/networkAPIservices.dart';
import 'package:trackerapp/models/geo_fence_model.dart';
import 'package:trackerapp/res/components/app_endpoit.dart';

class GeoFenceListRepository {
  final NetworkAPIservices _apiServices = NetworkAPIservices();

  Future<GeoFenceModel> geoFenceListFromAPI(String hashkey) async {
    try {
      final response = await _apiServices.getAPIresponse(
          '${AppUrl.baseURL}${AppUrl.getGeoFenceListEndPoint}$hashkey');
      if (kDebugMode) {
        print('GeoFenceList Response: $response');
      }
      return GeoFenceModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('GeoFenceList API Error: $e');
      }
      rethrow;
    }
  }

  Future<void> changeGeoFenceActivationStatus(
      String hashkey, String fenceID, int fenceStatus) async {
    try {
      await _apiServices.getAPIresponse(
          '${AppUrl.baseURL}${AppUrl.changeGeoFenceActivationEndPoint}$hashkey&id=$fenceID&active=$fenceStatus');
    } catch (e) {
      if (kDebugMode) {
        print('ChangeGeoFenceStatus API Error: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteGeoFenceActivationStatus(
      String hashkey, String fenceID) async {
    try {
      await _apiServices.getAPIresponse(
          '${AppUrl.baseURL}${AppUrl.deleteGeoFenceEndPoint}$hashkey&geofence_id=$fenceID');
    } catch (e) {
      if (kDebugMode) {
        print('DeleteGeoFence API Error: $e');
      }
      rethrow;
    }
  }
}