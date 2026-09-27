import 'dart:convert';
import 'dart:io';

import '../lifecycle/feature_flag_service.dart';

/// Central product identity and configuration.
///
/// All identity strings live here — never scatter product name, version,
/// or repository URL throughout the codebase.
///
/// Load once at startup:
///
/// ```dart
/// final config = await CambricConfig.load('lib/core/config/cambric_config.json');
/// ```
class CambricConfig {
  // ── product identity ─────────────────────────────────────────────────────

  final String productId;
  final String productName;
  final String? subtitle;
  final String? description;
  final String? publisher;
  final String version;
  final String templateVersion;
  final String? repository;
  final String? website;
  final String? supportUrl;

  // ── release ───────────────────────────────────────────────────────────────

  final String releaseProvider;
  final String? releaseApiBase;

  // ── cache ─────────────────────────────────────────────────────────────────

  final int cacheVersion;
  final int cacheMaxBytes;

  // ── updates ───────────────────────────────────────────────────────────────

  final bool updatesEnabled;
  final bool automaticUpdateChecks;
  final bool allowPrerelease;

  // ── ecosystem ─────────────────────────────────────────────────────────────

  final bool ecosystemEnabled;
  final int ecosystemProtocolVersion;

  // ── localization ──────────────────────────────────────────────────────────

  final String defaultLanguage;
  final List<String> supportedLanguages;
  final List<String> rtlLanguages;

  // ── environment ───────────────────────────────────────────────────────────

  final String environment;

  // ── feature flags ─────────────────────────────────────────────────────────

  final FeatureFlagService featureFlags;

  // ── branding ──────────────────────────────────────────────────────────────

  final String? brandPrimaryColor;
  final String? brandSecondaryColor;

  const CambricConfig({
    required this.productId,
    required this.productName,
    this.subtitle,
    this.description,
    this.publisher,
    required this.version,
    required this.templateVersion,
    this.repository,
    this.website,
    this.supportUrl,
    this.releaseProvider = 'github',
    this.releaseApiBase = 'https://api.github.com',
    this.cacheVersion = 1,
    this.cacheMaxBytes = 524288000, // 500 MB
    this.updatesEnabled = true,
    this.automaticUpdateChecks = true,
    this.allowPrerelease = false,
    this.ecosystemEnabled = true,
    this.ecosystemProtocolVersion = 1,
    this.defaultLanguage = 'en',
    this.supportedLanguages = const ['en'],
    this.rtlLanguages = const [],
    this.environment = 'production',
    this.featureFlags = const FeatureFlagService({}),
    this.brandPrimaryColor,
    this.brandSecondaryColor,
  });

  factory CambricConfig.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final release = json['release'] as Map<String, dynamic>? ?? {};
    final cache = json['cache'] as Map<String, dynamic>? ?? {};
    final update = json['update'] as Map<String, dynamic>? ?? {};
    final ecosystem = json['ecosystem'] as Map<String, dynamic>? ?? {};
    final localization =
        json['localization'] as Map<String, dynamic>? ?? {};
    final branding = json['branding'] as Map<String, dynamic>? ?? {};
    final flagsJson =
        json['featureFlags'] as Map<String, dynamic>?;

    List<String> stringList(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return const [];
    }

    return CambricConfig(
      productId:
          product['id']?.toString() ?? 'cambric-app-product',
      productName:
          product['name']?.toString() ?? 'Cambric App Product',
      subtitle: product['subtitle']?.toString(),
      description: product['description']?.toString(),
      publisher: product['publisher']?.toString(),
      version: product['version']?.toString() ?? '1.0.0',
      templateVersion:
          product['templateVersion']?.toString() ?? '1.0.0',
      repository: release['repository']?.toString(),
      website: product['website']?.toString(),
      supportUrl: product['supportUrl']?.toString(),
      releaseProvider:
          release['provider']?.toString() ?? 'github',
      releaseApiBase: release['apiBase']?.toString(),
      cacheVersion:
          (cache['version'] as num?)?.toInt() ?? 1,
      cacheMaxBytes:
          (cache['maxBytes'] as num?)?.toInt() ?? 524288000,
      updatesEnabled:
          update['enabled'] as bool? ?? true,
      automaticUpdateChecks:
          update['automaticChecks'] as bool? ?? true,
      allowPrerelease:
          update['allowPrerelease'] as bool? ?? false,
      ecosystemEnabled:
          ecosystem['enabled'] as bool? ?? true,
      ecosystemProtocolVersion:
          (ecosystem['protocolVersion'] as num?)?.toInt() ?? 1,
      defaultLanguage:
          localization['defaultLanguage']?.toString() ?? 'en',
      supportedLanguages:
          stringList(localization['supportedLanguages']),
      rtlLanguages:
          stringList(localization['rtlLanguages']),
      environment:
          json['environment']?.toString() ?? 'production',
      featureFlags: FeatureFlagService.fromJson(flagsJson),
      brandPrimaryColor: branding['primaryColor']?.toString(),
      brandSecondaryColor: branding['secondaryColor']?.toString(),
    );
  }

  /// Loads configuration from a JSON file.
  ///
  /// Returns sensible defaults when the file does not exist or is unreadable,
  /// so the application can always start even in a freshly cloned repository.
  static Future<CambricConfig> load(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      return const CambricConfig(
        productId: 'cambric-app-product',
        productName: 'Cambric App Product',
        version: '1.0.0',
        templateVersion: '1.0.0',
      );
    }

    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return CambricConfig.fromJson(data);
    } catch (_) {
      // Malformed config — return defaults rather than crash.
      return const CambricConfig(
        productId: 'cambric-app-product',
        productName: 'Cambric App Product',
        version: '1.0.0',
        templateVersion: '1.0.0',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'product': {
      'id': productId,
      'name': productName,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (publisher != null) 'publisher': publisher,
      'version': version,
      'templateVersion': templateVersion,
      if (website != null) 'website': website,
      if (supportUrl != null) 'supportUrl': supportUrl,
    },
    'release': {
      'provider': releaseProvider,
      if (repository != null) 'repository': repository,
      if (releaseApiBase != null) 'apiBase': releaseApiBase,
    },
    'cache': {
      'version': cacheVersion,
      'maxBytes': cacheMaxBytes,
    },
    'update': {
      'enabled': updatesEnabled,
      'automaticChecks': automaticUpdateChecks,
      'allowPrerelease': allowPrerelease,
    },
    'ecosystem': {
      'enabled': ecosystemEnabled,
      'protocolVersion': ecosystemProtocolVersion,
    },
    'localization': {
      'defaultLanguage': defaultLanguage,
      'supportedLanguages': supportedLanguages,
      'rtlLanguages': rtlLanguages,
    },
    'environment': environment,
    if (featureFlags.all.isNotEmpty) 'featureFlags': featureFlags.all,
    if (brandPrimaryColor != null || brandSecondaryColor != null)
      'branding': {
        if (brandPrimaryColor != null) 'primaryColor': brandPrimaryColor,
        if (brandSecondaryColor != null)
          'secondaryColor': brandSecondaryColor,
      },
  };
}
