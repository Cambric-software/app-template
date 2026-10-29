import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/cambric_config.dart';
import '../security/security_service.dart';
import 'license_key.dart';
import 'payment_provider.dart';
import 'subscription_state.dart';
import 'subscription_tier.dart';

/// Manages a product's subscription state.
///
/// Validates license keys offline (HMAC), persists state via SharedPreferences,
/// and gates features by tier. Payment is delegated to a [PaymentProvider].
class SubscriptionService {
  SubscriptionService({
    required this.config,
    required this.security,
    PaymentProvider? provider,
    SharedPreferences? prefs,
  })  : provider = provider ?? const StubPaymentProvider(),
        _prefs = prefs;

  final CambricConfig config;
  final SecurityService security;
  final PaymentProvider provider;

  SharedPreferences? _prefs;
  SubscriptionState _state = const SubscriptionState();

  static const _storageKey = 'cambric.subscription.state';

  /// The current subscription state.
  SubscriptionState get state => _state;

  /// The currently active tier.
  SubscriptionTier get tier => _state.tier;

  /// Loads persisted state. Safe to call multiple times.
  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _state = const SubscriptionState();
      return;
    }
    try {
      _state = SubscriptionState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _state = const SubscriptionState();
    }
  }

  /// Persists the current state.
  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_storageKey, jsonEncode(_state.toJson()));
  }

  /// Whether the current tier grants [required].
  bool can(SubscriptionTier required) => tier.atLeast(required);

  /// Whether a feature name is allowed for the current tier.
  /// Whether a feature name is allowed for the current tier.
  ///
  /// Products extend this by overriding or by checking [can] directly. The
  /// default grants core features to everyone and everything else to paid tiers.
  bool canFeature(String feature) {
    if (feature == 'core') return true;
    return tier != SubscriptionTier.free;
  }

  /// Applies a license key. Returns true on success.
  Future<bool> applyLicense(LicenseKey license, {String? secret}) async {
    if (license.productId != config.productId) return false;
    if (license.isExpired(DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
      return false;
    }
    if (secret != null && !license.verifySignature(secret)) return false;
    _state = SubscriptionState(
      tier: license.tier,
      license: license,
      expiresAt: license.expiresAt,
    );
    await _save();
    return true;
  }

  /// Clears the subscription, reverting to free.
  Future<void> clear() async {
    _state = const SubscriptionState();
    await _save();
  }

  /// Starts a checkout flow via the configured provider.
  Future<String?> startCheckout(SubscriptionTier tier) async {
    if (!provider.isConfigured) return null;
    return provider.startCheckout(tier);
  }
}