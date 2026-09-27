import 'package:flutter/widgets.dart';

/// Manages language strings and RTL direction.
class LocalizationService {
  final Map<String, Map<String, String>> _strings;
  String _currentLanguage;

  LocalizationService({
    Map<String, Map<String, String>> strings = const {},
    String defaultLanguage = 'en',
  }) : _strings = strings, _currentLanguage = defaultLanguage;

  String get name => 'LocalizationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  String get currentLanguage => _currentLanguage;

  static const _rtlLanguages = {'ar', 'he', 'fa', 'ur'};
  bool get isRtl => _rtlLanguages.contains(_currentLanguage);
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  void setLanguage(String code) => _currentLanguage = code;

  String translate(String key, {String? fallback}) =>
      _strings[_currentLanguage]?[key] ?? _strings['en']?[key] ?? fallback ?? key;

  String call(String key, {String? fallback}) => translate(key, fallback: fallback);
}
