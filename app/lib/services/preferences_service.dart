import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._();

  PreferencesService._();

  SharedPreferences? _preferences;

  Future<SharedPreferences> get preferences async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await preferences;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await preferences;
    return prefs.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await preferences;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await preferences;
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await preferences;
    await prefs.remove(key);
  }
}
