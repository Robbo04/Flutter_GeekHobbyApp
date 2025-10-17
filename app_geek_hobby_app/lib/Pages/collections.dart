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
      ),
      
    );
  }
}