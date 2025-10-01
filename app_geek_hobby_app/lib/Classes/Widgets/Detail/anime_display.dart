import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:flutter/material.dart';

class AnimeDisplay extends StatelessWidget {
  final Anime anime;

  const AnimeDisplay({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anime details"), // Assuming 'item' has a 'name' property
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                anime.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 16),
            Text(
              anime.studio,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              anime.yearReleased.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              anime.isMovie ? 'Movie: ${anime.runtime.toString()} minutes' : 'Series: ${anime.seasons.toString()} seasons, ${anime.episodes.toString()} episodes',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              anime.owned ? 'Owned' : 'Not Owned',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              anime.wishlist ? 'Wishlisted' : 'Not Wishlisted',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              "User Rating: ${anime.userRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Director: ${anime.seasons.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "IMDB Rating: ${anime.userRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            // Add more item details here as needed
          ],
        ),
      ),
    );
  }
}