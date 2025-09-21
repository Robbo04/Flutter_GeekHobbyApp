import 'package:app_geek_hobby_app/Classes/item.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/show_age.dart';

class Show extends Item {
  final int seasons;
  final int episodes;
  final int runtime; // Average runtime in minutes
  final ShowAgeRating ageRating; // Age rating

  Show({
    required super.name,
    required super.studio,
    required super.yearReleased,
    required this.seasons,
    required this.episodes,
    required this.runtime,
    required this.ageRating,
  });
}