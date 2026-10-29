import '../core/cache/cache_cleanup_service.dart';
import '../core/config/cambric_config.dart';
import '../core/diagnostics/diagnostics_service.dart';
import '../core/lifecycle/app_lifecycle_service.dart';
import '../core/lifecycle/version_service.dart';
import '../core/logging/logging_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/security/security_service.dart';
import '../core/storage/local_storage.dart';
import '../core/subscription/subscription_service.dart';
import '../core/updates/update_service.dart';
import '../core/services/preferences_service.dart';

/// The services this template actually wires at startup.
///
/// Everything here is constructed once in `main()` and passed down explicitly.
/// There is no global service locator: a screen receives the object it needs,
/// which keeps tests able to substitute a fake.
class AppServices {
  AppServices({
    required this.config,
    PreferencesService? preferences,
    LocalStorage? storage,
    CacheCleanupService? cacheCleanup,
    ConnectivityService? connectivity,
    UpdateService? updates,
    SubscriptionService? subscription,
  })  : preferences = preferences ?? PreferencesService.instance,
        storage = storage ?? LocalStorage(productId: config.productId),
        cacheCleanup = cacheCleanup ?? CacheCleanupService(),
        connectivity = connectivity ?? ConnectivityService(),
        updates = updates ?? UpdateService(),
        subscription = subscription ??
            SubscriptionService(
              config: config,
              security: const SecurityService(),
            ),
        version = VersionService.fromString(config.version) {
    diagnostics = DiagnosticsService(config: config, version: version);
  }

  /// Product identity and feature flags.
  final CambricConfig config;

  /// Authoritative version, parsed once from config.
  final VersionService version;

  /// Small persisted preferences: theme mode, onboarding completion.
  final PreferencesService preferences;

  /// Persistent user data, scoped to this product.
  final LocalStorage storage;

  /// Cache inspection and cleanup.
  final CacheCleanupService cacheCleanup;

  /// Network reachability, used by the diagnostics screen.
  final ConnectivityService connectivity;

  /// Release discovery, download and verification.
  final UpdateService updates;

  /// Subscription state and license validation.
  final SubscriptionService subscription;

  /// Local diagnostic report builder.
  late final DiagnosticsService diagnostics;

  final AppLifecycleService _lifecycle = AppLifecycleService();

  /// Prepares logging, lifecycle tracking and the product data directory.
  ///
  /// Safe to call once from `main()`. Errors are reported to diagnostics rather
  /// than preventing the app from starting.
  Future<void> initialize() async {
    CambricLogger.initialize();
    await _lifecycle.initialize();

    try {
      await storage.dataDirectory;
    } catch (error) {
      diagnostics.setStorageHealthy(false);
      diagnostics.reportError('Could not create the data directory', error: error);
    }

    try {
      await subscription.load();
    } catch (error) {
      diagnostics.reportError('Could not load subscription state', error: error);
    }
  }

  /// Stops lifecycle observation. Used by integration tests and hot restart.
  Future<void> dispose() => _lifecycle.dispose();
}
