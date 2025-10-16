import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';
import 'package:hive/hive.dart';

class GameDisplay extends StatefulWidget {
  final Game game;

  const GameDisplay({super.key, required this.game});

  @override
  State<GameDisplay> createState() => _GameDisplayState();
}

class _GameDisplayState extends State<GameDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;
  late bool completed;

  @override
  void initState() {
    super.initState();
    owned = widget.game.owned;
    wishlisted = widget.game.wishlist;
    userRating = widget.game.userRating;
    completed = widget.game.completed;
  }

  void updateOwned(bool value) async {
  setState(() {
    owned = value;
    if (owned) wishlisted = false;
    widget.game.owned = owned;
    widget.game.wishlist = wishlisted;
  });
  await widget.game.save();

  final ownedBox = Hive.box<int>('games_owned_collection_id');
  final wishlistBox = Hive.box<int>('games_wishlist_collection_id');

  // Add to owned collection
  if (owned) {
    ownedBox.put(widget.game.id, widget.game.id);
    // Remove from wishlist if present
    wishlistBox.delete(widget.game.id);
  } else {
    ownedBox.delete(widget.game.id);
  }
}

void updateWishlist(bool value) async {
  setState(() {
    wishlisted = value;
    widget.game.wishlist = wishlisted;
  });
  await widget.game.save();

  final wishlistBox = Hive.box<int>('games_wishlist_collection_id');

  // Add to wishlist collection
  if (wishlisted) {
    wishlistBox.put(widget.game.id, widget.game.id);
  } else {
    wishlistBox.delete(widget.game.id);
  }
}

void updateCompleted(bool value) async {
  setState(() {
    completed = value;
    widget.game.completed = value;
  });
  await widget.game.save();

  final completedBox = Hive.box<int>('games_completed_collection_id');

  if (completed) {
    completedBox.put(widget.game.id, widget.game.id);
  } else {
    completedBox.delete(widget.game.id);
  }
}

  void updateUserRating(int rating) async {
    setState(() {
      widget.game.userRating = rating;
    });
    await widget.game.save();
  }

  

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Game details",
      imageUrl: widget.game.imageUrl,
      details: [
        Text(widget.game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(widget.game.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.game.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Age Rating: ${widget.game.ageRating}", style: const TextStyle(fontSize: 16)),
        Text("Genres: ${widget.game.genres.map((g) => g.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
        Text("Platforms: ${widget.game.platforms.map((p) => p.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
        if (owned) ...[
          SwitchListTile(
            title: const Text('Completed'),
            value: completed,
            onChanged: updateCompleted,
          ),
        ],
      ],
      owned: owned,
      wishlisted: wishlisted,
      onOwnedChanged: updateOwned,
      onWishlistChanged: updateWishlist,
      userRating: userRating,
      onUserRatingChanged: updateUserRating,
    );
  }
}