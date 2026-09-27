/// Defines a named capability that can be granted or revoked.
class Capability {
  final String name;
  final String description;

  const Capability({required this.name, required this.description});

  @override
  String toString() => 'Capability($name)';
}

/// Built-in Cambric ecosystem capabilities.
abstract class CambricCapabilities {
  static const readSharedData = Capability(
    name: 'READ_SHARED_DATA',
    description: 'Read data from the Cambric shared data directory.',
  );
  static const writeSharedData = Capability(
    name: 'WRITE_SHARED_DATA',
    description: 'Write data to the Cambric shared data directory.',
  );
  static const requestService = Capability(
    name: 'REQUEST_SERVICE',
    description: 'Request a service from another Cambric application.',
  );
  static const exchangeData = Capability(
    name: 'EXCHANGE_DATA',
    description: 'Exchange approved data with another Cambric application.',
  );
}

/// Simple in-process access control for Cambric capabilities.
///
/// Grants and revokes capabilities for named subjects (product IDs or roles).
/// Capabilities are intentional — nothing is granted automatically.
///
/// This is not a replacement for OS-level permissions.  It provides a
/// software-level gate for the Cambric ecosystem protocol.
///
/// Usage:
///
/// ```dart
/// final acl = AccessControlService();
/// acl.grant('product-b', CambricCapabilities.readSharedData);
///
/// if (acl.can('product-b', CambricCapabilities.readSharedData)) {
///   // allow access
/// }
/// ```
class AccessControlService {
  final Map<String, Set<String>> _grants = {};

  /// Grants [capability] to [subject].
  void grant(String subject, Capability capability) {
    _grants.putIfAbsent(subject, () => {}).add(capability.name);
  }

  /// Revokes [capability] from [subject].
  void revoke(String subject, Capability capability) {
    _grants[subject]?.remove(capability.name);
  }

  /// Returns `true` if [subject] holds [capability].
  bool can(String subject, Capability capability) {
    return _grants[subject]?.contains(capability.name) ?? false;
  }

  /// Returns all capabilities currently held by [subject].
  Set<String> capabilitiesFor(String subject) =>
      Set.unmodifiable(_grants[subject] ?? {});

  /// Revokes all capabilities from [subject].
  void revokeAll(String subject) {
    _grants.remove(subject);
  }

  /// Clears all grants.
  void clear() => _grants.clear();
}
