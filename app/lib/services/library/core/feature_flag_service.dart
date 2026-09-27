/// Local feature flag system — zero network dependency.
///
/// Flags are loaded from config at startup and are read-only at runtime.
/// Unknown flags always default to `false`.
///
/// Usage:
/// ```dart
/// final flags = FeatureFlagService(flags: config.featureFlags);
/// if (flags.isEnabled('showDeveloperTools')) { ... }
/// ```
class FeatureFlagService {
  final Map<String, bool> _flags;

  const FeatureFlagService({Map<String, bool> flags = const {}})
      : _flags = flags;

  factory FeatureFlagService.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FeatureFlagService();
    final flags = <String, bool>{};
    for (final entry in json.entries) {
      if (entry.value is bool) flags[entry.key] = entry.value as bool;
    }
    return FeatureFlagService(flags: Map.unmodifiable(flags));
  }

  String get name => 'FeatureFlagService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Returns true if [flag] is enabled; defaults to [defaultValue].
  bool isEnabled(String flag, {bool defaultValue = false}) =>
      _flags[flag] ?? defaultValue;

  /// Returns all flags.
  Map<String, bool> get all => _flags;

  @override
  String toString() => 'FeatureFlagService(${_flags.length} flags)';
}
