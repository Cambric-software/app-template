import 'package:flutter/material.dart';
import '../../widgets/state_widgets.dart';

/// Developer-only component showcase.
/// Remove or gate behind a feature flag before shipping.
class ComponentDemoScreen extends StatelessWidget {
  const ComponentDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, 'Buttons', _buttons(context)),
          _section(context, 'States', _states(context)),
          _section(context, 'Typography', _typography(context)),
          _section(context, 'Cards', _cards(context)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary)),
        ),
        content,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      FilledButton(onPressed: () {}, child: const Text('Filled')),
      FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
      OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
      TextButton(onPressed: () {}, child: const Text('Text')),
      const FilledButton(onPressed: null, child: Text('Disabled')),
    ]);
  }

  Widget _states(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 80, child: LoadingWidget(message: 'Loading...')),
      const SizedBox(height: 8),
      EmptyStateWidget(icon: Icons.inbox_outlined, title: 'Nothing here', subtitle: 'Add something to get started',
          actionLabel: 'Add', onAction: () {}),
    ]);
  }

  Widget _typography(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Display Large', style: tt.displayLarge),
      Text('Headline Medium', style: tt.headlineMedium),
      Text('Title Large', style: tt.titleLarge),
      Text('Body Large', style: tt.bodyLarge),
      Text('Body Medium', style: tt.bodyMedium),
      Text('Label Small', style: tt.labelSmall),
    ]);
  }

  Widget _cards(BuildContext context) {
    return Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16),
          child: Row(children: [Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12), const Expanded(child: Text('This is a standard card.'))]))),
      const SizedBox(height: 8),
      Card(color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(padding: const EdgeInsets.all(16),
              child: Row(children: [Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12), const Expanded(child: Text('Error card example.'))]))),
    ]);
  }
}
