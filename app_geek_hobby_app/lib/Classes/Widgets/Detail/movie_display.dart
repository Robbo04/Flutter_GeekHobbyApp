import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';

class MovieDisplay extends StatefulWidget {
  final Movie movie;

  const MovieDisplay({super.key, required this.movie});

  @override
  State<MovieDisplay> createState() => _MovieDisplayState();
}

class _MovieDisplayState extends State<MovieDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;

  @override
  void initState() {
    super.initState();
    owned = widget.movie.owned;
    wishlisted = widget.movie.wishlist;
    userRating = widget.movie.userRating;
  }

  void updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.movie.owned = owned;
      widget.movie.wishlist = wishlisted;
    });
    await widget.movie.save();
  }

  void updateWishlist(bool value) async {
    setState(() {
      wishlisted = value;
      widget.movie.wishlist = wishlisted;
    });
    await widget.movie.save();
  }

  void updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.movie.userRating = rating;
    });
    await widget.movie.save();
  }

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Movie details",
      imageUrl: widget.movie.imageUrl,
      details: [
        Text(widget.movie.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(widget.movie.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.movie.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Runtime: ${widget.movie.duration} minutes", style: const TextStyle(fontSize: 16)),
        Text("Age Rating: ${widget.movie.ageRating}", style: const TextStyle(fontSize: 16)),
        Text("Genres: ${widget.movie.genres.map((g) => g.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
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