import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Data/collection_list_data.dart';
import 'package:app_geek_hobby_app/Data/list_data.dart';

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

        ],
      ),
      
    );
  }
}