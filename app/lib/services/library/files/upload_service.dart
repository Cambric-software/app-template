import 'dart:io';
import 'package:http/http.dart' as http;

/// Upload result.
class UploadResult {
  final bool success;
  final int? statusCode;
  final String? responseBody;
  final String? error;
  const UploadResult({required this.success, this.statusCode, this.responseBody, this.error});
}

/// Uploads files via HTTP multipart or PUT.
class UploadService {
  String get name => 'UploadService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Uploads [file] to [url] as a multipart POST.
  Future<UploadResult> uploadMultipart(
    File file,
    String url, {
    String fieldName = 'file',
    Map<String, String>? headers,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (headers != null) request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final response = await request.send().timeout(timeout);
      final body = await response.stream.bytesToString();
      return UploadResult(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        responseBody: body,
      );
    } catch (e) {
      return UploadResult(success: false, error: e.toString());
    }
  }

  /// Uploads [file] to [url] via HTTP PUT.
  Future<UploadResult> uploadPut(
    File file,
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final response = await http
          .put(Uri.parse(url), headers: headers, body: bytes)
          .timeout(timeout);
      return UploadResult(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    } catch (e) {
      return UploadResult(success: false, error: e.toString());
    }
  }
}
