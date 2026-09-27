import 'dart:io';

/// Result of an installation attempt.
class InstallResult {
  final bool success;
  final String? error;

  const InstallResult({required this.success, this.error});

  static const InstallResult ok = InstallResult(success: true);

  factory InstallResult.failed(String error) =>
      InstallResult(success: false, error: error);

  @override
  String toString() => success
      ? 'InstallResult(success)'
      : 'InstallResult(failed: $error)';
}

/// Abstract installer interface.
///
/// Implementations are platform-specific.  Shared code uses this interface
/// and never checks [Platform.isWindows] directly in application logic.
///
/// Obtain the correct implementation via [InstallerService.forCurrentPlatform].
abstract class InstallerService {
  const InstallerService();

  /// Returns the appropriate installer for the current platform.
  factory InstallerService.forCurrentPlatform() {
    if (Platform.isWindows) return const WindowsInstallerService();
    if (Platform.isLinux) return const LinuxInstallerService();
    if (Platform.isAndroid) return const AndroidInstallerService();
    return const UnsupportedInstallerService();
  }

  /// Installs the package at [packagePath].
  Future<InstallResult> install(String packagePath);

  /// Checks whether installation prerequisites are available.
  Future<bool> canInstall();

  /// Human-readable platform name.
  String get platformName;
}

// ── Windows ───────────────────────────────────────────────────────────────

/// Windows installer.
///
/// Launches the downloaded installer binary and waits for it to complete.
/// Does NOT perform unsafe registry changes directly.
class WindowsInstallerService extends InstallerService {
  const WindowsInstallerService();

  @override
  String get platformName => 'Windows';

  @override
  Future<bool> canInstall() async => Platform.isWindows;

  @override
  Future<InstallResult> install(String packagePath) async {
    if (!Platform.isWindows) {
      return InstallResult.failed(
        'WindowsInstallerService cannot run on ${Platform.operatingSystem}.',
      );
    }

    final file = File(packagePath);
    if (!await file.exists()) {
      return InstallResult.failed('Package not found: $packagePath');
    }

    try {
      // Launch the installer and wait for it to complete.
      final result = await Process.run(
        packagePath,
        ['/S'], // Silent install flag — common for NSIS/Inno Setup.
        runInShell: true,
      );

      if (result.exitCode != 0) {
        return InstallResult.failed(
          'Installer exited with code ${result.exitCode}: ${result.stderr}',
        );
      }

      return InstallResult.ok;
    } catch (e) {
      return InstallResult.failed(e.toString());
    }
  }
}

// ── Linux ─────────────────────────────────────────────────────────────────

/// Linux installer.
///
/// Extracts a bundle archive and copies it to the target location.
class LinuxInstallerService extends InstallerService {
  const LinuxInstallerService();

  @override
  String get platformName => 'Linux';

  @override
  Future<bool> canInstall() async => Platform.isLinux;

  @override
  Future<InstallResult> install(String packagePath) async {
    if (!Platform.isLinux) {
      return InstallResult.failed(
        'LinuxInstallerService cannot run on ${Platform.operatingSystem}.',
      );
    }

    final file = File(packagePath);
    if (!await file.exists()) {
      return InstallResult.failed('Package not found: $packagePath');
    }

    try {
      // Extract the archive.  Assumes a .tar.gz bundle.
      final result = await Process.run(
        'tar',
        ['-xzf', packagePath, '-C', '/opt'],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        return InstallResult.failed(
          'Extraction failed (code ${result.exitCode}): ${result.stderr}',
        );
      }

      return InstallResult.ok;
    } catch (e) {
      return InstallResult.failed(e.toString());
    }
  }
}

// ── Android ───────────────────────────────────────────────────────────────

/// Android installer.
///
/// On Android, installation goes through the OS package installer intent.
/// This implementation is a placeholder — the real APK install flow requires
/// platform channel code or a plugin (e.g., open_file or android_intent).
class AndroidInstallerService extends InstallerService {
  const AndroidInstallerService();

  @override
  String get platformName => 'Android';

  @override
  Future<bool> canInstall() async => Platform.isAndroid;

  @override
  Future<InstallResult> install(String packagePath) async {
    // TODO: Implement via platform channel or plugin.
    // The Dart-level installer cannot directly invoke the Android
    // PackageInstaller without a native bridge.
    return InstallResult.failed(
      'Android installation requires platform channel integration. '
      'See docs/UPDATES.md for implementation guidance.',
    );
  }
}

// ── Unsupported ───────────────────────────────────────────────────────────

class UnsupportedInstallerService extends InstallerService {
  const UnsupportedInstallerService();

  @override
  String get platformName => Platform.operatingSystem;

  @override
  Future<bool> canInstall() async => false;

  @override
  Future<InstallResult> install(String packagePath) async =>
      InstallResult.failed(
        'Installation is not supported on ${Platform.operatingSystem}.',
      );
}
