import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:flutter/material.dart';

class MovieDisplay extends StatelessWidget {
  final Movie movie;

  const MovieDisplay({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movie details"), // Assuming 'item' has a 'name' property
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 16),
            Text(
              movie.studio,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              movie.yearReleased.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Runtime: ${movie.duration.toString()} minutes",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              movie.owned ? 'Owned' : 'Not Owned',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              movie.wishlist ? 'Wishlisted' : 'Not Wishlisted',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              "User Rating: ${movie.userRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Director: ${movie.director}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "IMDB Rating: ${movie.imdbRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Age Rating: ${movie.ageRating.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Genres: ${movie.genres.map((g) => g.toString().split('.').last).join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            // Add more item details here as needed
          ],
        ),
      ),
    );
  }
}