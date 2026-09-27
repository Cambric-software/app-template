/// Provides typed runtime access to application configuration values.
///
/// Wraps a flat key/value map with typed getters and default fallbacks.
/// Source the map from [CambricConfig.toJson()] at startup.
///
/// Usage:
/// ```dart
/// final config = ConfigurationService(data: cambricConfig.toJson());
///
/// final version = config.getString('product.version', fallback: '0.0.0');
/// final maxCacheBytes = config.getInt('cache.maxBytes', fallback: 524288000);
/// final updatesEnabled = config.getBool('update.enabled', fallback: true);
/// ```
class ConfigurationService {
  final Map<String, dynamic> _data;

  ConfigurationService({Map<String, dynamic> data = const {}})
      : _data = Map.unmodifiable(data);

  String get name => 'ConfigurationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Returns the raw value at [key] using dot notation, or null.
  dynamic get(String key) {
    final parts = key.split('.');
    dynamic current = _data;
    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  String getString(String key, {String fallback = ''}) {
    final v = get(key);
    return v?.toString() ?? fallback;
  }

  int getInt(String key, {int fallback = 0}) {
    final v = get(key);
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  bool getBool(String key, {bool fallback = false}) {
    final v = get(key);
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return fallback;
  }

  double getDouble(String key, {double fallback = 0.0}) {
    final v = get(key);
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  List<String> getStringList(String key, {List<String> fallback = const []}) {
    final v = get(key);
    if (v is List) return v.whereType<String>().toList();
    return fallback;
  }

  bool containsKey(String key) => get(key) != null;
}
