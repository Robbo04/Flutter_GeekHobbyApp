import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';

class CollectionsService {
  CollectionsService._();
  static final CollectionsService instance = CollectionsService._();

  Future<Box<int>> _openIdBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<int>(name);
    return await Hive.openBox<int>(name);
  }

  Future<Box<Game>> _openGamesBox() async {
    const name = 'rawg_games';
    if (Hive.isBoxOpen(name)) return Hive.box<Game>(name);
    return await Hive.openBox<Game>(name);
  }

  Future<Box<Anime>> _openAnimeBox() async {
    const name = 'anilist_anime';
    if (Hive.isBoxOpen(name)) return Hive.box<Anime>(name);
    return await Hive.openBox<Anime>(name);
  }

  // ==================== GAME COLLECTIONS ====================

  /// Add a game id to the wishlist and optionally persist the full Game object.
  /// Also updates the in-memory Game fields and calls `save()` on the model.
  Future<void> addToWishlist(Game game, {bool persistGame = true}) async {
    final wishlistBox = await _openIdBox('games_wishlist_collection_id');

    await wishlistBox.put(game.id, game.id);

    // update model flags and save
    game.wishlist = true;
    await _maybePersistGame(game, persistGame);
  }

  Future<void> removeFromWishlist(Game game) async {
    final wishlistBox = await _openIdBox('games_wishlist_collection_id');
    await wishlistBox.delete(game.id);
    game.wishlist = false;
    try {
      await game.save();
    } catch (err, st) {
      debugPrint('Error saving game after wishlist removal: $err\n$st');
    }
  }

  /// Add to owned collection and optionally remove from other collections.
  Future<void> addToOwned(Game game, {bool removeFromOthers = true, bool persistGame = true}) async {
    final ownedBox = await _openIdBox('games_owned_collection_id');
    await ownedBox.put(game.id, game.id);

    if (removeFromOthers) {
      final wishlistBox = await _openIdBox('games_wishlist_collection_id');
      final backlogBox = await _openIdBox('games_backlog_collection_id');
      final completedBox = await _openIdBox('games_completed_collection_id');

      await wishlistBox.delete(game.id);
      await backlogBox.delete(game.id);
      await completedBox.delete(game.id);
    }

    // update model flags and save
    game.owned = true;
    game.wishlist = false;
    await _maybePersistGame(game, persistGame);
  }

  Future<void> removeFromOwned(Game game) async {
    final ownedBox = await _openIdBox('games_owned_collection_id');
    await ownedBox.delete(game.id);
    game.owned = false;
    try {
      await game.save();
    } catch (err, st) {
      debugPrint('Error saving game after owned removal: $err\n$st');
    }
  }

  /// Add to backlog collection
  Future<void> addToBacklog(Game game, {bool persistGame = true}) async {
    final backlogBox = await _openIdBox('games_backlog_collection_id');
    await backlogBox.put(game.id, game.id);
    await _maybePersistGame(game, persistGame);
  }

  Future<void> removeFromBacklog(Game game) async {
    final backlogBox = await _openIdBox('games_backlog_collection_id');
    await backlogBox.delete(game.id);
    try {
      await game.save();
    } catch (err, st) {
      debugPrint('Error saving game after backlog removal: $err\n$st');
    }
  }

  /// Add to completed collection
  Future<void> addToCompleted(Game game, {bool persistGame = true}) async {
    final completedBox = await _openIdBox('games_completed_collection_id');
    await completedBox.put(game.id, game.id);
    game.completed = true;
    await _maybePersistGame(game, persistGame);
  }

  Future<void> removeFromCompleted(Game game) async {
    final completedBox = await _openIdBox('games_completed_collection_id');
    await completedBox.delete(game.id);
    game.completed = false;
    try {
      await game.save();
    } catch (err, st) {
      debugPrint('Error saving game after completed removal: $err\n$st');
    }
  }

  /// Check if a game ID exists in any collection
  Future<bool> isGameInAnyCollection(int id) async {
    try {
      final boxes = await Future.wait([
        _openIdBox('games_owned_collection_id'),
        _openIdBox('games_wishlist_collection_id'),
        _openIdBox('games_backlog_collection_id'),
        _openIdBox('games_completed_collection_id'),
      ]);
      return boxes.any((box) => box.containsKey(id));
    } catch (_) {
      return false;
    }
  }

  /// Get all game IDs in wishlist
  Future<List<int>> getGameWishlistIds() async {
    final wishlistBox = await _openIdBox('games_wishlist_collection_id');
    return wishlistBox.values.toList();
  }

  /// Get all game IDs in owned
  Future<List<int>> getGameOwnedIds() async {
    final ownedBox = await _openIdBox('games_owned_collection_id');
    return ownedBox.values.toList();
  }

  /// Get all game IDs in backlog
  Future<List<int>> getGameBacklogIds() async {
    final backlogBox = await _openIdBox('games_backlog_collection_id');
    return backlogBox.values.toList();
  }

  /// Get all game IDs in completed
  Future<List<int>> getGameCompletedIds() async {
    final completedBox = await _openIdBox('games_completed_collection_id');
    return completedBox.values.toList();
  }

  /// Get all game objects in wishlist
  Future<List<Game>> getGameWishlist() async {
    final ids = await getGameWishlistIds();
    final gamesBox = await _openGamesBox();
    return ids.map((id) => gamesBox.get(id)).whereType<Game>().toList();
  }

  /// Get all game objects in owned
  Future<List<Game>> getGameOwned() async {
    final ids = await getGameOwnedIds();
    final gamesBox = await _openGamesBox();
    return ids.map((id) => gamesBox.get(id)).whereType<Game>().toList();
  }

  /// Get all game objects in backlog
  Future<List<Game>> getGameBacklog() async {
    final ids = await getGameBacklogIds();
    final gamesBox = await _openGamesBox();
    return ids.map((id) => gamesBox.get(id)).whereType<Game>().toList();
  }

  /// Get all game objects in completed
  Future<List<Game>> getGameCompleted() async {
    final ids = await getGameCompletedIds();
    final gamesBox = await _openGamesBox();
    return ids.map((id) => gamesBox.get(id)).whereType<Game>().toList();
  }

  // Convenience: persist full Game object into rawg_games, but don't crash on adapter errors.
  Future<void> _maybePersistGame(Game game, bool persist) async {
    if (!persist) {
      try {
        await game.save();
      } catch (err, st) {
        debugPrint('Error saving game model: $err\n$st');
      }
      return;
    }

    try {
      final gamesBox = await _openGamesBox();
      await gamesBox.put(game.id, game);
      // ensure the model is saved as well (in case model keeps its own fields)
      try {
        await game.save();
      } catch (_) {
        // ignore; we already logged if necessary
      }
    } catch (err, st) {
      // Common failure: missing TypeAdapter or adapter version mismatch
      debugPrint('Failed to persist Game ${game.id} to rawg_games: $err\n$st');
      // Fall back to saving the model only (if possible)
      try {
        await game.save();
      } catch (err2, st2) {
        debugPrint('Also failed to call game.save(): $err2\n$st2');
      }
    }
  }

  // ==================== ANIME COLLECTIONS ====================

  /// Add an anime to the wishlist and optionally persist the full Anime object.
  Future<void> addAnimeToWishlist(Anime anime, {bool persistAnime = true}) async {
    final wishlistBox = await _openIdBox('anime_wishlist_collection_id');

    await wishlistBox.put(anime.id, anime.id);

    // update model flags and save
    anime.wishlist = true;
    await _maybePersistAnime(anime, persistAnime);
  }

  Future<void> removeAnimeFromWishlist(Anime anime) async {
    final wishlistBox = await _openIdBox('anime_wishlist_collection_id');
    await wishlistBox.delete(anime.id);
    anime.wishlist = false;
    try {
      await anime.save();
    } catch (err, st) {
      debugPrint('Error saving anime after wishlist removal: $err\n$st');
    }
  }

  /// Add to watched collection and optionally remove from wishlist.
  Future<void> addAnimeToWatched(Anime anime, {bool removeFromWishlist = true, bool persistAnime = true}) async {
    final watchedBox = await _openIdBox('anime_watched_collection_id');
    await watchedBox.put(anime.id, anime.id);

    if (removeFromWishlist) {
      final wishlistBox = await _openIdBox('anime_wishlist_collection_id');
      await wishlistBox.delete(anime.id);
    }

    // update model flags and save
    anime.wishlist = false;
    await _maybePersistAnime(anime, persistAnime);
  }

  Future<void> removeAnimeFromWatched(Anime anime) async {
    final watchedBox = await _openIdBox('anime_watched_collection_id');
    await watchedBox.delete(anime.id);
    try {
      await anime.save();
    } catch (err, st) {
      debugPrint('Error saving anime after watched removal: $err\n$st');
    }
  }

  /// Get all anime IDs in wishlist
  Future<List<int>> getAnimeWishlistIds() async {
    final wishlistBox = await _openIdBox('anime_wishlist_collection_id');
    return wishlistBox.values.toList();
  }

  /// Get all anime IDs in watched
  Future<List<int>> getAnimeWatchedIds() async {
    final watchedBox = await _openIdBox('anime_watched_collection_id');
    return watchedBox.values.toList();
  }

  /// Get all anime objects in wishlist
  Future<List<Anime>> getAnimeWishlist() async {
    final ids = await getAnimeWishlistIds();
    final animeBox = await _openAnimeBox();
    return ids.map((id) => animeBox.get(id)).whereType<Anime>().toList();
  }

  /// Get all anime objects in watched
  Future<List<Anime>> getAnimeWatched() async {
    final ids = await getAnimeWatchedIds();
    final animeBox = await _openAnimeBox();
    return ids.map((id) => animeBox.get(id)).whereType<Anime>().toList();
  }

  // Convenience: persist full Anime object into anilist_anime, but don't crash on adapter errors.
  Future<void> _maybePersistAnime(Anime anime, bool persist) async {
    if (!persist) {
      try {
        await anime.save();
      } catch (err, st) {
        debugPrint('Error saving anime model: $err\n$st');
      }
      return;
    }

    try {
      final animeBox = await _openAnimeBox();
      await animeBox.put(anime.id, anime);
      // ensure the model is saved as well (in case model keeps its own fields)
      try {
        await anime.save();
      } catch (_) {
        // ignore; we already logged if necessary
      }
    } catch (err, st) {
      // Common failure: missing TypeAdapter or adapter version mismatch
      debugPrint('Failed to persist Anime ${anime.id} to anilist_anime: $err\n$st');
      // Fall back to saving the model only (if possible)
      try {
        await anime.save();
      } catch (err2, st2) {
        debugPrint('Also failed to call anime.save(): $err2\n$st2');
      }
    }
  }
}