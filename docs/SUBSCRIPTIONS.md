# Subscriptions

How Cambric applications handle subscription tiers and license keys.

---

## Model

Subscriptions are tiered (`free`, `pro`, `enterprise`). The free tier is always
available and requires no payment or account. Higher tiers are granted by a
signed license key, validated offline via HMAC-SHA256, so the product works
without a network connection.

Payment is delegated to a `PaymentProvider`. The template ships only
`StubPaymentProvider`, which is disabled and never charges. A product swaps in
a real provider (Paddle, Lemon Squeezy, Paymob, ...) once the business is
ready to receive money.

## Configuration

In `app/lib/core/config/cambric_config.json`:

```json
{
  "subscription": {
    "enabled": false,
    "provider": "none",
    "tiers": ["free", "pro"],
    "defaultTier": "free",
    "licenseValidation": "offline-hmac",
    "updateGating": {
      "free": "stable",
      "pro": "stable,prerelease"
    }
  }
}
```

With `enabled: false` (default), no paywall is shown and every feature is
available as if on the free tier.

## Services

- `SubscriptionService` - loads and persists state, validates license keys,
  gates features by tier, delegates checkout to the provider.
- `LicenseKey` - signed key model with offline HMAC verification.
- `SubscriptionTier` - ordered enum of tiers.
- `SubscriptionState` - current tier, license, expiry.
- `PaymentProvider` / `StubPaymentProvider` - payment abstraction.

## Usage

```dart
final subs = AppServices().subscription;

// Check a tier
if (subs.can(SubscriptionTier.pro)) {
  // pro feature
}

// Apply a license key
final ok = await subs.applyLicense(license, secret: sharedSecret);
```

## Important

- License keys are validated offline; never require a network call to unlock.
- The template does not install or charge anything. A product implements the
  final checkout and install steps deliberately.
- Do not store the signing secret in source code or config files.