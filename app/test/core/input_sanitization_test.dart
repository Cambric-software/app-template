import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/security/input_sanitization_service.dart';

void main() {
  group('InputSanitizationService', () {
    group('sanitization', () {
      test('trims whitespace', () {
        expect(
          InputSanitizationService.trimWhitespace('  hello   world  '),
          'hello world',
        );
      });

      test('converts to safe identifier', () {
        expect(
          InputSanitizationService.toSafeIdentifier('My App Name!'),
          'my-app-name-',
        );
      });

      test('sanitizes filename removes traversal', () {
        final result =
            InputSanitizationService.sanitizeFilename('../../../etc/passwd');
        // Each '..' becomes '_' and '/' becomes '_'
        expect(result.contains('..'), isFalse);
        expect(result.contains('/'), isFalse);
        expect(result, contains('etc'));
        expect(result, contains('passwd'));
      });

      test('escapes HTML special chars', () {
        expect(
          InputSanitizationService.escapeHtml('<script>alert("xss")</script>'),
          '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;',
        );
      });
    });

    group('validators', () {
      test('validateRequired returns null for non-empty', () {
        expect(
          InputSanitizationService.validateRequired('hello'),
          isNull,
        );
      });

      test('validateRequired returns error for empty', () {
        expect(
          InputSanitizationService.validateRequired(''),
          isNotNull,
        );
      });

      test('validateEmail accepts valid email', () {
        expect(
          InputSanitizationService.validateEmail('user@example.com'),
          isNull,
        );
      });

      test('validateEmail rejects invalid email', () {
        expect(
          InputSanitizationService.validateEmail('not-an-email'),
          isNotNull,
        );
      });

      test('validateUrl accepts https URL', () {
        expect(
          InputSanitizationService.validateUrl('https://example.com'),
          isNull,
        );
      });

      test('validateUrl rejects non-URL', () {
        expect(
          InputSanitizationService.validateUrl('not a url'),
          isNotNull,
        );
      });

      test('validateUrl allows empty (optional field)', () {
        expect(
          InputSanitizationService.validateUrl(''),
          isNull,
        );
      });

      test('looksLikeSecret detects AWS key pattern', () {
        expect(
          InputSanitizationService.looksLikeSecret('AKIAIOSFODNN7EXAMPLE'),
          isTrue,
        );
      });

      test('looksLikeSecret returns false for normal text', () {
        expect(
          InputSanitizationService.looksLikeSecret('hello world'),
          isFalse,
        );
      });
    });
  });
}
