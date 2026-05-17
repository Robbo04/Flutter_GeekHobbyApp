import 'package:app_geek_hobby_app/widgets/detail/movie_display.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/models/item/movie.dart';
import 'package:app_geek_hobby_app/models/item/show.dart';
import 'package:app_geek_hobby_app/widgets/detail/show_display.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/widgets/detail/anime_display.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/widgets/detail/game_display.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item; // Replace 'dynamic' with your actual item type

  const ItemDetailPage({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    Widget detailWidget;

    if (item is Movie)
    {
      detailWidget = MovieDisplay(movie: item as Movie);
    }
    else if (item is Show) {
      detailWidget = ShowDisplay(show: item as Show);
    }
    else if (item is Anime) {
      detailWidget = AnimeDisplay(anime: item as Anime);
    }     
    else if (item is Game) {
      detailWidget = GameDisplay(game: item as Game);
    }
    else {
      detailWidget = Center(
        child: Text('No detail view available for this item type.'),
      );
    }

    return Scaffold(
      body: detailWidget,
    );
  }
}