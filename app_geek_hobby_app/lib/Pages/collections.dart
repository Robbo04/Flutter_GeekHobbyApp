import 'package:app_geek_hobby_app/Pages/collections_content.dart';
import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Data/collection_list_data.dart';
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
        CollectionButton(
          collectionList: gameOwnedCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final ownedIdsBox = Hive.box<int>('games_owned_collection_id');
            final List<int> ownedIds = ownedIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: ownedIds,
                  title: 'Owned Games',
                ),
              ),
            );
          },
        ),
        CollectionButton(
          collectionList: gameWishlistCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final wishlistIdsBox = Hive.box<int>('games_wishlist_collection_id');
            final List<int> wishlistIds = wishlistIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: wishlistIds,
                  title: 'Wishlist Games',
                ),
              ),
            );
          },
        ),
        CollectionButton(
          collectionList: gameBacklogCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final backlogIdsBox = Hive.box<int>('games_backlog_collection_id');
            final List<int> backlogIds = backlogIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: backlogIds,
                  title: 'Backlog Games',
                ),
              ),
            );
          },
        ),
        CollectionButton(
          collectionList: gameCompletedCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final completedIdsBox = Hive.box<int>('games_completed_collection_id');
            final List<int> completedIds = completedIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: completedIds,
                  title: 'Completed Games',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimeTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CollectionButton(
          collectionList: animewishlistCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final wishlistIdsBox = Hive.box<int>('anime_wishlist_collection_id');
            final List<int> wishlistIds = wishlistIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: wishlistIds,
                  title: 'Anime Wishlist',
                ),
              ),
            );
          },
        ),
        CollectionButton(
          collectionList: animeWatchedCollection,
          imageUrl: 'https://via.placeholder.com/150',
          onTap: () {
            final watchedIdsBox = Hive.box<int>('anime_watched_collection_id');
            final List<int> watchedIds = watchedIdsBox.values.toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsContentPage(
                  itemIds: watchedIds,
                  title: 'Anime Watched',
                ),
              ),
            );
          },
        ),
      ],
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