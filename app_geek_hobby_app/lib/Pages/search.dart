import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/item_carousel.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Data/list_data.dart';
import 'package:app_geek_hobby_app/Data/collection_list_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final RawgService _rawgService = RawgService();
  final TextEditingController _controller = TextEditingController();
  Future<List<Game>>? _searchFuture;
  String _lastQuery = '';

  void _doSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _lastQuery = q;
      _searchFuture = _rawgService.fetchGames(search: q);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGamesSection() {
    if (_searchFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Game>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text('No games found for "$_lastQuery".')),
          );
        }

        final games = snapshot.data!;
        return ItemCarousel(
          title: 'Games — results for "$_lastQuery"',
          items: games,
          getName: (item) => (item as Game).name,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search games, movies, shows...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _searchFuture = null;
                    _lastQuery = '';
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onSubmitted: _doSearch,
          ),
          const SizedBox(height: 14),

          // Games results (RAWG)
          _buildGamesSection(),
          const SizedBox(height: 14),
          
          if (_searchFuture == null)
            const Center(child: Text('Enter a search term and press Enter to find games.')),
        ],
      ),
    );
  }
}
