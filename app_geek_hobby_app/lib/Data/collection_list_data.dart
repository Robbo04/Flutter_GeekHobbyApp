import 'package:app_geek_hobby_app/Classes/itemlist.dart';
import 'package:app_geek_hobby_app/Enums/Genres/video_genre.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';

import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';

import 'package:app_geek_hobby_app/Enums/AgeRatings/movie_age.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/show_age.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';

ItemList collectionListTest = ItemList(
  name: 'Collections',
  items: [],
)..allowedTypes.addAll([Movie, Show, Game, Anime]);

ItemList backlogGamesListTest = ItemList(
  name: 'Backlog Games',
  items: [],
)..allowedTypes.add(Game);

ItemList watchedMoviesListTest = ItemList(
  name: 'Watched Movies',
  items: [],
)..allowedTypes.add(Movie);

ItemList watchedShowsListTest = ItemList(
  name: 'Watched Shows',
  items: [],
)..allowedTypes.add(Show);

ItemList completedGamesListTest = ItemList(
  name: 'Completed Games',
  items: [],
)..allowedTypes.add(Game);

ItemList watchedAnimeListTest = ItemList(
  name: 'Watched Anime',
  items: [],
)..allowedTypes.add(Anime);