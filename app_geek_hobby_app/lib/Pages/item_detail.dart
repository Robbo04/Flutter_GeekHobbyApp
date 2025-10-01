import 'package:app_geek_hobby_app/Classes/Widgets/Detail/movie_display.dart';
import 'package:app_geek_hobby_app/Classes/item.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/show_display.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/anime_display.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/game_display.dart';

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