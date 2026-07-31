import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';

/// Standardized empty state display widget with consistent styling across the app
/// 
/// Usage examples:
/// - Default centered: `EmptyStateWidget(message: 'No items found')`
/// - With action: `EmptyStateWidget.withAction(message: 'No results', actionLabel: 'Retry', onAction: _retry)`
/// - Inline: `EmptyStateWidget.inline(message: 'No games available')`
/// - Custom icon: `EmptyStateWidget(message: 'No favorites', icon: Icons.favorite_border)`
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final bool centered;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.onAction,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.iconSize = 64,
    this.centered = true,
    this.padding = AppSpacing.paddingAll16,
    this.textAlign = TextAlign.center,
  });

  /// Centered empty state with icon and action button
  const EmptyStateWidget.withAction({
    super.key,
    required this.message,
    this.subtitle,
    required this.onAction,
    required this.actionLabel,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.iconSize = 64,
    this.padding = AppSpacing.paddingAll16,
  })  : centered = true,
        textAlign = TextAlign.center;

  /// Inline empty state without extra spacing (for lists/carousels)
  const EmptyStateWidget.inline({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.iconSize = 24,
  })  : subtitle = null,
        onAction = null,
        actionLabel = null,
        centered = false,
        padding = AppSpacing.paddingAll8,
        textAlign = TextAlign.center;

  /// Simple text-only empty message
  const EmptyStateWidget.simple({
    super.key,
    required this.message,
    this.textAlign = TextAlign.center,
  })  : subtitle = null,
        icon = Icons.inbox_outlined,
      iconColor = null,
        iconSize = 0,
        onAction = null,
        actionLabel = null,
        centered = false,
        padding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (iconSize > 0) ...[
            Icon(icon, size: iconSize, color: resolvedIconColor),
            AppSpacing.verticalLg,
          ],
          Text(
            message,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: iconSize > 40 ? 16 : 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.verticalSm,
            Text(
              subtitle!,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            AppSpacing.verticalLg,
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    return centered ? Center(child: content) : content;
  }
}
