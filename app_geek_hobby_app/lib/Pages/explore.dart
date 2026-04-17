import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Classes/Widgets/empty_state_widget.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/error_widget.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/item_carousel.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/loading_widget.dart';
import 'package:app_geek_hobby_app/Data/curated_lists.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Pages/search.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final RawgService _rawgService = RawgService.instance;
  final AniListService _aniListService = AniListService.instance;

  // Helper method to fetch games based on carousel category
  Future<List<Game>> _fetchGameCarousel(CarouselCategory category) {
    switch (category.type) {
      case CarouselType.trending:
        return _rawgService.fetchTrending(minMetacritic: 0, minRatingsCount: 0);
      case CarouselType.comingSoon:
        return _rawgService.fetchComingSoon();
      case CarouselType.mostPlayed:
        return _rawgService.fetchMostPlayed();
      case CarouselType.genre:
        return _rawgService.fetchByGenre(genre: category.value!);
      case CarouselType.tag:
        return _rawgService.fetchByTag(tag: category.value!);
      default:
        return _rawgService.fetchGames();
    }
  }

  // Helper method to fetch anime based on carousel category
  Future<List<Anime>> _fetchAnimeCarousel(CarouselCategory category) {
    switch (category.type) {
      case CarouselType.trending:
        return _aniListService.fetchTrending(perPage: 20);
      case CarouselType.comingSoon:
        return _aniListService.fetchComingSoon(perPage: 20);
      case CarouselType.mostPlayed:
        return _aniListService.fetchMostPopular(perPage: 20);
      case CarouselType.genre:
        return _aniListService.fetchByGenre(genre: category.value!, perPage: 20);
      default:
        return _aniListService.searchAnime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 38.0,
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 6),
          const SizedBox(height: 14),

          // Dynamically generate game carousels
          ...ExploreCarousels.gameCarousels.map((category) {
            return Column(
              children: [
                FutureBuilder<List<Game>>(
                  future: _fetchGameCarousel(category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget();
                    } else if (snapshot.hasError) {
                      return AppErrorWidget.inline(message: 'Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return EmptyStateWidget.simple(message: 'No ${category.title.toLowerCase()} found.');
                    }
                    final games = snapshot.data!;
                    return ItemCarousel(
                      title: category.title,
                      items: games,
                      getName: (item) => (item as Game).name,
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],
            );
          }),

          // Dynamically generate anime carousels
          ...ExploreCarousels.animeCarousels.map((category) {
            return Column(
              children: [
                FutureBuilder<List<Anime>>(
                  future: _fetchAnimeCarousel(category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget();
                    } else if (snapshot.hasError) {
                      return AppErrorWidget.inline(message: 'Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return EmptyStateWidget.simple(message: 'No ${category.title.toLowerCase()} found.');
                    }
                    final anime = snapshot.data!;
                    return ItemCarousel(
                      title: category.title,
                      items: anime,
                      getName: (item) => (item as Anime).name,
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],
            );
          }),
        ],
      ),
    );
  }
}
