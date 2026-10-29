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

/// Merchant-of-Record providers. These accept international cards from buyers
/// and pay out to a local bank or wallet, which is what an Egyptian sole
/// proprietor needs. Swap one in once a receivable account exists.
///
/// Each is a scaffold: it reports not-configured until API keys are supplied,
/// so the app degrades to the free tier instead of crashing.
class PaddlePaymentProvider extends PaymentProvider {
  const PaddlePaymentProvider({this.apiKey, this.priceId});

  final String? apiKey;
  final String? priceId;

  @override
  String get name => 'paddle';

  @override
  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty && priceId != null;

  @override
  Future<String?> startCheckout(SubscriptionTier tier) async {
    if (!isConfigured) return null;
    // Integration point: POST to Paddle's checkout API and return the URL.
    return null;
  }

  @override
  Future<LicenseKey?> verifyPurchase(String reference) async {
    if (!isConfigured) return null;
    return null;
  }
}

class LemonSqueezyPaymentProvider extends PaymentProvider {
  const LemonSqueezyPaymentProvider({this.apiKey, this.storeId});

  final String? apiKey;
  final String? storeId;

  @override
  String get name => 'lemonsqueezy';

  @override
  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty && storeId != null;

  @override
  Future<String?> startCheckout(SubscriptionTier tier) async {
    if (!isConfigured) return null;
    return null;
  }

  @override
  Future<LicenseKey?> verifyPurchase(String reference) async {
    if (!isConfigured) return null;
    return null;
  }
}

/// Egypt-local providers. Useful when the buyer base is domestic and the
/// seller has a local merchant account.
class PaymobPaymentProvider extends PaymentProvider {
  const PaymobPaymentProvider({this.apiKey, this.integrationId});

  final String? apiKey;
  final String? integrationId;

  @override
  String get name => 'paymob';

  @override
  bool get isConfigured =>
      apiKey != null && apiKey!.isNotEmpty && integrationId != null;

  @override
  Future<String?> startCheckout(SubscriptionTier tier) async {
    if (!isConfigured) return null;
    return null;
  }

  @override
  Future<LicenseKey?> verifyPurchase(String reference) async {
    if (!isConfigured) return null;
    return null;
  }
}

class FawryPaymentProvider extends PaymentProvider {
  const FawryPaymentProvider({this.merchantCode, this.securityKey});

  final String? merchantCode;
  final String? securityKey;

  @override
  String get name => 'fawry';

  @override
  bool get isConfigured =>
      merchantCode != null && merchantCode!.isNotEmpty && securityKey != null;

  @override
  Future<String?> startCheckout(SubscriptionTier tier) async {
    if (!isConfigured) return null;
    return null;
  }

  @override
  Future<LicenseKey?> verifyPurchase(String reference) async {
    if (!isConfigured) return null;
    return null;
  }
}