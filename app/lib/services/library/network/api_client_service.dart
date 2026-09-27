import 'dart:convert';
import 'package:http/http.dart' as http;

/// Typed REST API client with base URL, auth injection, JSON parsing.
class ApiClientService {
  final String baseUrl;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};
  final Duration timeout;

  ApiClientService({required this.baseUrl, this.timeout = const Duration(seconds: 15)});

  String get name => 'ApiClientService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  void setAuthToken(String token) => _headers['Authorization'] = token;
  void setHeader(String key, String value) => _headers[key] = value;
  void removeHeader(String key) => _headers.remove(key);

  Future<Map<String, dynamic>?> getJson(String path) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers).timeout(timeout);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> postJson(String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body)).timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try { final d = jsonDecode(response.body); return d is Map<String, dynamic> ? d : {}; } catch (_) { return {}; }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> delete(String path) async {
    try {
      final r = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers).timeout(timeout);
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) { return false; }
  }
}
