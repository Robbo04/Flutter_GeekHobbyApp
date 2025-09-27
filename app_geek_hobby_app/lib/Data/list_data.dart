import 'package:app_geek_hobby_app/Classes/itemlist.dart';
import 'package:app_geek_hobby_app/Enums/Genres/video_genre.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';

import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

import 'package:app_geek_hobby_app/Enums/AgeRatings/movie_age.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/show_age.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';

final ItemList moviesListTest = ItemList(
  name: 'Movies',
  items: [
    Movie(name: 'Movie 1', studio: 'Studio 1', yearReleased: 2020, genres: [VideoGenre.action], director: 'Director 1', duration: 120, ageRating: MovieAgeRating.pg, imdbRating: 7.5),
    Movie(name: 'Movie 2', studio: 'Studio 2', yearReleased: 2021, genres: [VideoGenre.comedy], director: 'Director 2', duration: 90, ageRating: MovieAgeRating.fifteen, imdbRating: 6.8),
    Movie(name: 'Movie 3', studio: 'Studio 3', yearReleased: 2022, genres: [VideoGenre.drama], director: 'Director 3', duration: 100, ageRating: MovieAgeRating.eighteen, imdbRating: 8.0),
    Movie(name: 'Movie 4', studio: 'Studio 4', yearReleased: 2023, genres: [VideoGenre.horror], director: 'Director 4', duration: 110, ageRating: MovieAgeRating.pg, imdbRating: 7.2),
    Movie(name: 'Movie 5', studio: 'Studio 5', yearReleased: 2024, genres: [VideoGenre.sciFi], director: 'Director 5', duration: 130, ageRating: MovieAgeRating.pg, imdbRating: 8.5),
    Movie(name: 'Movie 6', studio: 'Studio 6', yearReleased: 2024, genres: [VideoGenre.fantasy], director: 'Director 6', duration: 140, ageRating: MovieAgeRating.pg, imdbRating: 7.9),
    Movie(name: 'Movie 7', studio: 'Studio 7', yearReleased: 2024, genres: [VideoGenre.animation], director: 'Director 7', duration: 95, ageRating: MovieAgeRating.pg, imdbRating: 8.1),
    Movie(name: 'Movie 8', studio: 'Studio 8', yearReleased: 2024, genres: [VideoGenre.thriller], director: 'Director 8', duration: 105, ageRating: MovieAgeRating.fifteen, imdbRating: 7.4),
    Movie(name: 'Movie 9', studio: 'Studio 9', yearReleased: 2024, genres: [VideoGenre.mystery], director: 'Director 9', duration: 115, ageRating: MovieAgeRating.eighteen, imdbRating: 8.3),
    Movie(name: 'Movie 10', studio: 'Studio 10', yearReleased: 2024, genres: [VideoGenre.documentary], director: 'Director 10', duration: 85, ageRating: MovieAgeRating.pg, imdbRating: 7.0),

  ],
)..allowedTypes.add(Movie);


final ItemList showsListTest = ItemList(
  name: 'Shows',
  items: [
    Show(name: 'Show 1', studio: 'Studio 1', yearReleased: 2020, genres: [VideoGenre.action], seasons: 1, episodes: 10, runtime: 30, ageRating: ShowAgeRating.pg),
    Show(name: 'Show 2', studio: 'Studio 2', yearReleased: 2021, genres: [VideoGenre.comedy], seasons: 2, episodes: 20, runtime: 25, ageRating: ShowAgeRating.fifteen),
    Show(name: 'Show 3', studio: 'Studio 3', yearReleased: 2022, genres: [VideoGenre.drama], seasons: 3, episodes: 30, runtime: 40, ageRating: ShowAgeRating.eighteen),
    Show(name: 'Show 4', studio: 'Studio 4', yearReleased: 2023, genres: [VideoGenre.horror], seasons: 4, episodes: 40, runtime: 50, ageRating: ShowAgeRating.pg),
  ],
)..allowedTypes.add(Show);

final ItemList gameListsTest = ItemList(
    name: 'Games',
    items: [
      Game(name: 'Game 1', studio: 'Studio 1', yearReleased: 2020, genres: [GameGenre.action], platforms: [], ageRating: GameAge.pegi12, metacriticRating: 85),
      Game(name: 'Game 2', studio: 'Studio 2', yearReleased: 2021, genres: [GameGenre.adventure], platforms: [], ageRating: GameAge.pegi16, metacriticRating: 90),
      Game(name: 'Game 3', studio: 'Studio 3', yearReleased: 2022, genres: [GameGenre.rpg], platforms: [], ageRating: GameAge.pegi18, metacriticRating: 95),
      Game(name: 'Game 4', studio: 'Studio 4', yearReleased: 2023, genres: [GameGenre.strategy], platforms: [], ageRating: GameAge.pegi7, metacriticRating: 80),
    ],
  )..allowedTypes.add(Game);
