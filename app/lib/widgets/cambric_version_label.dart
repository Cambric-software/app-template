import 'package:flutter/material.dart';

/// Displays the application version in the bottom-right corner.
class CambricVersionLabel extends StatelessWidget {
  final String version;

  const CambricVersionLabel({
    super.key,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        version.startsWith('v') ? version : 'v$version',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
        semanticsLabel: 'Version $version',
      ),
    );
  }
}
