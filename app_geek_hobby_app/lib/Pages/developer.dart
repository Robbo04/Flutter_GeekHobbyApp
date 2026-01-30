import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/clear_anime_groups_button.dart';
import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      appBar: AppBar(
        title: const Text('Developer Tools'),
        backgroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.orange[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[800],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Developer tools for debugging and maintenance',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Anime Groups Section
            _buildSection(
              title: 'Anime Groups',
              icon: Icons.collections_bookmark,
              children: [
                const AnimeGroupStatsWidget(),
                const SizedBox(height: 12),
                const ClearAnimeGroupsButton(),
                const SizedBox(height: 8),
                Text(
                  'Use this if anime appear in multiple groups (e.g., Jujutsu Kaisen split across seasons)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Game Cache Section
            _buildSection(
              title: 'Game Cache',
              icon: Icons.videogame_asset,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    // Show confirmation
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Refresh Game Cache'),
                        content: const Text(
                          'This will refresh all cached game data from RAWG API. '
                          'This may take a few moments.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    // Show loading
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Refreshing cached games...'),
                        ),
                      );

                      await RawgService.instance.refreshAllCachedGames(
                        batchSize: 3,
                        delay: const Duration(milliseconds: 300),
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context); // Close loading

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Game cache refresh complete!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.pop(context); // Close loading

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('❌ Error refreshing cache: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Refresh Game Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Updates game details and images from RAWG API',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // API Request Stats Section
            _buildSection(
              title: 'API Request Tracking',
              icon: Icons.analytics,
              children: [const ApiStatsWidget()],
            ),

            const SizedBox(height: 32),

            // Info footer
            Center(
              child: Text(
                'These tools are for development and debugging purposes',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class ApiStatsWidget extends StatelessWidget {
  const ApiStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final rawgService = RawgService.instance;
    final aniListService = AniListService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // RAWG API Stats Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'RAWG API (Games)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                'Monthly Limit:',
                '${rawgService.monthlyLimit}',
                Colors.grey[700]!,
              ),
              _buildStatRow(
                'This Month Used:',
                '${rawgService.monthlyRequestsMade}',
                rawgService.usagePercentage > 80
                    ? Colors.red[700]!
                    : Colors.grey[700]!,
              ),
              _buildStatRow(
                'Remaining:',
                '${rawgService.monthlyRequestsRemaining}',
                rawgService.monthlyRequestsRemaining < 1000
                    ? Colors.red[700]!
                    : Colors.green[700]!,
                isBold: true,
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: rawgService.usagePercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rawgService.usagePercentage > 80
                        ? Colors.red
                        : rawgService.usagePercentage > 50
                        ? Colors.orange
                        : Colors.green,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${rawgService.usagePercentage.toStringAsFixed(1)}% used',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                'Session Requests:',
                '${rawgService.sessionRequests}',
                Colors.grey[600]!,
              ),
              if (rawgService.lastRequestTime != null)
                _buildStatRow(
                  'Last Request:',
                  _formatTime(rawgService.lastRequestTime!),
                  Colors.grey[600]!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // AniList API Stats Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.collections_bookmark,
                    color: Colors.purple[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AniList API (Anime)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                'Per-Minute Limit:',
                '${aniListService.minuteLimit}',
                Colors.grey[700]!,
              ),
              _buildStatRow(
                'Last Minute:',
                '${aniListService.requestsLastMinute}/${aniListService.minuteLimit}',
                aniListService.requestsLastMinute > 80
                    ? Colors.red[700]!
                    : Colors.green[700]!,
                isBold: true,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                'Today\'s Requests:',
                '${aniListService.todayRequestsMade}',
                Colors.grey[600]!,
              ),
              _buildStatRow(
                'Session Requests:',
                '${aniListService.sessionRequests}',
                Colors.grey[600]!,
              ),
              if (aniListService.lastRequestTime != null)
                _buildStatRow(
                  'Last Request:',
                  _formatTime(aniListService.lastRequestTime!),
                  Colors.grey[600]!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data persists across app restarts. Cache TTL is 3 days to minimize API usage.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
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
