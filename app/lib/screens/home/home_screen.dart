import 'package:flutter/material.dart';
import '../cache/cache_screen.dart';
import '../settings/settings_screen.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/state_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveLayout.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambric App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: isWide ? _wideLayout(context) : _narrowLayout(context),
    );
  }

  Widget _narrowLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: _cards(context),
    );
  }

  Widget _wideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView(padding: const EdgeInsets.all(20), children: _cards(context)),
        ),
        const VerticalDivider(width: 1),
        const Expanded(
          flex: 3,
          child: Center(
            child: EmptyStateWidget(
              icon: Icons.widgets_outlined,
              title: 'Select an action',
              subtitle: 'Choose an item from the list on the left.',
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _cards(BuildContext context) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _navCard(context, icon: Icons.storage_outlined, title: 'Cache', subtitle: 'View and clear cached data',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CacheScreen()))),
      const SizedBox(height: 8),
      _navCard(context, icon: Icons.monitor_heart_outlined, title: 'Diagnostics', subtitle: 'System information and platform details',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagnosticsScreen()))),
      const SizedBox(height: 8),
      _navCard(context, icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Application configuration',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ];
  }

  Widget _heroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.layers_outlined, size: 32, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 12),
            Text('Cambric App Template', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text('Replace this product layer with your application.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }

  Widget _navCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
