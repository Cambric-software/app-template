import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Reusable HTTP service with retry, timeout, and offline isolation.
class NetworkService {
  static final NetworkService instance = NetworkService._();

  NetworkService._();

  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const int _defaultMaxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
  }) =>
      _withRetry(
        () => http.get(uri, headers: headers).timeout(timeout),
        maxRetries: maxRetries,
        uri: uri,
      );

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxRetries = 1,
  }) =>
      _withRetry(
        () => http.post(uri, headers: headers, body: body).timeout(timeout),
        maxRetries: maxRetries,
        uri: uri,
      );

  Future<http.Response> _withRetry(
    Future<http.Response> Function() operation, {
    required int maxRetries,
    required Uri uri,
  }) async {
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        return await operation();
      } on SocketException catch (e) {
        if (attempt > maxRetries) {
          throw NetworkException(
            'Network unavailable after $attempt attempts: ${e.message}',
            uri: uri,
          );
        }
        await Future<void>.delayed(_retryDelay * attempt);
      } on TimeoutException {
        if (attempt > maxRetries) {
          throw NetworkException(
            'Request timed out after $attempt attempts.',
            uri: uri,
          );
        }
        await Future<void>.delayed(_retryDelay * attempt);
      } catch (e) {
        throw NetworkException(e.toString(), uri: uri);
      }
    }
  }
}

class NetworkException implements Exception {
  final String message;
  final Uri? uri;

  const NetworkException(this.message, {this.uri});

  @override
  String toString() => uri != null
      ? 'NetworkException: $message (uri: $uri)'
      : 'NetworkException: $message';
}
