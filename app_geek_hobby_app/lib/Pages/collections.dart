import 'package:app_geek_hobby_app/Pages/collections_content.dart';
import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Data/collection_list_data.dart';
import 'package:app_geek_hobby_app/Classes/itemlist.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/Classes/Widgets/collection_button.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Collections'),
          backgroundColor: const Color.fromARGB(255, 219, 167, 227),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.videogame_asset), text: 'Games'),
              Tab(icon: Icon(Icons.animation), text: 'Anime'),
              Tab(icon: Icon(Icons.movie), text: 'Movies'),
              Tab(icon: Icon(Icons.tv), text: 'TV'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGamesTab(context),
            _buildAnimeTab(context),
            _buildMoviesTab(context),
            _buildTVTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCollectionButton(
          context,
          gameOwnedCollection,
          'games_owned_collection_id',
          'Owned Games',
        ),
        _buildCollectionButton(
          context,
          gameWishlistCollection,
          'games_wishlist_collection_id',
          'Wishlist Games',
        ),
        _buildCollectionButton(
          context,
          gameBacklogCollection,
          'games_backlog_collection_id',
          'Backlog Games',
        ),
        _buildCollectionButton(
          context,
          gameCompletedCollection,
          'games_completed_collection_id',
          'Completed Games',
        ),
      ],
    );
  }

  Widget _buildAnimeTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCollectionButton(
          context,
          animewishlistCollection,
          'anime_wishlist_collection_id',
          'Anime Wishlist',
        ),
        _buildCollectionButton(
          context,
          animeWatchedCollection,
          'anime_watched_collection_id',
          'Anime Watched',
        ),
      ],
    );
  }

  /// Helper method to build a collection button with navigation
  Widget _buildCollectionButton(
    BuildContext context,
    ItemList collectionList,
    String hiveBoxName,
    String title,
  ) {
    return CollectionButton(
      collectionList: collectionList,
      imageUrl: 'https://via.placeholder.com/150',
      onTap: () {
        final box = Hive.box<int>(hiveBoxName);
        final ids = box.values.toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionsContentPage(
              itemIds: ids,
              title: title,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoviesTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.movie, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Movie Collections',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTVTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.tv, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'TV Show Collections',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}