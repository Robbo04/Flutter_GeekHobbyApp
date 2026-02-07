import 'package:flutter/material.dart';

/// Reusable dialog utilities for consistent UX across the app
class DialogHelpers {
  /// Show a confirmation dialog with custom title and content
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Show a loading spinner dialog (non-dismissible)
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Close the currently open dialog
  static void closeDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// Execute an async action with confirmation, loading, and error handling
  static Future<void> executeAsyncAction(
    BuildContext context, {
    required String confirmTitle,
    required String confirmContent,
    required String successMessage,
    required Future<void> Function() action,
    String confirmText = 'Confirm',
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmation(
      context,
      title: confirmTitle,
      content: confirmContent,
      confirmText: confirmText,
    );

    if (!confirmed || !context.mounted) return;

    showLoading(context);

    try {
      await action();

      if (!context.mounted) return;
      closeDialog(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ $successMessage'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      closeDialog(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
