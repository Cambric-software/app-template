/// Abstract clock for deterministic time in tests.
///
/// Inject [Clock] instead of calling [DateTime.now()] directly so tests
/// can control time without system dependencies.
///
/// Production code:
///
/// ```dart
/// final clock = SystemClock();
/// final timestamp = clock.now();
/// ```
///
/// Test code:
///
/// ```dart
/// final clock = FakeClock(DateTime(2026, 1, 1));
/// expect(service.lastChecked(clock), DateTime(2026, 1, 1));
/// ```
abstract class Clock {
  const Clock();

  /// Returns the current date and time.
  DateTime now();

  /// Returns the current UTC date and time.
  DateTime nowUtc() => now().toUtc();
}

/// Production clock that delegates to [DateTime.now()].
class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Test clock with a controllable fixed time.
///
/// Call [advance] to move time forward without sleeping.
class FakeClock extends Clock {
  DateTime _current;

  FakeClock(DateTime initial) : _current = initial;

  @override
  DateTime now() => _current;

  /// Advances the clock by [duration].
  void advance(Duration duration) {
    _current = _current.add(duration);
  }

  /// Sets the clock to an explicit time.
  void setTime(DateTime time) {
    _current = time;
  }
}
