import 'package:app_geek_hobby_app/Classes/Widgets/item_carousel.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Data/list_data.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Pages/search.dart'; // added

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final RawgService _rawgService = RawgService.instance;
  final AniListService _aniListService = AniListService.instance;
  late Future<List<Game>> _gamesFuture;
  late Future<List<Game>> _trendingGamesFuture;
  late Future<List<Anime>> _trendingAnimeFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _rawgService.fetchGames();
    _trendingGamesFuture = _rawgService.fetchTrending(minMetacritic: 0, minRatingsCount: 0);
    _trendingAnimeFuture = _aniListService.fetchTrending(perPage: 20);
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
            iconSize: 38.0, // increased size
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.replay),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text('Refreshing cached games...')));
          await RawgService.instance.refreshAllCachedGames(batchSize: 3, delay: Duration(milliseconds: 300));
          messenger.showSnackBar(const SnackBar(content: Text('Refresh complete')));
          setState(() {}); // if needed to rebuild UI
        },
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 6), // optional spacing in place of the removed search bar
          const SizedBox(height: 14),

          
          // Games from RAWG (FutureBuilder)
          FutureBuilder<List<Game>>(
            future: _gamesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No games found.'));
              }
              final games = snapshot.data!;
              return ItemCarousel(
                title: 'Games (RAWG)',
                items: games,
                getName: (item) => (item as Game).name,
              );
            },
          ),
          const SizedBox(height: 14),

          FutureBuilder<List<Game>>(
            future: _trendingGamesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No trending games found.'));
              }
              final trendingGames = snapshot.data!;
              return ItemCarousel(
                title: 'Trending Games',
                items: trendingGames,
                getName: (item) => (item as Game).name,
              );
            },
          ),
          const SizedBox(height: 14),

          // Trending Anime carousel
          FutureBuilder<List<Anime>>(
            future: _trendingAnimeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No trending anime found.'));
              }
              final trendingAnime = snapshot.data!;
              return ItemCarousel(
                title: 'Trending Anime',
                items: trendingAnime,
                getName: (item) => (item as Anime).name,
              );
            },
          ),

          const Center(
            child: Text('\nExplore Page Content Here'),
          ),
        ],
      ),
    );
  }
}