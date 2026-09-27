class UriService {
  String get name => 'UriService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Uri? parse(String url) => Uri.tryParse(url);

  bool isValid(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme;
  }

  bool isHttps(String url) {
    final uri = Uri.tryParse(url);
    return uri?.scheme == 'https';
  }

  String addQueryParams(String url, Map<String, String> params) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final existing = Map<String, String>.from(uri.queryParameters);
    existing.addAll(params);
    return uri.replace(queryParameters: existing).toString();
  }

  Map<String, String> queryParams(String url) =>
      Uri.tryParse(url)?.queryParameters ?? {};

  String encode(String value) => Uri.encodeComponent(value);
  String decode(String value) => Uri.decodeComponent(value);
}
