import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Utils/dialog_helpers.dart';
import 'package:flutter/material.dart';

/// Debug utility to clear anime groups
/// Add this button to your settings page or debug menu
class ClearAnimeGroupsButton extends StatelessWidget {
  const ClearAnimeGroupsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => DialogHelpers.executeAsyncAction(
        context,
        confirmTitle: 'Clear Anime Groups',
        confirmContent:
            'This will clear all anime group data. Groups will be rebuilt '
            'automatically the next time you search.\n\n'
            'Use this if you notice anime split into multiple groups.',
        confirmText: 'Clear Groups',
        successMessage: 'Anime groups cleared! They will rebuild on next search.',
        action: () => AniListService.instance.clearAllGroups(),
      ),
      icon: const Icon(Icons.refresh),
      label: const Text('Clear Anime Groups'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Show group statistics
class AnimeGroupStatsWidget extends StatelessWidget {
  const AnimeGroupStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AniListService.instance;
    
    return FutureBuilder(
      future: _getStats(service),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final stats = snapshot.data as Map<String, int>;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anime Group Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Total Groups: ${stats['groups']}'),
                Text('Grouped Anime: ${stats['groupedAnime']}'),
                Text('Cached Anime: ${stats['cachedAnime']}'),
                const SizedBox(height: 8),
                Text(
                  'Coverage: ${stats['groups'] == 0 ? '0' : ((stats['groupedAnime']! / stats['cachedAnime']!) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _getStats(AniListService service) async {
    return {
      'groups': service.totalGroups,
      'groupedAnime': service.totalGroupedAnime,
      'cachedAnime': service.totalCachedAnime,
    };
  }
}
