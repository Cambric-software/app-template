/// Immutable security policy configuration.
class SecurityPolicy {
  final int minPasswordLength;
  final bool requireUppercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int maxLoginAttempts;
  final Duration sessionTimeout;

  const SecurityPolicy({
    this.minPasswordLength = 8,
    this.requireUppercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = false,
    this.maxLoginAttempts = 5,
    this.sessionTimeout = const Duration(hours: 24),
  });

  /// Tighter policy for high-security contexts.
  static const SecurityPolicy strict = SecurityPolicy(
    minPasswordLength: 12,
    requireUppercase: true,
    requireNumbers: true,
    requireSpecialChars: true,
    maxLoginAttempts: 3,
    sessionTimeout: Duration(hours: 8),
  );

  /// Relaxed policy for low-risk or developer contexts.
  static const SecurityPolicy relaxed = SecurityPolicy(
    minPasswordLength: 6,
    requireUppercase: false,
    requireNumbers: false,
    sessionTimeout: Duration(days: 30),
  );
}

/// Validates passwords and exposes the active [SecurityPolicy].
class SecurityPolicyService {
  SecurityPolicy _policy;

  SecurityPolicyService({SecurityPolicy policy = const SecurityPolicy()})
      : _policy = policy;

  String get name => 'SecurityPolicyService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// The currently active policy.
  SecurityPolicy get policy => _policy;

  /// Replaces the active policy at runtime.
  void setPolicy(SecurityPolicy policy) => _policy = policy;

  /// Validates [password] against the active policy.
  ///
  /// Returns null when valid, or a human-readable error message otherwise.
  String? validatePassword(String password) {
    if (password.length < _policy.minPasswordLength) {
      return 'Password must be at least ${_policy.minPasswordLength} characters.';
    }
    if (_policy.requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (_policy.requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    if (_policy.requireSpecialChars &&
        !password.contains(RegExp(r'[!@#\$%^&*]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }
}
