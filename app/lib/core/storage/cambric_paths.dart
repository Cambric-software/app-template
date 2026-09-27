import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Centralized platform-safe path resolution for Cambric applications.
///
/// All paths are resolved through [getApplicationSupportDirectory] so they
/// are correct and safe on Windows, Linux, and Android without hardcoding
/// any platform-specific separator or root directory.
///
/// Directory layout under the Cambric root:
///
/// ```
/// Cambric/
/// ├── Core/
/// │   ├── Registry/     — shared product registry (one file per product)
/// │   ├── Connections/  — approved inter-product connections
/// │   └── Ecosystem/    — ecosystem identity + metadata
/// ├── Products/
/// │   └── <productId>/
/// │       ├── Data/     — persistent user data
/// │       └── Cache/    — disposable cache
/// ├── Shared/
/// │   └── Data/         — shared data readable by approved products
/// ├── Downloads/        — staged release/update downloads
/// ├── Updates/          — staged updates pending installation
/// ├── Backups/          — versioned application backups
/// └── Logs/             — application logs
/// ```
class CambricPaths {
  // ── root ────────────────────────────────────────────────────────────────

  static Future<Directory> appData() async {
    final base = await getApplicationSupportDirectory();
    return _ensure(
      '${base.path}${Platform.pathSeparator}Cambric',
    );
  }

  // ── product ──────────────────────────────────────────────────────────────

  static Future<Directory> productData(String productId) async {
    final root = await appData();
    return _ensure(
      _join(root.path, 'Products', productId, 'Data'),
    );
  }

  static Future<Directory> productCache(String productId) async {
    final root = await appData();
    return _ensure(
      _join(root.path, 'Products', productId, 'Cache'),
    );
  }

  // ── shared ───────────────────────────────────────────────────────────────

  static Future<Directory> sharedData() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Shared', 'Data'));
  }

  // ── core ─────────────────────────────────────────────────────────────────

  static Future<Directory> registry() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Core', 'Registry'));
  }

  static Future<Directory> connections() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Core', 'Connections'));
  }

  static Future<Directory> ecosystem() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Core', 'Ecosystem'));
  }

  // ── downloads / updates / backups / logs ────────────────────────────────

  static Future<Directory> downloads() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Downloads'));
  }

  static Future<Directory> updates() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Updates'));
  }

  static Future<Directory> backups() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Backups'));
  }

  static Future<Directory> logs() async {
    final root = await appData();
    return _ensure(_join(root.path, 'Logs'));
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  /// Joins path segments with the platform-specific separator.
  static String _join(String base, [
    String? a,
    String? b,
    String? c,
  ]) {
    final sep = Platform.pathSeparator;
    var path = base;
    for (final segment in [a, b, c]) {
      if (segment != null) path = '$path$sep$segment';
    }
    return path;
  }

  /// Creates the directory if it does not exist and returns it.
  static Future<Directory> _ensure(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
