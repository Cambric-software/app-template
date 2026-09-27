import 'package:flutter/material.dart';

import 'core/ecosystem/cambric_ecosystem_service.dart';
import 'core/ecosystem/product_registry_service.dart';
import 'core/lifecycle/app_lifecycle_service.dart';
import 'core/config/cambric_config.dart';
import 'theme/app_theme.dart';
import 'widgets/cambric_first_run_wizard.dart';
import 'cambric_app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load central configuration.
  final config = await CambricConfig.load(
    'lib/core/config/cambric_config.json',
  );

  // Initialize application lifecycle tracking.
  final lifecycle = AppLifecycleService();
  await lifecycle.initialize();

  // Initialize the local Cambric ecosystem service.
  final ecosystem = CambricEcosystemService();
  await ecosystem.ensureIdentity();

  // Register this product in the shared local registry.
  final registry = ProductRegistryService();
  await registry.register({
    'productId': config.productId,
    'name': config.productName,
    'version': config.version,
    'platform': 'flutter',
    'protocolVersion': config.ecosystemProtocolVersion,
    'capabilities': [
      'local-storage',
      'cache',
      'release-discovery',
      'updates',
      'ecosystem',
    ],
    'lastSeen': DateTime.now().toIso8601String(),
  });

  final products = await registry.products();

  runApp(
    CambricTemplateApp(
      config: config,
      existingProducts: products,
    ),
  );
}

class CambricTemplateApp extends StatelessWidget {
  final CambricConfig config;
  final List<Map<String, dynamic>> existingProducts;

  const CambricTemplateApp({
    super.key,
    required this.config,
    required this.existingProducts,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: config.productName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          return CambricAppShell(
            productName: config.productName,
            version: config.version,
            child: Center(
              child: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => CambricFirstRunWizard(
                      existingProducts: existingProducts,
                      onComplete: () => Navigator.of(context).pop(),
                    ),
                  );
                },
                child: const Text('Open Cambric Setup'),
              ),
            ),
          );
        },
      ),
    );
  }
}
