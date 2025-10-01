import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:flutter/material.dart';

class ShowDisplay extends StatelessWidget {
  final Show show;

  const ShowDisplay({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Show details"), // Assuming 'item' has a 'name' property
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              show.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              show.studio,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              show.yearReleased.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Seasons: ${show.seasons.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Episodes: ${show.episodes.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              show.owned ? 'Owned' : 'Not Owned',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              show.wishlist ? 'Wishlisted' : 'Not Wishlisted',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              "User Rating: ${show.userRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Runtime: ${show.runtime.toString()} minutes",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Age Rating: ${show.ageRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Genres: ${show.genres.map((g) => g.toString().split('.').last).join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            // Add more item details here as needed
          ],
        ),
      ),
    );
  }
}