import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CambricTemplateApp());
}

class CambricTemplateApp extends StatelessWidget {
  const CambricTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
