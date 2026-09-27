import 'package:shared_preferences/shared_preferences.dart';

/// Typed shared preferences wrapper.
class PreferencesService {
  SharedPreferences? _prefs;

  String get name => 'PreferencesService';
  bool get isAvailable => _prefs != null;
  Future<bool> healthCheck() async => _prefs != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> dispose() async => _prefs = null;

  Future<void> setBool(String key, bool v) async => _prefs?.setBool(key, v);
  Future<void> setString(String key, String v) async => _prefs?.setString(key, v);
  Future<void> setInt(String key, int v) async => _prefs?.setInt(key, v);
  Future<void> setDouble(String key, double v) async => _prefs?.setDouble(key, v);
  Future<void> setStringList(String key, List<String> v) async => _prefs?.setStringList(key, v);

  bool? getBool(String key) => _prefs?.getBool(key);
  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  double? getDouble(String key) => _prefs?.getDouble(key);
  List<String>? getStringList(String key) => _prefs?.getStringList(key);

  bool getBoolOrDefault(String key, {bool fallback = false}) =>
      _prefs?.getBool(key) ?? fallback;
  String getStringOrDefault(String key, {String fallback = ''}) =>
      _prefs?.getString(key) ?? fallback;

  Future<void> remove(String key) async => _prefs?.remove(key);
  Future<void> clear() async => _prefs?.clear();
  bool contains(String key) => _prefs?.containsKey(key) ?? false;
  Set<String> get keys => _prefs?.getKeys() ?? {};
}
