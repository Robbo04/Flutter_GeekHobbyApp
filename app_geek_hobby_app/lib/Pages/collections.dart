import 'package:app_geek_hobby_app/Pages/collections_content.dart';
import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Data/collection_list_data.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/Classes/Widgets/collection_button.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CollectionButton(
            collectionList: collectionListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          CollectionButton(
            collectionList: backlogGamesListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          CollectionButton(
            collectionList: watchedMoviesListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          CollectionButton(
            collectionList: watchedShowsListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          CollectionButton(
            collectionList: watchedAnimeListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          CollectionButton(
            collectionList: completedGamesListTest,
            imageUrl: 'https://via.placeholder.com/150',
          ),
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

        ],
      ),
      
    );
  }
}