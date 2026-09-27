import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for secure/sensitive value storage.
///
/// ⚠️ This uses SharedPreferences as a fallback — NOT secure for production secrets.
/// Replace the internal implementation with `flutter_secure_storage` for real apps.
///
/// This class exists so all application code depends on SecureStorageService,
/// making it easy to swap in a real secure backend later.
class SecureStorageService {
  SharedPreferences? _prefs;
  static const String _prefix = '__secure__';

  String get name => 'SecureStorageService';
  bool get isAvailable => _prefs != null;
  Future<bool> healthCheck() async => _prefs != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> dispose() async => _prefs = null;

  Future<void> write(String key, String value) async =>
      _prefs?.setString('$_prefix$key', value);

  String? read(String key) => _prefs?.getString('$_prefix$key');

  Future<void> delete(String key) async => _prefs?.remove('$_prefix$key');

  bool contains(String key) =>
      _prefs?.containsKey('$_prefix$key') ?? false;
}
