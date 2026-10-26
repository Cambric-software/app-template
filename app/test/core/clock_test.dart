import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/lifecycle/clock.dart';

void main() {
  group('SystemClock', () {
    test('returns a real DateTime', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final now = clock.now();
      final after = DateTime.now();

      expect(now.isAfter(before) || now.isAtSameMomentAs(before), isTrue);
      expect(now.isBefore(after) || now.isAtSameMomentAs(after), isTrue);
    });
  });

  group('FakeClock', () {
    test('returns the fixed time', () {
      final fixed = DateTime(2026, 1, 15, 12, 0);
      final clock = FakeClock(fixed);
      expect(clock.now(), fixed);
    });

    test('advance moves time forward', () {
      final clock = FakeClock(DateTime(2026, 1, 1));
      clock.advance(const Duration(days: 7));
      expect(clock.now(), DateTime(2026, 1, 8));
    });

    test('setTime overrides current time', () {
      final clock = FakeClock(DateTime(2026, 1, 1));
      clock.setTime(DateTime(2030, 6, 15));
      expect(clock.now(), DateTime(2030, 6, 15));
    });

    test('nowUtc returns UTC', () {
      final clock = FakeClock(DateTime(2026, 1, 1, 12, 0));
      expect(clock.nowUtc().isUtc, isTrue);
    });
  });
}
