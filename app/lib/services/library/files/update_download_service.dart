import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads update packages to the local downloads directory.
class UpdateDownloadService {
  String get name => 'UpdateDownloadService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<File?> download(
    String url,
    String filename, {
    void Function(int received, int total)? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory(
        '${base.path}${Platform.pathSeparator}Downloads',
      );
      await dir.create(recursive: true);

      final dest = File('${dir.path}${Platform.pathSeparator}$filename');
      final tmp = File('${dest.path}.tmp');

      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send().timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = tmp.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }

      await sink.flush();
      await sink.close();

      if (await dest.exists()) await dest.delete();
      await tmp.rename(dest.path);

      return dest;
    } catch (_) {
      return null;
    }
  }
}
