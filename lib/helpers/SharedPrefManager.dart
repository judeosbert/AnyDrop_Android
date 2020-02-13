import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static SharedPreferences _sharedPreferences;

  static Future<void> init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  static String getString(String key) =>
      _sharedPreferences.getString(key) ?? "";

  static Future<bool> setString(String key, String value) =>
      _sharedPreferences.setString(key, value);

  static bool getBool(String key) => _sharedPreferences.getBool(key) ?? false;

  static Future<bool> setBool(String key, bool value) =>
      _sharedPreferences.setBool(key, value);
}

class SharedPrefKeys {
  static String isHelpWindowShown = "isHelpWindowShown";
}
