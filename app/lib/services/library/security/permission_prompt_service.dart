import 'package:flutter/material.dart';

/// Displays an in-app rationale dialog before the OS permission request.
///
/// Showing a custom explanation first increases user acceptance rates and
/// gives a chance to abort before the native OS dialog fires (which, on
/// iOS/Android, can only be shown once).
class PermissionPromptService {
  String get name => 'PermissionPromptService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Shows an [AlertDialog] explaining why [title] permission is needed.
  ///
  /// Returns true if the user tapped [allow], false if they tapped [deny] or
  /// dismissed the dialog.
  Future<bool> showPrompt(
    BuildContext context, {
    required String title,
    required String reason,
    String allow = 'Allow',
    String deny = 'Not now',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(deny),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(allow),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
