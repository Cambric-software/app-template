import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/config/cambric_config.dart';

void main() {
  group('CambricConfig.fromJson', () {
    test('valid full config parses all fields correctly', () {
      final config = CambricConfig.fromJson({
        'product': {
          'id': 'my-app',
          'name': 'My App',
          'version': '2.3.4',
          'templateVersion': '1.0.0',
          'publisher': 'ACME',
          'website': 'https://example.com',
        },
        'release': {'provider': 'github', 'repository': 'org/my-app'},
        'localization': {
          'defaultLanguage': 'ar',
          'supportedLanguages': ['en', 'ar'],
          'rtlLanguages': ['ar'],
        },
        'environment': 'development',
      });

      expect(config.productId, equals('my-app'));
      expect(config.productName, equals('My App'));
      expect(config.version, equals('2.3.4'));
      expect(config.publisher, equals('ACME'));
      expect(config.defaultLanguage, equals('ar'));
      expect(config.supportedLanguages, containsAll(['en', 'ar']));
      expect(config.rtlLanguages, contains('ar'));
      expect(config.environment, equals('development'));
    });

    test('empty map returns safe defaults without throwing', () {
      final config = CambricConfig.fromJson({});
      expect(config.productId, isNotEmpty);
      expect(config.productName, isNotEmpty);
      expect(config.version, isNotEmpty);
    });

    test('null product section returns defaults', () {
      final config = CambricConfig.fromJson({'product': null});
      expect(config.productId, isNotEmpty);
    });

    test('missing version field uses default', () {
      final config = CambricConfig.fromJson({
        'product': {'id': 'test', 'name': 'Test'},
      });
      expect(config.version, isNotEmpty);
    });

    test('malformed localization list does not crash', () {
      final config = CambricConfig.fromJson({
        'localization': {
          'supportedLanguages': 'not-a-list',
          'rtlLanguages': 42,
        },
      });
      expect(config.supportedLanguages, isA<List<String>>());
      expect(config.rtlLanguages, isA<List<String>>());
    });

    test('boolean fields default correctly when absent', () {
      final config = CambricConfig.fromJson({});
      expect(config.updatesEnabled, isTrue);
      expect(config.automaticUpdateChecks, isTrue);
      expect(config.allowPrerelease, isFalse);
      expect(config.ecosystemEnabled, isTrue);
    });

    test('feature flags parsed from json', () {
      final config = CambricConfig.fromJson({
        'featureFlags': {
          'showDeveloperTools': true,
          'customFlag': false,
        },
      });
      expect(config.featureFlags.isEnabled('showDeveloperTools'), isTrue);
      expect(config.featureFlags.isEnabled('customFlag'), isFalse);
    });

    test('missing featureFlags section does not crash', () {
      final config = CambricConfig.fromJson({'featureFlags': null});
      expect(config.featureFlags, isNotNull);
    });
  });
}
