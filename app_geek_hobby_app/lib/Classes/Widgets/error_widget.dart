import 'package:flutter/material.dart';

/// Standardized error display widget with consistent styling across the app
/// 
/// Usage examples:
/// - Default centered: `ErrorWidget(message: 'Failed to load data')`
/// - With retry: `ErrorWidget.withRetry(message: 'Network error', onRetry: _loadData)`
/// - Inline: `ErrorWidget.inline(message: 'Error: ${error.toString()}')`
/// - Simple text: `ErrorWidget.simple(message: 'No results found')`
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final bool centered;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 64,
    this.centered = true,
    this.padding = const EdgeInsets.all(16),
    this.textAlign = TextAlign.center,
  });

  /// Centered error with icon and optional retry button
  const AppErrorWidget.withRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 64,
    this.padding = const EdgeInsets.all(16),
  })  : centered = true,
        textAlign = TextAlign.center;

  /// Inline error without extra spacing (for FutureBuilder errors)
  const AppErrorWidget.inline({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 24,
  })  : onRetry = null,
        centered = false,
        padding = const EdgeInsets.all(8),
        textAlign = TextAlign.center;

  /// Simple text-only error message
  const AppErrorWidget.simple({
    super.key,
    required this.message,
    this.textAlign = TextAlign.center,
  })  : icon = Icons.error_outline,
        iconColor = Colors.red,
        iconSize = 0,
        onRetry = null,
        centered = false,
        padding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (iconSize > 0) ...[
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: iconSize > 40 ? 16 : 14,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );

    return centered ? Center(child: content) : content;
  }
}
