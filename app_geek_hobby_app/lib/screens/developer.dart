import 'package:app_geek_hobby_app/services/rawg_service.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/widgets/common/clear_anime_groups_button.dart';
import 'package:app_geek_hobby_app/widgets/cards/api_stats_card.dart';
import 'package:app_geek_hobby_app/core/themes/app_semantic_colors.dart';
import 'package:app_geek_hobby_app/core/utils/dialog_helpers.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAll16Responsive(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: AppSpacing.paddingAll16,
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: Text(
                        'Developer tools for debugging and maintenance',
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
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
              context: context,
              title: 'Anime Groups',
              icon: Icons.collections_bookmark,
              children: [
                const AnimeGroupStatsWidget(),
                AppSpacing.verticalMd,
                const ClearAnimeGroupsButton(),
                AppSpacing.verticalSmResponsive(context),
                Text(
                  'Use this if anime appear in multiple groups (e.g., Jujutsu Kaisen split across seasons)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalLg,

            // Anime Cache Section
            _buildSection(
              context: context,
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                AppSpacing.verticalSmResponsive(context),
                Text(
                  'Clears cached search results for both games and anime. Use this if search results seem outdated or incorrect.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalLgResponsive(context),

            // Game Cache Section
            _buildSection(
              context: context,
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
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  'Updates game details and images from RAWG API',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalLg,

            // Anime Cache Section
            _buildSection(
              context: context,
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
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  'Use this to refresh anime episode counts for ongoing series',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalLg,

            // API Request Stats Section
            _buildSection(
              context: context,
              title: 'API Request Tracking',
              icon: Icons.analytics,
              children: [const ApiStatsWidget()],
            ),

            AppSpacing.verticalXxlResponsive(context),

            // Info footer
            Center(
              child: Text(
                'These tools are for development and debugging purposes',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: AppSpacing.paddingAll16Responsive(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              AppSpacing.horizontalSmResponsive(context),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          AppSpacing.verticalLgResponsive(context),
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
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final rawgService = RawgService.instance;
    final aniListService = AniListService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // RAWG API Stats Card
        ApiStatsCard(
          title: 'RAWG API (Games)',
          icon: Icons.videogame_asset,
          themeColor: colorScheme.primary,
          stats: [
            StatRow('Monthly Limit:', '${rawgService.monthlyLimit}'),
            StatRow(
              'This Month Used:',
              '${rawgService.monthlyRequestsMade}',
              valueColor: rawgService.usagePercentage > 80
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
            StatRow(
              'Remaining:',
              '${rawgService.monthlyRequestsRemaining}',
              valueColor: rawgService.monthlyRequestsRemaining < 1000
                  ? colorScheme.error
                  : semantic.success,
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rawgService.usagePercentage > 80
                        ? colorScheme.error
                        : rawgService.usagePercentage > 50
                            ? semantic.warning
                            : semantic.success,
                  ),
                  minHeight: 12,
                ),
              ),
              AppSpacing.verticalXsResponsive(context),
              Text(
                '${rawgService.usagePercentage.toStringAsFixed(1)}% used',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.verticalMdResponsive(context),
              ...[
                StatRow(
                  'Session Requests:',
                  '${rawgService.sessionRequests}',
                  valueColor: colorScheme.onSurfaceVariant,
                ),
                if (rawgService.lastRequestTime != null)
                  StatRow(
                    'Last Request:',
                    TimeFormatter.formatTimeAgo(rawgService.lastRequestTime!),
                    valueColor: colorScheme.onSurfaceVariant,
                  ),
              ].map((s) => Padding(
                    padding: AppSpacing.paddingV4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          s.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: s.isBold ? FontWeight.bold : FontWeight.w600,
                            color: s.valueColor ?? colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        AppSpacing.verticalLgResponsive(context),
        // AniList API Stats Card
        ApiStatsCard(
          title: 'AniList API (Anime)',
          icon: Icons.collections_bookmark,
          themeColor: colorScheme.secondary,
          stats: [
            StatRow('Per-Minute Limit:', '${aniListService.minuteLimit}'),
            StatRow(
              'Last Minute:',
              '${aniListService.requestsLastMinute}/${aniListService.minuteLimit}',
              valueColor: aniListService.requestsLastMinute > 80
                  ? colorScheme.error
                  : semantic.success,
              isBold: true,
            ),
            StatRow(
              "Today's Requests:",
              '${aniListService.todayRequestsMade}',
              valueColor: colorScheme.onSurfaceVariant,
            ),
            StatRow(
              'Session Requests:',
              '${aniListService.sessionRequests}',
              valueColor: colorScheme.onSurfaceVariant,
            ),
            if (aniListService.lastRequestTime != null)
              StatRow(
                'Last Request:',
                TimeFormatter.formatTimeAgo(aniListService.lastRequestTime!),
                valueColor: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
        AppSpacing.verticalLgResponsive(context),
        Container(
          padding: AppSpacing.paddingAll12Responsive(context),
          decoration: BoxDecoration(
            color: semantic.info,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: semantic.onInfo,
                size: 20,
              ),
              AppSpacing.horizontalSmResponsive(context),
              Expanded(
                child: Text(
                  'Data persists across app restarts. Cache TTL is 3 days to minimize API usage.',
                  style: TextStyle(
                    fontSize: 12,
                    color: semantic.onInfo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
