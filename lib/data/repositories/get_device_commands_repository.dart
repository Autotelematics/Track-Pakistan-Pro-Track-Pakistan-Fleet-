import 'dart:convert';
import 'dart:developer';

import 'package:trackerapp/data/models/get_device_commands_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import "package:http/http.dart" as http;

class GetDeviceCommandsRepository {
  //Get Device Commands
  Future<List<GetDeviceCommandsModel>?> getDeviceCommands(
      {required String deviceId})
  async {
    final userAuthToken = MySharedPreferences.getString(authTokenKey);
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.getDeviceCommandsEp}$userAuthToken&device_id=$deviceId");
    final headers = {"Content-Type": "application/json"};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return getDeviceCommandsModelFromJson(response.body);
    } else {
      return null;
    }
  }

  //Send Device Commands
  Future<void> sendDeviceCommands({required String deviceId,commandType})
  async {
    final userAuthToken = MySharedPreferences.getString(authTokenKey);
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.sendDeviceCommandsEp}$userAuthToken&device_id=$deviceId&type=$commandType");
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      log("response statuscode :${response.statusCode}");
      log("response body :${response.body}");
    } else {
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      log("response error :${decodedData["message"]}");
      AppSnackBar.error(message: decodedData["message"]);
    }
  }
}
