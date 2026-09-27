class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;
  const SupportedLanguage({required this.code, required this.name, required this.nativeName, this.isRtl = false});
}

class LanguageService {
  static const List<SupportedLanguage> builtIn = [
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English'),
    SupportedLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRtl: true),
  ];

  final List<SupportedLanguage> _supported;
  String _current;

  LanguageService({List<SupportedLanguage>? supported, String defaultCode = 'en'})
      : _supported = supported ?? builtIn, _current = defaultCode;

  String get name => 'LanguageService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  String get currentCode => _current;
  SupportedLanguage? get current => _supported.where((l) => l.code == _current).firstOrNull;
  List<SupportedLanguage> get all => List.unmodifiable(_supported);
  bool get isRtl => current?.isRtl ?? false;

  void setLanguage(String code) {
    if (_supported.any((l) => l.code == code)) _current = code;
  }
}
