/// A validation rule applied to a value.
typedef Validator<T> = String? Function(T value);

/// Result of running a set of validators against a value.
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({required this.isValid, this.errors = const []});

  static const ValidationResult ok = ValidationResult(isValid: true);

  factory ValidationResult.fail(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  String? get firstError => errors.isEmpty ? null : errors.first;

  @override
  String toString() =>
      isValid ? 'ValidationResult(valid)' : 'ValidationResult(${errors.join('; ')})';
}

/// Composable validation engine.
///
/// Built-in validators cover the most common cases. Compose multiple
/// validators with [all] or [first].
///
/// Usage:
/// ```dart
/// final v = ValidationService();
///
/// // Single field
/// final result = v.validate('hello@example.com', [
///   ValidationService.required(),
///   ValidationService.email(),
/// ]);
///
/// // Form-level
/// final formResult = v.validateForm({
///   'email': ['hello@example.com', [ValidationService.email()]],
///   'name': ['', [ValidationService.required()]],
/// });
/// ```
class ValidationService {
  String get name => 'ValidationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  // ── core ───────────────────────────────────────────────────────────────────

  /// Runs [validators] against [value], collecting all errors.
  ValidationResult validate<T>(T value, List<Validator<T>> validators) {
    final errors = <String>[];
    for (final v in validators) {
      final error = v(value);
      if (error != null) errors.add(error);
    }
    return errors.isEmpty
        ? ValidationResult.ok
        : ValidationResult.fail(errors);
  }

  // ── built-in validators ───────────────────────────────────────────────────

  static Validator<String?> required({String? message}) =>
      (v) => (v == null || v.trim().isEmpty)
          ? (message ?? 'This field is required.')
          : null;

  static Validator<String?> minLength(int min, {String? message}) =>
      (v) => (v != null && v.length >= min)
          ? null
          : (message ?? 'Minimum $min characters required.');

  static Validator<String?> maxLength(int max, {String? message}) =>
      (v) => (v == null || v.length <= max)
          ? null
          : (message ?? 'Maximum $max characters allowed.');

  static Validator<String?> email({String? message}) => (v) {
        if (v == null || v.trim().isEmpty) return null;
        final ok = RegExp(
          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(v.trim());
        return ok ? null : (message ?? 'Enter a valid email address.');
      };

  static Validator<String?> url({String? message}) => (v) {
        if (v == null || v.trim().isEmpty) return null;
        final uri = Uri.tryParse(v.trim());
        return (uri != null && uri.hasScheme && uri.scheme.startsWith('http'))
            ? null
            : (message ?? 'Enter a valid URL (https://...).');
      };

  static Validator<String?> numeric({String? message}) => (v) {
        if (v == null || v.trim().isEmpty) return null;
        return num.tryParse(v.trim()) != null
            ? null
            : (message ?? 'Enter a valid number.');
      };

  static Validator<String?> pattern(RegExp regex, {String? message}) =>
      (v) => (v != null && regex.hasMatch(v))
          ? null
          : (message ?? 'Value does not match expected format.');

  static Validator<String?> noSpecialChars({String? message}) =>
      (v) => (v == null || RegExp(r'^[a-zA-Z0-9 _\-\.]+$').hasMatch(v))
          ? null
          : (message ?? 'Only letters, numbers, spaces, - _ . allowed.');
}
