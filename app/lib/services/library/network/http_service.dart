import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Low-level HTTP client with typed responses, headers, and timeout.
class HttpService {
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  HttpService({
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 15),
  });

  String get name => 'HttpService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return http
        .get(Uri.parse(url), headers: _merge(headers))
        .timeout(timeout);
  }

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return http
        .post(Uri.parse(url), headers: _merge(headers), body: body)
        .timeout(timeout);
  }

  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return http
        .put(Uri.parse(url), headers: _merge(headers), body: body)
        .timeout(timeout);
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    return http
        .delete(Uri.parse(url), headers: _merge(headers))
        .timeout(timeout);
  }

  Future<Map<String, dynamic>?> getJson(String url,
      {Map<String, String>? headers}) async {
    final merged = _merge(headers);
    merged['Accept'] = 'application/json';
    final response = await get(url, headers: merged);
    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {}
    }
    return null;
  }

  Map<String, String> _merge(Map<String, String>? extra) => {
        ...defaultHeaders,
        if (extra != null) ...extra,
      };

  bool isSuccess(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;
}
