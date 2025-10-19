import 'package:app_geek_hobby_app/Classes/Widgets/item_carousel.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Data/list_data.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Pages/search.dart'; // added

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final RawgService _rawgService = RawgService();
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _rawgService.fetchGames();
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 6), // optional spacing in place of the removed search bar
          const SizedBox(height: 14),

          // Movies carousel
          ItemCarousel(
            title: 'Movies',
            items: moviesListTest.items,
            getName: (item) => item.name,
          ),
          const SizedBox(height: 14),

          // Shows carousel
          ItemCarousel(
            title: 'Shows',
            items: showsListTest.items,
            getName: (item) => item.name,
          ),
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

          // Anime carousel
          ItemCarousel(
            title: 'Anime',
            items: animeListTest.items,
            getName: (item) => item.name,
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text('Explore Page Content Here'),
          ),
        ],
      ),
    );
  }
}