import 'dart:convert';
import 'dart:developer';
import 'package:trackerapp/data/models/get_driver_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:http/http.dart' as http;

class DriverRepository {
  //Add Driver Api Method
  Future<void> addDriverMethod({
    required String name,
    required String rfId,
    required String phone,
    required String email,
    required String deviceId,
  })
  async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey);
    final header = {'Content-Type': 'application/json'};
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.addDriverUserEp}$userApiHashKey&name=$name&device_id=$deviceId&rfid=$rfId&phone=$phone&email=$email");
    final response = await http.put(url, headers: header);
    log("Api hit statuscode:${response.statusCode}");
    log("Api hit body:${response.body}");
    if (response.statusCode == 200) {
      AppSnackBar.success(message: "Driver Added Successfully");
    } else {
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      AppSnackBar.error(message: decodedData["message"]);
    }
  }

  //Edit Driver Info
  Future<void> editDriverInfoMethod({
    required String driverId,
    required String name,
    required String rfid,
    required String phone,
    required String email,
    required String description,
  })
  async {
    final userAuthToken = MySharedPreferences.getString(authTokenKey);
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.editDriverUserEp}$userAuthToken&name=$name&rfid=$rfid&phone=$phone&email=$email&description=$description&id=$driverId");
    final headers = {"Content-Type": "application/json"};
    final response = await http.put(url, headers: headers);
    if (response.statusCode == 200) {
      AppSnackBar.success(message: "Driver Info Updated");
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      AppSnackBar.error(message: decodedBody["message"]);
    }
  }

  //get Driver Api Method
  Future<GetDriverModel?> getDriverMethod({
    required String deviceId,
  })
  async {
    try {
      final userApiHashKey = MySharedPreferences.getString(authTokenKey);
      final url = Uri.parse(
          "${AppUrl.baseURL}${AppUrl.getDriverUserEp}$userApiHashKey");
      final headers = {"Content-Type": "application/json"};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        AppSnackBar.success(message: "Driver users Fetched Successfully");
        final model = getDriverModelFromJson(response.body);
        return model;
      } else {
        Map<String, dynamic> decodedBody = jsonDecode(response.body);
        AppSnackBar.error(message: decodedBody["message"]);
      }
    } catch (e, stackTrace) {
      AppSnackBar.error(message: "Something went wrong while fetching drivers");
    }

    return null;
  }

  //Add Device To Driver ApiMethod
  Future<void> addDeviceToDriverMethod({
    required String driverId,
    required String deviceId,
  })
  async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey);
    final header = {'Content-Type': 'application/json'};
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.addDeviceToDriverEp}$userApiHashKey&driver_id=$driverId&device_id=$deviceId");
    final response = await http.post(url, headers: header);
    log("Api hit statuscode:${response.statusCode}");
    log("Api hit body:${response.body}");
    if (response.statusCode == 200) {
      AppSnackBar.success(message: "Driver Assign Successfully");
    } else {
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      AppSnackBar.error(message: decodedData["message"]);
    }
  }
}
