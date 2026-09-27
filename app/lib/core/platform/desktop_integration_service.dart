import 'dart:io';

/// Provides desktop integration hooks for Windows and Linux.
///
/// Operations:
/// - Reading application metadata (name, version, install path)
/// - Creating/removing desktop shortcuts where the OS supports it
///
/// Does NOT perform unsafe direct registry changes.
/// Does NOT create entries the OS installer already handles.
class DesktopIntegrationService {
  final String productName;
  final String productId;
  final String version;
  final String? executablePath;

  const DesktopIntegrationService({
    required this.productName,
    required this.productId,
    required this.version,
    this.executablePath,
  });

  bool get isDesktop => Platform.isWindows || Platform.isLinux;

  // ── shortcuts ─────────────────────────────────────────────────────────────

  /// Creates a desktop shortcut for the application.
  ///
  /// Returns `true` if the shortcut was created successfully.
  /// Returns `false` on unsupported platforms or when [executablePath] is null.
  Future<bool> createDesktopShortcut() async {
    if (!isDesktop || executablePath == null) return false;

    if (Platform.isWindows) return await _windowsShortcut();
    if (Platform.isLinux) return await _linuxDesktopEntry();
    return false;
  }

  /// Removes the desktop shortcut if it exists.
  Future<bool> removeDesktopShortcut() async {
    if (!isDesktop) return false;

    if (Platform.isWindows) {
      final path = await _windowsDesktopPath();
      final file = File('$path\\$productName.lnk');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    }

    if (Platform.isLinux) {
      final path = await _linuxDesktopFilePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    }

    return false;
  }

  // ── version metadata ─────────────────────────────────────────────────────

  /// Returns a map of application metadata suitable for display or logging.
  Map<String, String> get applicationMetadata => {
    'productName': productName,
    'productId': productId,
    'version': version,
    'platform': Platform.operatingSystem,
    if (executablePath != null) 'executablePath': executablePath!,
  };

  // ── private helpers ───────────────────────────────────────────────────────

  Future<bool> _windowsShortcut() async {
    final desktopPath = await _windowsDesktopPath();
    final shortcutPath = '$desktopPath\\$productName.lnk';

    try {
      // Create a VBScript to generate the .lnk shortcut.
      final script = '''
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "$shortcutPath"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = "${executablePath!.replaceAll('"', '')}"
oLink.Description = "$productName"
oLink.Save
''';

      final vbsFile = File('${Directory.systemTemp.path}\\create_shortcut.vbs');
      await vbsFile.writeAsString(script);

      final result = await Process.run(
        'cscript',
        ['//nologo', vbsFile.path],
        runInShell: true,
      );

      await vbsFile.delete();
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<String> _windowsDesktopPath() async {
    try {
      final result = await Process.run(
        'powershell',
        ['-Command', '[Environment]::GetFolderPath("Desktop")'],
        runInShell: true,
      );
      return result.stdout.toString().trim();
    } catch (_) {
      return '${Platform.environment['USERPROFILE'] ?? ''}\\Desktop';
    }
  }

  Future<bool> _linuxDesktopEntry() async {
    final path = await _linuxDesktopFilePath();
    final file = File(path);
    await file.parent.create(recursive: true);

    final content = '''
[Desktop Entry]
Name=$productName
Exec=${executablePath!}
Type=Application
Version=$version
Comment=$productName $version
Terminal=false
''';

    try {
      await file.writeAsString(content, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> _linuxDesktopFilePath() async {
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/.local/share/applications/$productId.desktop';
  }
}
