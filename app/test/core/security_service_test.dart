import 'package:flutter_test/flutter_test.dart';

import 'package:cambric_app/core/security/secret_redaction_service.dart';
import 'package:cambric_app/core/security/security_service.dart';

void main() {
  group('SecurityService', () {
    test('hashes the same input to the same digest', () {
      final a = SecurityService.sha256String('cambric');
      final b = SecurityService.sha256String('cambric');

      expect(a, equals(b));
      expect(a.length, 64);
    });

    test('different input produces a different digest', () {
      expect(
        SecurityService.sha256String('a'),
        isNot(equals(SecurityService.sha256String('b'))),
      );
    });

    test('constant time comparison matches equality', () {
      expect(SecurityService.constantTimeEquals('abc', 'abc'), isTrue);
      expect(SecurityService.constantTimeEquals('abc', 'abd'), isFalse);
      expect(SecurityService.constantTimeEquals('abc', 'ab'), isFalse);
    });

    test('integrity tags verify only for the right secret', () {
      const secret = 'shared-secret';
      final tag = SecurityService.generateIntegrityTag('payload', secret);

      expect(
        SecurityService.verifyIntegrityTag('payload', tag, secret),
        isTrue,
      );
      expect(
        SecurityService.verifyIntegrityTag('payload', tag, 'wrong'),
        isFalse,
      );
    });
  });

  group('SecretRedactionService', () {
    final redaction = SecretRedactionService();

    test('redacts key-value secrets', () {
      final result = redaction.redact('api_key = super-secret-value');
      expect(result, isNot(contains('super-secret-value')));
      expect(result, contains('[REDACTED]'));
    });

    test('redacts sensitive map keys', () {
      final result = redaction.redactMap(<String, dynamic>{
        'password': 'hunter2',
        'name': 'visible',
      });

      expect(result['password'], '[REDACTED]');
      expect(result['name'], 'visible');
    });

    test('leaves ordinary text alone', () {
      const text = 'Cambric App 1.0.0 on Windows';
      expect(redaction.redact(text), text);
    });
  });
}
