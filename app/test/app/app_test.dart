import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cambric_app/app/app.dart';

void main() {
  group('themeModeFromName', () {
    test('restores each stored theme', () {
      expect(themeModeFromName('system'), ThemeMode.system);
      expect(themeModeFromName('light'), ThemeMode.light);
      expect(themeModeFromName('dark'), ThemeMode.dark);
    });

    test('falls back to system for null or unknown values', () {
      expect(themeModeFromName(null), ThemeMode.system);
      expect(themeModeFromName('not-a-theme'), ThemeMode.system);
    });
  });
}
