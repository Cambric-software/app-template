import 'license_key.dart';
import 'subscription_tier.dart';

/// Abstraction over a payment/checkout provider.
///
/// Implementations handle the actual money movement. The template ships only
/// [StubPaymentProvider], which is disabled and never charges anything. A
/// product swaps in a real provider (Paddle, Lemon Squeezy, Paymob, ...) once
/// the business is ready to receive money.
abstract class PaymentProvider {
  const PaymentProvider();

  /// Human-readable name of this provider.
  String get name;

  /// Whether this provider is configured and able to charge.
  bool get isConfigured;

  /// Starts a checkout flow for [tier]. Returns a checkout URL or null on
  /// failure. The app never handles card data directly.
  Future<String?> startCheckout(SubscriptionTier tier);

  /// Verifies a purchase referenced by [reference] and returns the granted
  /// [LicenseKey], or null on failure.
  Future<LicenseKey?> verifyPurchase(String reference);
}

/// A disabled provider used by default. It never charges and never configures.
class StubPaymentProvider extends PaymentProvider {
  const StubPaymentProvider();

  @override
  String get name => 'none';

  @override
  bool get isConfigured => false;

  @override
  Future<String?> startCheckout(SubscriptionTier tier) async => null;

  @override
  Future<LicenseKey?> verifyPurchase(String reference) async => null;
}