import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/config/cambric_config.dart';
import 'package:cambric_app/theme/app_theme.dart';

void main() {
  group('App bootstrap integration', () {
    test('CambricConfig.load returns valid defaults when file is missing', () async {
      final config = await CambricConfig.load('nonexistent/path/config.json');
      expect(config.productId, isNotEmpty);
      expect(config.productName, isNotEmpty);
      expect(config.version, isNotEmpty);
      expect(config.templateVersion, isNotEmpty);
    });

    test('CambricConfig.load with empty path returns defaults without throwing', () async {
      final config = await CambricConfig.load('');
      expect(config, isNotNull);
      expect(config.productId, isNotEmpty);
    });

    test('CambricConfig.load called multiple times returns consistent defaults', () async {
      final a = await CambricConfig.load('not/exist.json');
      final b = await CambricConfig.load('also/not/exist.json');
      expect(a.productId, equals(b.productId));
      expect(a.version, equals(b.version));
    });

    test('AppTheme.light produces light brightness ThemeData', () {
      final theme = AppTheme.light();
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme, isNotNull);
    });

    test('AppTheme.dark produces dark brightness ThemeData', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme, isNotNull);
    });

    test('CambricConfig default values are safe for app startup', () async {
      final config = await CambricConfig.load('missing.json');
      // None of these should be null or throw when accessed
      expect(config.productId, isA<String>());
      expect(config.productName, isA<String>());
      expect(config.version, isA<String>());
      expect(config.updatesEnabled, isA<bool>());
      expect(config.ecosystemEnabled, isA<bool>());
      expect(config.supportedLanguages, isA<List<String>>());
    });
  });
}
