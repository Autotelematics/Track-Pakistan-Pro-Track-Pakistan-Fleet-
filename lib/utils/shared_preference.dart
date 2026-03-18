import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerapp/utils/preference_keys.dart';

class MySharedPreferences {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> reload() async {
    _preferences.reload();
  }

  static containKey(String key) {
    return _preferences.containsKey(key);
  }

  static setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  static String getString(String key) {
    return _preferences.getString(key) ?? "";
  }

  static setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  static bool getBool(String key) {
    return _preferences.getBool(key) ?? false;
  }

  // New methods for int
  static setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  static int getInt(String key) {
    return _preferences.getInt(key) ?? 0;
  }

  static removeKey(String key) {
    return _preferences.remove(key);
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return _preferences.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return _preferences.getStringList(key) ?? [];
  }

  static Future<void> logout() async {
    await _preferences.remove(isLoggedInKey);
    await _preferences.remove(authTokenKey);
    await _preferences.remove(userIdKey);
    await _preferences.remove(userNameKey);
    await _preferences.remove(userEmailKey);
    await _preferences.remove(userTypeKey);
    await _preferences.remove(canChangePasswordKey);
    await _preferences.remove(canSendCommandViewKey);
    await _preferences.remove(latestFcmTokenKey);
    await _preferences.remove(lastSyncedFcmTokenKey);
    await _preferences.remove(lastSyncedFcmUserHashKey);
    await _preferences.remove(isImpersonatingAsUserKey);
    await _preferences.remove(adminOriginalAuthTokenKey);
    await _preferences.remove(adminOriginalUserIdKey);
    await _preferences.remove(adminOriginalUserEmailKey);
    await _preferences.remove(adminOriginalUserTypeKey);
  }

  static Future<void> clearAll() async {
    await _preferences.clear();
  }
}
