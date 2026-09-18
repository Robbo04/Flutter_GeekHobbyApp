import 'package:flutter/material.dart';

class OfflineRetryBanner extends StatelessWidget {
  const OfflineRetryBanner({
    super.key,
    required this.isVisible,
    required this.onRetry,
    this.message = 'Connection issue detected. Some content could not be loaded.',
  });

  final bool isVisible;
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: colorScheme.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
