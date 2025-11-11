import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AuthRepository {
  Future<bool> loginApi({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.loginEp}email=$email&password=$password");
    final result = await http.post(url).timeout(const Duration(seconds: 12));
    final body = jsonDecode(result.body);

    if (result.statusCode == 200) {
      print("api Hash Key :${body["user_api_hash"]}");
      MySharedPreferences.setBool(isLoggedInKey,true);
      MySharedPreferences.setString(authTokenKey,body["user_api_hash"]);
      return true;
    } else {
      throw body["message"] ?? "Something went wrong";
    }
  }
}
