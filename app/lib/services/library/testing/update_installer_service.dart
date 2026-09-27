import 'dart:io';

class InstallResult {
  final bool success;
  final String? error;
  const InstallResult({required this.success, this.error});
  static const ok = InstallResult(success: true);
}

class UpdateInstallerService {
  String get name => 'UpdateInstallerService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<InstallResult> install(String packagePath) async {
    final file = File(packagePath);
    if (!await file.exists()) return InstallResult(success: false, error: 'Package not found: $packagePath');
    if (Platform.isWindows) return _installWindows(packagePath);
    if (Platform.isLinux) return _installLinux(packagePath);
    return InstallResult(success: false, error: 'Installation not supported on ${Platform.operatingSystem}');
  }

  Future<InstallResult> _installWindows(String path) async {
    try {
      final r = await Process.run(path, ['/S'], runInShell: true);
      return r.exitCode == 0 ? InstallResult.ok : InstallResult(success: false, error: r.stderr.toString());
    } catch (e) { return InstallResult(success: false, error: e.toString()); }
  }

  Future<InstallResult> _installLinux(String path) async {
    try {
      final r = await Process.run('tar', ['-xzf', path, '-C', '/opt'], runInShell: true);
      return r.exitCode == 0 ? InstallResult.ok : InstallResult(success: false, error: r.stderr.toString());
    } catch (e) { return InstallResult(success: false, error: e.toString()); }
  }
}
