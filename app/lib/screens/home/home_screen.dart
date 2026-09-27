import 'package:flutter/material.dart';

import '../cache/cache_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambric App'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Template application',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Replace this product layer with the application you are building.',
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CacheScreen(),
                ),
              );
            },
            child: const Text('Cache management'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
