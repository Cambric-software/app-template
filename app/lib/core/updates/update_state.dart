/// All states in the Cambric update state machine.
///
/// ```
/// idle
///   ↓
/// checking
///   ↓
/// available ─────────────────────────────────────────────┐
///   ↓                                                     │
/// downloading                                             │
///   ↓                                                     │
/// downloaded                                              │
///   ↓                                                     │
/// verifying                                               │
///   ↓                                                     │
/// readyToInstall                                          │
///   ↓                                                     │
/// installing                                              │
///   ↓                                                     │
/// installed                                               │
///                                                         │
/// Failure states:                                         │
/// notAvailable   ← (from checking)                       │
/// checkFailed    ← (from checking)                       │
/// downloadFailed ← (from downloading)                    │
/// verificationFailed ← (from verifying)                  │
/// installFailed  ← (from installing)                     │
/// rollbackRequired ← (from installing)                   │
/// rolledBack     ← (from rollbackRequired)               │
/// ```
enum UpdateState {
  idle,
  checking,
  available,
  notAvailable,
  checkFailed,
  downloading,
  downloaded,
  downloadFailed,
  verifying,
  verificationFailed,
  readyToInstall,
  installing,
  installed,
  installFailed,
  rollbackRequired,
  rolledBack,
}
