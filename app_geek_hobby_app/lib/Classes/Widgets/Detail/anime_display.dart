import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';

class AnimeDisplay extends StatefulWidget {
  final Anime anime;

  const AnimeDisplay({super.key, required this.anime});

  @override
  State<AnimeDisplay> createState() => _AnimeDisplayState();
}

class _AnimeDisplayState extends State<AnimeDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;

  @override
  void initState() {
    super.initState();
    owned = widget.anime.owned;
    wishlisted = widget.anime.wishlist;
    userRating = widget.anime.userRating;
  }

  void updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.anime.owned = owned;
      widget.anime.wishlist = wishlisted;
    });
    await widget.anime.save();
  }

  void updateWishlist(bool value) async {
    setState(() {
      wishlisted = value;
      widget.anime.wishlist = wishlisted;
    });
    await widget.anime.save();
  }

  void updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.anime.userRating = rating;
    });
    await widget.anime.save();
  }

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Anime details",
      imageUrl: widget.anime.imageUrl,
      details: [
        Text(widget.anime.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(widget.anime.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.anime.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Runtime: ${widget.anime.runtime} minutes", style: const TextStyle(fontSize: 16)),
        Text("Seasons: ${widget.anime.seasons}", style: const TextStyle(fontSize: 16)),
        Text("Episodes: ${widget.anime.episodes}", style: const TextStyle(fontSize: 16)),
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