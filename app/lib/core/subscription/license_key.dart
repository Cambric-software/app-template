import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'subscription_tier.dart';

/// A signed license key that grants a subscription tier.
///
/// Keys are validated offline using HMAC-SHA256 so a product works without a
/// network connection. The signature is computed over the canonical payload
/// `tier|issuedAt|expiresAt|productId` with a shared secret held by the issuer.
class LicenseKey {
  const LicenseKey({
    required this.key,
    required this.tier,
    required this.productId,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
  });

  /// The opaque key string shown to the user (e.g. `CBRC-XXXX-XXXX-XXXX`).
  final String key;

  /// The tier this key grants.
  final SubscriptionTier tier;

  /// The product this key is valid for.
  final String productId;

  /// When the key was issued (epoch seconds).
  final int issuedAt;

  /// When the key expires (epoch seconds). 0 means never expires.
  final int expiresAt;

  /// HMAC-SHA256 signature over the canonical payload.
  final String signature;

  /// Whether this key has expired relative to [now] (epoch seconds).
  bool isExpired(int now) => expiresAt > 0 && now > expiresAt;

  /// Builds the canonical payload that was signed.
  String canonicalPayload() =>
      '${tier.name}|$issuedAt|$expiresAt|$productId';

  /// Verifies the signature against [secret] using constant-time comparison.
  bool verifySignature(String secret) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(canonicalPayload())).toString();
    return _constantTimeEquals(digest, signature);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'tier': tier.name,
        'productId': productId,
        'issuedAt': issuedAt,
        'expiresAt': expiresAt,
        'signature': signature,
      };

  factory LicenseKey.fromJson(Map<String, dynamic> json) => LicenseKey(
        key: json['key'] as String,
        tier: SubscriptionTier.fromName(json['tier'] as String?),
        productId: json['productId'] as String,
        issuedAt: json['issuedAt'] as int,
        expiresAt: json['expiresAt'] as int,
        signature: json['signature'] as String,
      );
}