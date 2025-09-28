import 'package:app_geek_hobby_app/Classes/Widgets/item_carousel.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Data/list_data.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ItemCarousel(
            title: 'Movies',
            items: moviesListTest.items,
            getName: (item) => item.name,
          ),
          const SizedBox(height: 10),
          ItemCarousel(
            title: 'Shows',
            items: showsListTest.items,
            getName: (item) => item.name,
          ),
          const SizedBox(height: 10),
          ItemCarousel(
            title: 'Games',
            items: gameListsTest.items,
            getName: (item) => item.name,
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text('Explore Page Content Here'),
          ),
        ],
      ),
    );
  }
}