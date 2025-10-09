import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';

class GameDisplay extends StatelessWidget {
  final Game game;

  const GameDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Game details",
      imageUrl: game.imageUrl,
      details: [
        Text(game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(game.studio, style: const TextStyle(fontSize: 16)),
        Text(game.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text(game.owned ? 'Owned' : 'Not Owned', style: const TextStyle(fontSize: 16, color: Colors.green)),
        Text(game.wishlist ? 'Wishlisted' : 'Not Wishlisted', style: const TextStyle(fontSize: 16, color: Colors.blue)),
        Text("User Rating: ${game.userRating}", style: const TextStyle(fontSize: 16)),
        Text("Age Rating: ${game.ageRating}", style: const TextStyle(fontSize: 16)),
        Text("Genres: ${game.genres.map((g) => g.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
        Text("Platforms: ${game.platforms.map((p) => p.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
        Text("Metacritic Rating: ${game.metacriticRating}/100", style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}