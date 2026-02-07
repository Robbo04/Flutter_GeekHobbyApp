import 'package:flutter/material.dart';

/// Data model for a stat row
class StatRow {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const StatRow(
    this.label,
    this.value, {
    this.valueColor,
    this.isBold = false,
  });
}

/// Reusable card widget for displaying API statistics
class ApiStatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color themeColor;
  final List<StatRow> stats;
  final Widget? extraWidget;

  const ApiStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.stats,
    this.extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...stats.map(_buildStatRow),
          if (extraWidget != null) ...[
            const SizedBox(height: 12),
            extraWidget!,
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(icon, color: themeColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(StatRow stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stat.label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: stat.isBold ? FontWeight.bold : FontWeight.w600,
              color: stat.valueColor ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility for formatting time differences
class TimeFormatter {
  static String formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
