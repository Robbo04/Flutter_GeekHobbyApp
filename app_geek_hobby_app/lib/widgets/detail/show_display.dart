import 'package:app_geek_hobby_app/models/item/show.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';
import 'package:app_geek_hobby_app/widgets/detail/item_display.dart';

class ShowDisplay extends StatefulWidget {
  final Show show;

  const ShowDisplay({super.key, required this.show});

  @override
  State<ShowDisplay> createState() => _ShowDisplayState();
}

class _ShowDisplayState extends State<ShowDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;

  @override
  void initState() {
    super.initState();
    owned = widget.show.owned;
    wishlisted = widget.show.wishlist;
    userRating = widget.show.userRating;
  }

  void updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.show.owned = owned;
      widget.show.wishlist = wishlisted;
    });
    await widget.show.save();
  }

  void updateWishlist(bool value) async {
    setState(() {
      wishlisted = value;
      widget.show.wishlist = wishlisted;
    });
    await widget.show.save();
  }

  void updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.show.userRating = rating;
    });
    await widget.show.save();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ItemDisplay(
      title: "Show details",
      imageUrl: widget.show.imageUrl,
      details: [
        AppTitleText(
          widget.show.name,
          selectable: true,
          maxLines: null,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.verticalLg,
        Text(widget.show.studio, style: textTheme.bodyMedium),
        Text(widget.show.yearReleased.toString(), style: textTheme.bodyMedium),
        Text("Runtime: ${widget.show.runtime} minutes", style: textTheme.bodyMedium),
        Text("Age Rating: ${widget.show.ageRating}", style: textTheme.bodyMedium),
        Text("Genres: ${widget.show.genres.map((g) => g.toString().split('.').last).join(', ')}", style: textTheme.bodyMedium),
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