import 'license_key.dart';
import 'subscription_tier.dart';

/// The current subscription state of a product.
class SubscriptionState {
  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.license,
    this.expiresAt = 0,
  });

  /// The active tier.
  final SubscriptionTier tier;

  /// The license key that granted the current tier, if any.
  final LicenseKey? license;

  /// Epoch seconds when the current subscription expires. 0 means no expiry.
  final int expiresAt;

  bool get isPaid => tier != SubscriptionTier.free;

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'license': license?.toJson(),
        'expiresAt': expiresAt,
      };

  factory SubscriptionState.fromJson(Map<String, dynamic> json) =>
      SubscriptionState(
        tier: SubscriptionTier.fromName(json['tier'] as String?),
        license: json['license'] == null
            ? null
            : LicenseKey.fromJson(json['license'] as Map<String, dynamic>),
        expiresAt: (json['expiresAt'] as int?) ?? 0,
      );
}