/// Single authoritative version representation.
///
/// Parse from a semver string such as `"1.4.3"` or `"v1.4.3"`.
///
/// The same [AppVersion] must be used everywhere: UI, diagnostics, logs,
/// release system, update system, installer, and ecosystem registry.
/// Never maintain separate hardcoded version strings in different files.
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final String? build;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.build,
  });

  /// Parse a semver string.  Tolerates a leading `v`.
  ///
  /// Examples: `"1.0.0"`, `"v1.4.3"`, `"2.0.0+47"`.
  factory AppVersion.parse(String version) {
    final clean = version.trim().replaceFirst(RegExp('^v'), '');
    final plusParts = clean.split('+');
    final buildLabel = plusParts.length > 1 ? plusParts[1] : null;
    final parts = plusParts[0].split('.');

    int seg(int i) =>
        i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0;

    return AppVersion(
      major: seg(0),
      minor: seg(1),
      patch: seg(2),
      build: buildLabel,
    );
  }

  /// Returns the canonical `"major.minor.patch"` version string.
  String get version => '$major.$minor.$patch';

  /// Returns the full version string including build label if present.
  @override
  String toString() =>
      build != null ? '$version+$build' : version;

  /// Returns `"vX.Y.Z"` for display in the UI.
  String get display => 'v$version';

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);
}

/// Service that exposes the authoritative application version.
///
/// Initialized once from [CambricConfig] in `main()`.
class VersionService {
  final AppVersion _version;

  const VersionService(this._version);

  factory VersionService.fromString(String version) =>
      VersionService(AppVersion.parse(version));

  AppVersion get version => _version;

  /// Human-readable display string, e.g. `"v1.4.3"`.
  String get display => _version.display;

  /// Raw version string, e.g. `"1.4.3"`.
  String get versionString => _version.version;
}
