import 'package:http/http.dart' as http;

class NetworkService {
  static final NetworkService instance = NetworkService._();

  NetworkService._();

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) {
    return http.get(
      uri,
      headers: headers,
    );
  }
}
