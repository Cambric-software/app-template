import 'dart:io';

abstract class InstallerService {
  const InstallerService();
  factory InstallerService.forCurrentPlatform() {
    if (Platform.isWindows) return const WindowsInstaller();
    if (Platform.isLinux) return const LinuxInstaller();
    return const UnsupportedInstaller();
  }
  Future<bool> install(String packagePath);
  Future<bool> canInstall();
  String get platformName;
}

class WindowsInstaller extends InstallerService {
  const WindowsInstaller();
  @override String get platformName => 'Windows';
  @override Future<bool> canInstall() async => Platform.isWindows;
  @override Future<bool> install(String packagePath) async {
    try { final r = await Process.run(packagePath, ['/S'], runInShell: true); return r.exitCode == 0; }
    catch (_) { return false; }
  }
}

class LinuxInstaller extends InstallerService {
  const LinuxInstaller();
  @override String get platformName => 'Linux';
  @override Future<bool> canInstall() async => Platform.isLinux;
  @override Future<bool> install(String packagePath) async {
    try { final r = await Process.run('tar', ['-xzf', packagePath, '-C', '/opt'], runInShell: true); return r.exitCode == 0; }
    catch (_) { return false; }
  }
}

class UnsupportedInstaller extends InstallerService {
  const UnsupportedInstaller();
  @override String get platformName => Platform.operatingSystem;
  @override Future<bool> canInstall() async => false;
  @override Future<bool> install(String packagePath) async => false;
}
