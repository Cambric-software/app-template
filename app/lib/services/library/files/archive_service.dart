import 'dart:io';

/// Archive operations (zip/tar via system commands).
///
/// Does NOT require a Dart archive plugin. Delegates to platform tools.
/// For a pure-Dart implementation, add the `archive` pub package.
class ArchiveService {
  String get name => 'ArchiveService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Creates a zip archive of [source] directory at [destination].
  Future<bool> zipDirectory(Directory source, File destination) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-Command',
          'Compress-Archive -Path "${source.path}\\*" -DestinationPath "${destination.path}" -Force',
        ]);
        return result.exitCode == 0;
      } else {
        final result = await Process.run(
          'zip',
          ['-r', destination.path, '.'],
          workingDirectory: source.path,
        );
        return result.exitCode == 0;
      }
    } catch (_) {
      return false;
    }
  }

  /// Extracts a zip archive to [destination] directory.
  Future<bool> unzip(File archive, Directory destination) async {
    await destination.create(recursive: true);
    try {
      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-Command',
          'Expand-Archive -Path "${archive.path}" -DestinationPath "${destination.path}" -Force',
        ]);
        return result.exitCode == 0;
      } else {
        final result = await Process.run(
          'unzip',
          ['-o', archive.path, '-d', destination.path],
        );
        return result.exitCode == 0;
      }
    } catch (_) {
      return false;
    }
  }

  /// Creates a tar.gz archive (Linux/macOS only).
  Future<bool> tarGz(Directory source, File destination) async {
    if (Platform.isWindows) return false;
    try {
      final result = await Process.run(
        'tar',
        ['-czf', destination.path, '-C', source.parent.path, source.uri.pathSegments.last],
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
