import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';

class AnimeFranchiseResults extends StatelessWidget {
  final List<AnimeFranchise> franchises;
  final String query;
  final String? sectionTitle;

  const AnimeFranchiseResults({
    super.key,
    required this.franchises,
    this.query = '',
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle ?? 'Anime Franchises - "$query"',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...franchises.map((franchise) => _FranchiseCard(franchise: franchise)),
      ],
    );
  }
}

class _FranchiseCard extends StatelessWidget {
  final AnimeFranchise franchise;

  const _FranchiseCard({required this.franchise});

  @override
  Widget build(BuildContext context) {
    final tint =
        _parseAniListColor(franchise.coverColor) ?? const Color(0xFF1F7A8C);
    final cleanedTitle = _cleanMasterTitle(franchise.title);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimeFranchiseDetailPage(franchise: franchise),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint.withOpacity(0.2), Colors.white],
            ),
          ),
          child: Row(
            children: [
              _HeroImage(url: franchise.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanedTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      franchise.entries.length > 1
                          ? '${franchise.entries.length} entries • ${franchise.totalEpisodes} total eps'
                          : 'Standalone',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

String _cleanMasterTitle(String title) {
  return title
      .replaceAll(
        RegExp(
          r'\b(season|part|cour|arc|chapter)\s*\d+\b',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(r'\b(season|part|cour|arc|chapter)\b', caseSensitive: false),
        '',
      )
      .replaceAll(RegExp(r'\s*[-:|]\s*', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _HeroImage extends StatelessWidget {
  final String? url;

  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 70,
        color: Colors.grey.shade300,
        child: (url != null && url!.isNotEmpty)
            ? Image.network(url!, fit: BoxFit.cover)
            : const Icon(Icons.movie_creation_outlined, color: Colors.grey),
      ),
    );
  }
}

Color? _parseAniListColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}
