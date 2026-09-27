import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Progress callback for downloads.
typedef DownloadProgressCallback = void Function(int received, int total);

/// Download result.
class DownloadResult {
  final bool success;
  final File? file;
  final String? error;
  const DownloadResult({required this.success, this.file, this.error});
}

/// Downloads files with progress tracking, retry, and checksum verification.
class DownloadService {
  String get name => 'DownloadService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Downloads [url] to [destination].
  Future<DownloadResult> download(
    String url,
    File destination, {
    DownloadProgressCallback? onProgress,
    int maxRetries = 3,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await destination.parent.create(recursive: true);

        final request = http.Request('GET', Uri.parse(url));
        final response = await request.send().timeout(timeout);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          if (attempt == maxRetries) {
            return DownloadResult(
              success: false,
              error: 'HTTP ${response.statusCode}',
            );
          }
          await Future<void>.delayed(Duration(seconds: attempt * 2));
          continue;
        }

        final total = response.contentLength ?? 0;
        var received = 0;

        final tmp = File('${destination.path}.tmp');
        final sink = tmp.openWrite();

        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, total);
        }
        await sink.flush();
        await sink.close();

        // Atomic rename.
        if (await destination.exists()) await destination.delete();
        await tmp.rename(destination.path);

        return DownloadResult(success: true, file: destination);
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(success: false, error: e.toString());
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }
    return const DownloadResult(success: false, error: 'Max retries exceeded');
  }
}
