import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

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
}