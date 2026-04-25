import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/clear_anime_groups_button.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/api_stats_card.dart';
import 'package:app_geek_hobby_app/Utils/dialog_helpers.dart';
import 'package:app_geek_hobby_app/Constants/app_spacing.dart';
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
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.orange[100],
              child: Padding(
                padding: AppSpacing.paddingAll16,
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[800],
                    ),
                    AppSpacing.horizontalMd,
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
            AppSpacing.verticalXl,

            // Anime Groups Section
            _buildSection(
              title: 'Anime Groups',
              icon: Icons.collections_bookmark,
              children: [
                const AnimeGroupStatsWidget(),
                AppSpacing.verticalMd,
                const ClearAnimeGroupsButton(),
                AppSpacing.verticalSm,
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

            AppSpacing.verticalLg,

            // Anime Cache Section
            _buildSection(
              title: 'Search Cache',
              icon: Icons.search,
              children: [
                ElevatedButton.icon(
                  onPressed: () => DialogHelpers.executeAsyncAction(
                    context,
                    confirmTitle: 'Clear All Search Cache',
                    confirmContent:
                        'This will clear all cached search results for both games and anime. '
                        'New searches will fetch fresh data from RAWG and AniList APIs. '
                        'This is useful after updating search algorithms.',
                    confirmText: 'Clear Cache',
                    successMessage: 'All search cache cleared!',
                    action: () async {
                      await AniListService.instance.clearSearchCache();
                      await RawgService.instance.clearSearchCache();
                    },
                  ),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Search Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  'Clears cached search results for both games and anime. Use this if search results seem outdated or incorrect.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalLg,

            // Game Cache Section
            _buildSection(
              title: 'Game Cache',
              icon: Icons.videogame_asset,
              children: [
                ElevatedButton.icon(
                  onPressed: () => DialogHelpers.executeAsyncAction(
                    context,
                    confirmTitle: 'Refresh Game Cache',
                    confirmContent:
                        'This will refresh all cached game data from RAWG API. '
                        'This may take a few moments.',
                    confirmText: 'Refresh',
                    successMessage: 'Game cache refresh complete!',
                    action: () => RawgService.instance.refreshAllCachedGames(
                      batchSize: 3,
                      delay: const Duration(milliseconds: 300),
                    ),
                  ),
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

            AppSpacing.verticalLg,

            // Anime Cache Section
            _buildSection(
              title: 'Anime Cache',
              icon: Icons.movie,
              children: [
                ElevatedButton.icon(
                  onPressed: () => DialogHelpers.executeAsyncAction(
                    context,
                    confirmTitle: 'Clear Anime Cache',
                    confirmContent:
                        'This will clear all cached anime data. Your collection flags '
                        '(watched/wishlist) and ratings will be preserved, but anime '
                        'details will be refetched with updated episode counts.',
                    confirmText: 'Clear Cache',
                    successMessage: 'Anime cache cleared!',
                    action: () async {
                      await AniListService.instance.clearAnimeCache();
                    },
                  ),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Anime Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use this to refresh anime episode counts for ongoing series',
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
        ApiStatsCard(
          title: 'RAWG API (Games)',
          icon: Icons.videogame_asset,
          themeColor: Colors.blue[700]!,
          stats: [
            StatRow('Monthly Limit:', '${rawgService.monthlyLimit}'),
            StatRow(
              'This Month Used:',
              '${rawgService.monthlyRequestsMade}',
              valueColor: rawgService.usagePercentage > 80
                  ? Colors.red[700]
                  : Colors.grey[700],
            ),
            StatRow(
              'Remaining:',
              '${rawgService.monthlyRequestsRemaining}',
              valueColor: rawgService.monthlyRequestsRemaining < 1000
                  ? Colors.red[700]
                  : Colors.green[700],
              isBold: true,
            ),
          ],
          extraWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              ...[
                StatRow(
                  'Session Requests:',
                  '${rawgService.sessionRequests}',
                  valueColor: Colors.grey[600],
                ),
                if (rawgService.lastRequestTime != null)
                  StatRow(
                    'Last Request:',
                    TimeFormatter.formatTimeAgo(rawgService.lastRequestTime!),
                    valueColor: Colors.grey[600],
                  ),
              ].map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.label,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          s.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: s.isBold ? FontWeight.bold : FontWeight.w600,
                            color: s.valueColor ?? Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // AniList API Stats Card
        ApiStatsCard(
          title: 'AniList API (Anime)',
          icon: Icons.collections_bookmark,
          themeColor: Colors.purple[700]!,
          stats: [
            StatRow('Per-Minute Limit:', '${aniListService.minuteLimit}'),
            StatRow(
              'Last Minute:',
              '${aniListService.requestsLastMinute}/${aniListService.minuteLimit}',
              valueColor: aniListService.requestsLastMinute > 80
                  ? Colors.red[700]
                  : Colors.green[700],
              isBold: true,
            ),
            StatRow(
              "Today's Requests:",
              '${aniListService.todayRequestsMade}',
              valueColor: Colors.grey[600],
            ),
            StatRow(
              'Session Requests:',
              '${aniListService.sessionRequests}',
              valueColor: Colors.grey[600],
            ),
            if (aniListService.lastRequestTime != null)
              StatRow(
                'Last Request:',
                TimeFormatter.formatTimeAgo(aniListService.lastRequestTime!),
                valueColor: Colors.grey[600],
              ),
          ],
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
}
