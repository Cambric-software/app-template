import 'dart:io';

class DesktopIntegrationService {
  final String productName;
  final String? executablePath;

  const DesktopIntegrationService({required this.productName, this.executablePath});

  String get name => 'DesktopIntegrationService';
  bool get isAvailable => Platform.isWindows || Platform.isLinux;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => isAvailable;

  Future<bool> createShortcut() async {
    if (!isAvailable || executablePath == null) return false;
    if (Platform.isWindows) return _windowsShortcut();
    if (Platform.isLinux) return _linuxDesktopEntry();
    return false;
  }

  Future<bool> _windowsShortcut() async {
    try {
      final desktop = await _windowsDesktop();
      final script = 'Set oWS = WScript.CreateObject("WScript.Shell")\n'
          'oWS.CreateShortcut("$desktop\\\\$productName.lnk").TargetPath = "$executablePath"\n';
      final vbs = File('${Directory.systemTemp.path}\\create_sc.vbs');
      await vbs.writeAsString(script);
      final r = await Process.run('cscript', ['//nologo', vbs.path], runInShell: true);
      await vbs.delete();
      return r.exitCode == 0;
    } catch (_) { return false; }
  }

  Future<String> _windowsDesktop() async {
    try {
      final r = await Process.run('powershell', ['-Command', '[Environment]::GetFolderPath("Desktop")'], runInShell: true);
      return r.stdout.toString().trim();
    } catch (_) { return '${Platform.environment['USERPROFILE'] ?? ''}\\Desktop'; }
  }

  Future<bool> _linuxDesktopEntry() async {
    try {
      final home = Platform.environment['HOME'] ?? '/tmp';
      final f = File('$home/.local/share/applications/${productName.toLowerCase().replaceAll(' ', '_')}.desktop');
      await f.parent.create(recursive: true);
      await f.writeAsString('[Desktop Entry]\nName=$productName\nExec=$executablePath\nType=Application\nTerminal=false\n');
      return true;
    } catch (_) { return false; }
  }
}
