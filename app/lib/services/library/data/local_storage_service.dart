import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── LocalStorageService ────────────────────────────────────────────────────

/// Key-value persistent JSON file storage. User data. Never cleared with cache.
class LocalStorageService {
  Directory? _dir;

  String get name => 'LocalStorageService';
  bool get isAvailable => _dir != null;
  Future<bool> healthCheck() async => _dir != null;

  Future<void> initialize() async {
    final base = await getApplicationSupportDirectory();
    _dir = Directory('${base.path}${Platform.pathSeparator}data');
    await _dir!.create(recursive: true);
  }

  Future<void> dispose() async { _dir = null; }

  Future<void> write(String key, dynamic value) async {
    await _file(key).writeAsString(jsonEncode(value), flush: true);
  }

  Future<dynamic> read(String key) async {
    final f = _file(key);
    if (!await f.exists()) return null;
    try { return jsonDecode(await f.readAsString()); } catch (_) { return null; }
  }

  Future<bool> contains(String key) => _file(key).exists();

  Future<void> delete(String key) async {
    final f = _file(key);
    if (await f.exists()) await f.delete();
  }

  File _file(String key) {
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
    return File('${_dir!.path}${Platform.pathSeparator}$safe.json');
  }
}

// ── PreferencesService ─────────────────────────────────────────────────────

/// Typed access to shared_preferences.
class PreferencesService {
  SharedPreferences? _prefs;

  String get name => 'PreferencesService';
  bool get isAvailable => _prefs != null;
  Future<bool> healthCheck() async => _prefs != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> dispose() async { _prefs = null; }

  Future<void> setBool(String key, bool value) async => _prefs?.setBool(key, value);
  Future<void> setString(String key, String value) async => _prefs?.setString(key, value);
  Future<void> setInt(String key, int value) async => _prefs?.setInt(key, value);
  Future<void> setDouble(String key, double value) async => _prefs?.setDouble(key, value);

  bool? getBool(String key) => _prefs?.getBool(key);
  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  double? getDouble(String key) => _prefs?.getDouble(key);

  Future<void> remove(String key) async => _prefs?.remove(key);
  Future<void> clear() async => _prefs?.clear();
  Set<String> get keys => _prefs?.getKeys() ?? {};
}

// ── SecureStorageService ────────────────────────────────────────────────────

/// Abstraction for secure/sensitive value storage.
///
/// On desktop/mobile production apps, use flutter_secure_storage or
/// platform keychain. This implementation falls back to SharedPreferences
/// and is NOT cryptographically secured — it is an interface placeholder.
///
/// IMPORTANT: Replace with flutter_secure_storage for production secrets.
class SecureStorageService {
  SharedPreferences? _prefs;
  static const _prefix = '__secure__';

  String get name => 'SecureStorageService';
  bool get isAvailable => _prefs != null;
  Future<bool> healthCheck() async => _prefs != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> dispose() async { _prefs = null; }

  Future<void> write(String key, String value) async {
    await _prefs?.setString('$_prefix$key', value);
  }

  String? read(String key) => _prefs?.getString('$_prefix$key');

  Future<void> delete(String key) async => _prefs?.remove('$_prefix$key');

  bool contains(String key) =>
      _prefs?.containsKey('$_prefix$key') ?? false;
}
