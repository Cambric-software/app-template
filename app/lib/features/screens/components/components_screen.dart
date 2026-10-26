import 'package:flutter/material.dart';

import 'package:cambric_design/cambric_design.dart';

/// The living component gallery.
///
/// A new product copies from this page rather than from memory: every component
/// the design system exposes is rendered here in the current theme.
class ComponentsScreen extends StatelessWidget {
  /// Create the gallery.
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DsPage(
      title: 'Components',
      actions: <Widget>[
        DsStatusPill(
          label: theme.brightness == Brightness.dark ? 'Dark' : 'Light',
          color: theme.colorScheme.primary,
          icon: theme.brightness == Brightness.dark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DsCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.widgets_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    'These are the real widgets from lib/widgets/ds_widgets.dart, '
                    'rendered in the active theme. Change the theme in Settings to '
                    'check both designs.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Cards and metrics',
            subtitle: 'The default grouping devices.',
            child: DsGrid(
              children: <Widget>[
                DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const DsLabel('DsCard'),
                      const SizedBox(height: Space.sm),
                      Text('A plain panel', style: theme.textTheme.titleSmall),
                      const SizedBox(height: Space.xs),
                      Text(
                        'Hairline border, radius 14, no shadow.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DsMetricTile(
                  label: 'Example metric',
                  value: '42',
                  unit: 'ms',
                  accent: theme.colorScheme.primary,
                  icon: Icons.speed_outlined,
                  status: HealthStatus.normal,
                ),
                const DsMetricTile(
                  label: 'Example metric',
                  value: '1.2',
                  unit: 'GB',
                  accent: AppColors.accent,
                  icon: Icons.storage_outlined,
                  status: HealthStatus.normal,
                ),
                const DsInfoCard(
                  title: 'DsInfoCard',
                  subtitle: 'Icon, title, optional badge and detail bullets',
                  icon: Icons.info_outline,
                  badge: 'Example',
                  badgeStatus: DsStatus.info,
                  details: <String>[
                    'The header stacks when the card is narrower than 420dp.',
                    'The pill is a status, not decoration: icon and word too.',
                    'Use it for capabilities or settings summaries.',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Status',
            subtitle: 'Colour is never the only signal.',
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                for (final status in DsStatus.values)
                  DsStatusPill(
                    label: status.label,
                    color: dsStatusColor(status, context),
                    icon: status.icon,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          const DsSection(
            title: 'Segmented control',
            subtitle: 'DsSegmented<T> scrolls rather than clipping.',
            child: _SegmentedDemo(),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Buttons',
            subtitle: 'Filled, tonal, outlined, text and disabled.',
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Tonal'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
                const FilledButton(
                  onPressed: null,
                  child: Text('Disabled'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          const DsSection(
            title: 'Inputs',
            subtitle: 'The same radii and border colours as the rest of the UI.',
            child: _InputDemo(),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Empty state',
            subtitle: 'Says what is missing and what would fill it.',
            child: DsCard(
              padding: EdgeInsets.zero,
              child: DsEmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing here yet',
                message:
                    'An empty screen without an explanation reads as broken. '
                    'Show the action that would fill it.',
                action: FilledButton(
                  onPressed: () {},
                  child: const Text('Example action'),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Type scale',
            subtitle: 'Named by role in design_tokens.dart.',
            child: DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Display', style: theme.textTheme.displaySmall),
                  const SizedBox(height: Space.sm),
                  Text('Title', style: theme.textTheme.titleLarge),
                  const SizedBox(height: Space.sm),
                  Text(
                    'Body: the quick brown fox jumps over the lazy dog.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Space.sm),
                  Text('Caption', style: theme.textTheme.bodySmall),
                  const SizedBox(height: Space.md),
                  const DsLabel('Overline label'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo();

  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  String _value = 'week';

  @override
  Widget build(BuildContext context) {
    return DsSegmented<String>(
      value: _value,
      options: const <DsSegment<String>>[
        DsSegment<String>(value: 'day', label: 'Day', icon: Icons.today_outlined),
        DsSegment<String>(value: 'week', label: 'Week', icon: Icons.date_range_outlined),
        DsSegment<String>(value: 'month', label: 'Month', icon: Icons.calendar_month_outlined),
        DsSegment<String>(value: 'all', label: 'All time', icon: Icons.all_inclusive),
      ],
      onChanged: (value) => setState(() => _value = value),
    );
  }
}

class _InputDemo extends StatefulWidget {
  const _InputDemo();

  @override
  State<_InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<_InputDemo> {
  bool _notifications = true;
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Project name',
              hintText: 'My Cambric app',
              helperText: 'Validation is supplied by InputSanitizationService.',
              helperStyle: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: Space.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notifications'),
            subtitle: const Text('A standard switch, themed centrally.'),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Remember this choice'),
            value: _remember,
            onChanged: (value) => setState(() => _remember = value ?? false),
          ),
        ],
      ),
    );
  }
}
