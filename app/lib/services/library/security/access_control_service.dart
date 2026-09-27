/// A named capability that can be granted to or revoked from a subject.
class Capability {
  final String name;
  final String description;

  const Capability({required this.name, required this.description});
}

/// Simple capability-based access control.
///
/// Subjects are arbitrary string identifiers (user IDs, role names, etc.).
/// Capabilities are named actions; the service tracks which subjects hold
/// which capabilities.
class AccessControlService {
  final Map<String, Set<String>> _grants = {};

  String get name => 'AccessControlService';
  bool get isAvailable => true;
  Future<void> initialize() async {}

  Future<void> dispose() async {
    _grants.clear();
  }

  Future<bool> healthCheck() async => true;

  /// Grants [capability] to [subject].
  void grant(String subject, Capability capability) =>
      _grants.putIfAbsent(subject, () => {}).add(capability.name);

  /// Revokes [capability] from [subject]. No-op if not held.
  void revoke(String subject, Capability capability) =>
      _grants[subject]?.remove(capability.name);

  /// Returns true if [subject] currently holds [capability].
  bool can(String subject, Capability capability) =>
      _grants[subject]?.contains(capability.name) ?? false;

  /// Removes all capabilities from [subject].
  void revokeAll(String subject) => _grants.remove(subject);

  /// Returns an unmodifiable set of capability names held by [subject].
  Set<String> capabilitiesFor(String subject) =>
      Set.unmodifiable(_grants[subject] ?? {});
}
