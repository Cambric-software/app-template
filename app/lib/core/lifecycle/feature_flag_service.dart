/// Simple local feature flag system.
///
/// Feature flags are loaded from [CambricConfig] at startup.
/// They are read-only at runtime — they are not hot-reloaded.
///
/// All flags default to `false` when not present in configuration.
/// This ensures unknown flags do not accidentally enable features.
///
/// Example configuration:
///
/// ```json
/// {
///   "featureFlags": {
///     "showDeveloperTools": true,
///     "enableExperimentalCache": false
///   }
/// }
/// ```
class FeatureFlagService {
  final Map<String, bool> _flags;

  const FeatureFlagService(this._flags);

  factory FeatureFlagService.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FeatureFlagService({});
    final flags = <String, bool>{};
    for (final entry in json.entries) {
      final value = entry.value;
      if (value is bool) {
        flags[entry.key] = value;
      }
    }
    return FeatureFlagService(Map.unmodifiable(flags));
  }

  /// Returns the value of [flag], defaulting to [defaultValue] when absent.
  bool isEnabled(
    String flag, {
    bool defaultValue = false,
  }) =>
      _flags[flag] ?? defaultValue;

  /// Returns all currently defined flags.
  Map<String, bool> get all => _flags;

  @override
  String toString() => 'FeatureFlagService(${_flags.length} flags)';
}
