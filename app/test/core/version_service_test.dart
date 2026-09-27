import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/lifecycle/version_service.dart';

void main() {
  group('AppVersion', () {
    test('parses standard semver', () {
      final v = AppVersion.parse('1.4.3');
      expect(v.major, 1);
      expect(v.minor, 4);
      expect(v.patch, 3);
      expect(v.build, isNull);
    });

    test('parses semver with leading v', () {
      final v = AppVersion.parse('v2.0.1');
      expect(v.major, 2);
      expect(v.minor, 0);
      expect(v.patch, 1);
    });

    test('parses semver with build label', () {
      final v = AppVersion.parse('1.0.0+47');
      expect(v.build, '47');
      expect(v.toString(), '1.0.0+47');
    });

    test('returns display string with v prefix', () {
      final v = AppVersion.parse('1.4.3');
      expect(v.display, 'v1.4.3');
    });

    test('compares versions correctly', () {
      final a = AppVersion.parse('1.0.0');
      final b = AppVersion.parse('2.0.0');
      final c = AppVersion.parse('1.0.0');

      expect(b > a, isTrue);
      expect(a < b, isTrue);
      expect(a == c, isTrue);
    });

    test('handles missing segments gracefully', () {
      final v = AppVersion.parse('1');
      expect(v.major, 1);
      expect(v.minor, 0);
      expect(v.patch, 0);
    });
  });

  group('VersionService', () {
    test('exposes display and versionString', () {
      final service = VersionService.fromString('1.4.3');
      expect(service.display, 'v1.4.3');
      expect(service.versionString, '1.4.3');
    });
  });
}
