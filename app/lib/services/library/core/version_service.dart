/// Semantic version parser and comparator.
///
/// See [AppVersion] in `core/lifecycle/version_service.dart` for the full
/// implementation. This service is the thin wrapper used in the library.
class VersionService {
  final String _version;

  VersionService({String version = '1.0.0'}) : _version = version;

  String get name => 'VersionService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// The full version string.
  String get version => _version;

  /// Display string with v prefix.
  String get display =>
      _version.startsWith('v') ? _version : 'v$_version';

  /// Major version component.
  int get major => _parsedParts[0];
  int get minor => _parsedParts[1];
  int get patch => _parsedParts[2];

  List<int> get _parsedParts {
    final clean = _version.replaceFirst(RegExp(r'^v'), '').split('+')[0];
    final parts = clean.split('.');
    int seg(int i) =>
        i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
    return [seg(0), seg(1), seg(2)];
  }

  /// Returns true if this version is greater than [other].
  bool isNewerThan(String other) {
    final a = VersionService(version: _version)._parsedParts;
    final b = VersionService(version: other)._parsedParts;
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }
}
