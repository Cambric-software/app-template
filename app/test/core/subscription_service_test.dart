import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cambric_app/core/config/cambric_config.dart';
import 'package:cambric_app/core/security/security_service.dart';
import 'package:cambric_app/core/subscription/license_key.dart';
import 'package:cambric_app/core/subscription/subscription_service.dart';
import 'package:cambric_app/core/subscription/subscription_tier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CambricConfig config;
  late SubscriptionService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    config = const CambricConfig(
      productId: 'cambric-app-product',
      productName: 'Cambric App Product',
      version: '1.0.0',
      templateVersion: '1.0.0',
    );
    service = SubscriptionService(
      config: config,
      security: const SecurityService(),
    );
    await service.load();
  });

  test('starts on free tier', () {
    expect(service.tier, SubscriptionTier.free);
    expect(service.state.isPaid, isFalse);
  });

  test('can() grants free for free', () {
    expect(service.can(SubscriptionTier.free), isTrue);
    expect(service.can(SubscriptionTier.pro), isFalse);
  });

  test('applyLicense rejects wrong product', () async {
    const license = LicenseKey(
      key: 'CBRC-TEST',
      tier: SubscriptionTier.pro,
      productId: 'other-product',
      issuedAt: 0,
      expiresAt: 0,
      signature: '',
    );
    final ok = await service.applyLicense(license);
    expect(ok, isFalse);
    expect(service.tier, SubscriptionTier.free);
  });

  test('applyLicense rejects expired key', () async {
    const license = LicenseKey(
      key: 'CBRC-TEST',
      tier: SubscriptionTier.pro,
      productId: 'cambric-app-product',
      issuedAt: 0,
      expiresAt: 1,
      signature: '',
    );
    final ok = await service.applyLicense(license);
    expect(ok, isFalse);
    expect(service.tier, SubscriptionTier.free);
  });

  test('clear reverts to free', () async {
    await service.clear();
    expect(service.tier, SubscriptionTier.free);
  });
}