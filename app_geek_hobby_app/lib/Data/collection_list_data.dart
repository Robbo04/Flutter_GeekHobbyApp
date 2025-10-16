import 'package:app_geek_hobby_app/Classes/itemlist.dart';

import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';

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

ItemList gameWishlistCollection = ItemList(
  name: 'Games Wishlist',
  items: [],
)..allowedTypes.add(Game);

ItemList gameOwnedCollection = ItemList(
  name: 'Games Owned',
  items: [],
)..allowedTypes.add(Game);

ItemList gameBacklogCollection = ItemList(
  name: 'Games Backlog',
  items: [],
)..allowedTypes.add(Game);

ItemList gameCompletedCollection = ItemList(
  name: 'Games Completed',
  items: [],
)..allowedTypes.add(Game);