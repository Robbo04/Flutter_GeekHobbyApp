import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/user/user.dart';
import 'package:app_geek_hobby_app/models/user/user_profile.dart';
import 'package:app_geek_hobby_app/models/user/user_media.dart';
import 'package:app_geek_hobby_app/models/media/media.dart';
import 'package:app_geek_hobby_app/models/franchise/franchise.dart';
import 'package:app_geek_hobby_app/models/franchise/franchise_member.dart';
import 'package:app_geek_hobby_app/models/studio/studio.dart';
import 'package:app_geek_hobby_app/models/studio/studio_member.dart';
import 'package:app_geek_hobby_app/models/collection/collection.dart';
import 'package:app_geek_hobby_app/models/collection/collection_item.dart';
import 'package:app_geek_hobby_app/models/review/review.dart';

import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/enums/platforms/game_platform.dart';
import 'package:app_geek_hobby_app/enums/age_ratings/game_age.dart';
import 'package:app_geek_hobby_app/enums/genres/game_genre.dart';

class LocalHiveService {
  static Future<void> initialize() async {
    // Keep all local database registration in one place.
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserMediaAdapter());
    Hive.registerAdapter(MediaAdapter());
    Hive.registerAdapter(FranchiseAdapter());
    Hive.registerAdapter(FranchiseMemberAdapter());
    Hive.registerAdapter(StudioAdapter());
    Hive.registerAdapter(StudioMemberAdapter());
    Hive.registerAdapter(AppCollectionAdapter());
    Hive.registerAdapter(CollectionItemAdapter());
    Hive.registerAdapter(ReviewAdapter());

    // Existing app models, still registered centrally for compatibility.
    Hive.registerAdapter(GameAdapter());
    Hive.registerAdapter(AnimeAdapter());
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(GamePlatformAdapter());
    Hive.registerAdapter(GameAgeAdapter());
    Hive.registerAdapter(GameGenreAdapter());

    await Hive.openBox<User>('users');
    await Hive.openBox<UserProfile>('user_profiles');
    await Hive.openBox<UserMedia>('user_media');
    await Hive.openBox<Media>('media');
    await Hive.openBox<Franchise>('franchises');
    await Hive.openBox<FranchiseMember>('franchise_members');
    await Hive.openBox<Studio>('studios');
    await Hive.openBox<StudioMember>('studio_members');
    await Hive.openBox<AppCollection>('collections');
    await Hive.openBox<CollectionItem>('collection_items');
    await Hive.openBox<Review>('reviews');

    // Existing cached boxes remain separate concern from the database layer.
    await Hive.openBox<Item>('items');
    await Hive.openBox<List>('rawg_search_results');
    await Hive.openBox<GameDetails>('rawg_game_details');
    await Hive.openBox<int>('rawg_stats');
    await Hive.openBox<int>('anilist_stats');
    await Hive.openBox<int>('games_wishlist_collection_id');
    await Hive.openBox<int>('games_owned_collection_id');
    await Hive.openBox<int>('games_backlog_collection_id');
    await Hive.openBox<int>('games_completed_collection_id');
    await Hive.openBox<int>('anime_wishlist_collection_id');
    await Hive.openBox<int>('anime_watched_collection_id');
    await Hive.openBox<String>('app_preferences');

    try {
      await Hive.openBox<Game>('rawg_games');
    } catch (e, st) {
      print('Error opening rawg_games box: $e\n$st');
      await Hive.deleteBoxFromDisk('rawg_games');
      await Hive.openBox<Game>('rawg_games');
    }

    try {
      await Hive.openBox<int>('rawg_cache_meta');
    } catch (e, st) {
      print('Error opening rawg_cache_meta box: $e\n$st');
      await Hive.deleteBoxFromDisk('rawg_cache_meta');
      await Hive.openBox<int>('rawg_cache_meta');
    }

    try {
      await Hive.openBox<Anime>('anilist_anime');
    } catch (e, st) {
      print('Error opening anilist_anime box: $e\n$st');
      await Hive.deleteBoxFromDisk('anilist_anime');
      await Hive.openBox<Anime>('anilist_anime');
    }

    try {
      await Hive.openBox<int>('anilist_cache_meta');
    } catch (e, st) {
      print('Error opening anilist_cache_meta box: $e\n$st');
      await Hive.deleteBoxFromDisk('anilist_cache_meta');
      await Hive.openBox<int>('anilist_cache_meta');
    }

    await Hive.openBox<List>('anilist_search_results');
  }
}
