import 'package:flutter/material.dart';

/// The steps of the first-run wizard.
enum _WizardStep {
  welcome,
  language,
  theme,
  permissions,
  ecosystem,
  complete,
}

/// Multi-step first-run setup wizard.
///
/// Only runs once per installation. Persist completion state via
/// [PreferencesService] to prevent re-showing on subsequent launches.
///
/// Steps:
/// ```
/// Welcome → Language → Theme → Permissions → Ecosystem → Complete
/// ```
class CambricFirstRunWizard extends StatefulWidget {
  final List<Map<String, dynamic>> existingProducts;
  final VoidCallback onComplete;

  const CambricFirstRunWizard({
    super.key,
    required this.existingProducts,
    required this.onComplete,
  });

  @override
  State<CambricFirstRunWizard> createState() =>
      _CambricFirstRunWizardState();
}

class _CambricFirstRunWizardState extends State<CambricFirstRunWizard> {
  _WizardStep _step = _WizardStep.welcome;

  String _selectedLanguage = 'en';
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _connectExisting = false;
  bool _shareApprovedData = false;

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ar', 'label': 'العربية'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_stepTitle()),
      content: SizedBox(
        width: 520,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: _stepContent(),
          ),
        ),
      ),
      actions: _actions(),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case _WizardStep.welcome:
        return 'Welcome';
      case _WizardStep.language:
        return 'Language';
      case _WizardStep.theme:
        return 'Appearance';
      case _WizardStep.permissions:
        return 'Permissions';
      case _WizardStep.ecosystem:
        return 'Cambric products';
      case _WizardStep.complete:
        return 'Ready';
    }
  }

  Widget _stepContent() {
    switch (_step) {
      case _WizardStep.welcome:
        return _WelcomeStep();
      case _WizardStep.language:
        return _LanguageStep(
          languages: _languages,
          selected: _selectedLanguage,
          onSelected: (code) => setState(() => _selectedLanguage = code),
        );
      case _WizardStep.theme:
        return _ThemeStep(
          selected: _selectedTheme,
          onSelected: (mode) => setState(() => _selectedTheme = mode),
        );
      case _WizardStep.permissions:
        return const _PermissionsStep();
      case _WizardStep.ecosystem:
        return _EcosystemStep(
          existingProducts: widget.existingProducts,
          connectExisting: _connectExisting,
          shareApprovedData: _shareApprovedData,
          onConnectChanged: (v) =>
              setState(() => _connectExisting = v ?? false),
          onShareChanged: (v) =>
              setState(() => _shareApprovedData = v),
        );
      case _WizardStep.complete:
        return const _CompleteStep();
    }
  }

  List<Widget> _actions() {
    final isFirst = _step == _WizardStep.welcome;
    final isLast = _step == _WizardStep.complete;
    return [
      if (!isFirst)
        TextButton(
          onPressed: _previous,
          child: const Text('Back'),
        ),
      FilledButton(
        onPressed: isLast ? widget.onComplete : _next,
        child: Text(isLast ? 'Get started' : 'Continue'),
      ),
    ];
  }

  void _next() {
    const steps = _WizardStep.values;
    final index = steps.indexOf(_step);
    if (index < steps.length - 1) {
      setState(() => _step = steps[index + 1]);
    }
  }

  void _previous() {
    const steps = _WizardStep.values;
    final index = steps.indexOf(_step);
    if (index > 0) {
      setState(() => _step = steps[index - 1]);
    }
  }
}

// ── Step widgets ──────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'This wizard will prepare your application, initialize local storage, '
      'and configure optional settings.\n\n'
      'Your data stays on this device unless you choose to share it.',
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final List<Map<String, String>> languages;
  final String selected;
  final void Function(String) onSelected;

  const _LanguageStep({
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final lang in languages)
          ListTile(
            leading: Radio<String>(
              value: lang['code']!,
              // ignore: deprecated_member_use
              groupValue: selected,
              // ignore: deprecated_member_use
              onChanged: (v) { if (v != null) onSelected(v); },
            ),
            title: Text(lang['label']!),
            onTap: () => onSelected(lang['code']!),
          ),
      ],
    );
  }
}

class _ThemeStep extends StatelessWidget {
  final ThemeMode selected;
  final void Function(ThemeMode) onSelected;

  const _ThemeStep({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tile(ThemeMode.system, Icons.brightness_auto_outlined,
            'System default', 'Follows your device setting'),
        _tile(ThemeMode.light, Icons.light_mode_outlined,
            'Light', 'Always use light appearance'),
        _tile(ThemeMode.dark, Icons.dark_mode_outlined,
            'Dark', 'Always use dark appearance'),
      ],
    );
  }

  Widget _tile(
      ThemeMode mode, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Radio<ThemeMode>(
        value: mode,
        // ignore: deprecated_member_use
        groupValue: selected,
        // ignore: deprecated_member_use
        onChanged: (v) { if (v != null) onSelected(v); },
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(icon),
      onTap: () => onSelected(mode),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This application uses:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        _PermRow(
          icon: Icons.folder_outlined,
          label: 'Local storage',
          detail: 'Saves application data to your device',
        ),
        SizedBox(height: 8),
        _PermRow(
          icon: Icons.cloud_off_outlined,
          label: 'Works offline',
          detail: 'No remote server required',
        ),
        SizedBox(height: 8),
        _PermRow(
          icon: Icons.network_check_outlined,
          label: 'Optional network access',
          detail: 'Used only for release checks and downloads',
        ),
      ],
    );
  }
}

class _PermRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;

  const _PermRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(detail,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _EcosystemStep extends StatelessWidget {
  final List<Map<String, dynamic>> existingProducts;
  final bool connectExisting;
  final bool shareApprovedData;
  final void Function(bool?) onConnectChanged;
  final void Function(bool) onShareChanged;

  const _EcosystemStep({
    required this.existingProducts,
    required this.connectExisting,
    required this.shareApprovedData,
    required this.onConnectChanged,
    required this.onShareChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (existingProducts.isEmpty)
          const Text(
            'This appears to be the first Cambric application on this device.',
          )
        else ...[
          const Text('Existing Cambric applications detected:'),
          const SizedBox(height: 8),
          for (final product in existingProducts)
            CheckboxListTile(
              value: connectExisting,
              onChanged: onConnectChanged,
              title: Text(
                product['name']?.toString() ??
                    product['productId']?.toString() ??
                    'Cambric Product',
              ),
              dense: true,
            ),
        ],
        const SizedBox(height: 12),
        SwitchListTile(
          value: shareApprovedData,
          onChanged: onShareChanged,
          title: const Text('Allow approved shared-data connections'),
          subtitle: const Text(
            'Sharing requires explicit permission per connection',
          ),
          dense: true,
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        const Text(
          'Setup complete. Your application is ready to use.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
