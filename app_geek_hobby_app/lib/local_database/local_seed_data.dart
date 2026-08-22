import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/collection/collection.dart';
import 'package:app_geek_hobby_app/models/collection/collection_item.dart';
import 'package:app_geek_hobby_app/models/franchise/franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/media/media.dart';
import 'package:app_geek_hobby_app/models/studio/studio.dart';
import 'package:app_geek_hobby_app/models/user/user_media.dart';

class LocalSeedData {
  static String _normalizeId(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'unknown' : normalized;
  }

  static Future<void> migrateExistingAppMedia() async {
    final mediaBox = Hive.box<Media>('media');
    final studioBox = Hive.box<Studio>('studios');
    final franchiseBox = Hive.box<Franchise>('franchises');

    final fallbackFranchiseId = 'franchise_unassigned';
    final fallbackFranchise = Franchise(
      id: fallbackFranchiseId,
      name: 'Unassigned Franchise',
      description: 'Fallback franchise created during media migration.',
    );
    if (!franchiseBox.containsKey(fallbackFranchiseId)) {
      await franchiseBox.put(fallbackFranchiseId, fallbackFranchise);
    }

    final gamesBox = Hive.isBoxOpen('rawg_games')
        ? Hive.box<Game>('rawg_games')
        : await Hive.openBox<Game>('rawg_games');

    final animeBox = Hive.isBoxOpen('anilist_anime')
        ? Hive.box<Anime>('anilist_anime')
        : await Hive.openBox<Anime>('anilist_anime');

    for (final game in gamesBox.values) {
      final mediaId = 'game_${game.id}';
      final studioId = _normalizeId(game.studio);

      if (!studioBox.containsKey(studioId)) {
        await studioBox.put(
          studioId,
          Studio(
            id: studioId,
            name: game.studio,
            country: null,
            logoUrl: null,
          ),
        );
      }

      if (!mediaBox.containsKey(mediaId)) {
        await mediaBox.put(
          mediaId,
          Media(
            id: mediaId,
            title: game.name,
            type: 'game',
            studioId: studioId,
            franchiseId: fallbackFranchiseId,
            releaseYear: game.yearReleased,
            imageUrl: game.imageUrl,
            description: 'Migrated from the app\'s existing game data.',
            genres: game.genres.map((g) => g.name).toList(),
            platforms: game.platforms.map((p) => p.name).toList(),
          ),
        );
      }
    }

    for (final anime in animeBox.values) {
      final mediaId = 'anime_${anime.id}';
      final studioId = _normalizeId(anime.studio);

      if (!studioBox.containsKey(studioId)) {
        await studioBox.put(
          studioId,
          Studio(
            id: studioId,
            name: anime.studio,
            country: null,
            logoUrl: null,
          ),
        );
      }

      if (!mediaBox.containsKey(mediaId)) {
        await mediaBox.put(
          mediaId,
          Media(
            id: mediaId,
            title: anime.name,
            type: 'anime',
            studioId: studioId,
            franchiseId: fallbackFranchiseId,
            releaseYear: anime.yearReleased,
            imageUrl: anime.imageUrl,
            description: anime.description ?? 'Migrated from the app\'s existing anime data.',
            genres: const [],
            platforms: const [],
          ),
        );
      }
    }
  }

  static Future<void> seedDemoData() async {
    final mediaBox = Hive.box<Media>('media');
    final franchiseBox = Hive.box<Franchise>('franchises');
    final studioBox = Hive.box<Studio>('studios');
    final userMediaBox = Hive.box<UserMedia>('user_media');
    final collectionBox = Hive.box<AppCollection>('collections');
    final collectionItemBox = Hive.box<CollectionItem>('collection_items');

    final sampleStudios = [
      Studio(
        id: 'studio_nintendo',
        name: 'Nintendo',
        country: 'Japan',
        logoUrl: 'https://example.com/nintendo.png',
      ),
      Studio(
        id: 'studio_ghibli',
        name: 'Studio Ghibli',
        country: 'Japan',
        logoUrl: 'https://example.com/ghibli.png',
      ),
      Studio(
        id: 'studio_fromsoftware',
        name: 'FromSoftware',
        country: 'Japan',
        logoUrl: 'https://example.com/fromsoftware.png',
      ),
    ];

    for (final studio in sampleStudios) {
      await studioBox.put(studio.id, studio);
    }

    final sampleFranchises = [
      Franchise(
        id: 'franchise_zelda',
        name: 'The Legend of Zelda',
        description: 'A fantasy adventure series about exploration and dungeons.',
        coverImageUrl: 'https://example.com/zelda.png',
      ),
      Franchise(
        id: 'franchise_totoro',
        name: 'Spirited Away / Ghibli Worlds',
        description: 'A magical setting with whimsical spirits and family themes.',
        coverImageUrl: 'https://example.com/ghibli.png',
      ),
      Franchise(
        id: 'franchise_souls',
        name: 'Soulsborne',
        description: 'Dark fantasy action RPGs with challenging combat.',
        coverImageUrl: 'https://example.com/souls.png',
      ),
    ];

    for (final franchise in sampleFranchises) {
      await franchiseBox.put(franchise.id, franchise);
    }

    final sampleMedia = [
      Media(
        id: 'media_zelda',
        title: 'The Legend of Zelda: Tears of the Kingdom',
        type: 'game',
        studioId: 'studio_nintendo',
        franchiseId: 'franchise_zelda',
        releaseYear: 2023,
        imageUrl: 'https://example.com/zelda.jpg',
        description: 'A direct sequel exploring the skies and depths of Hyrule.',
        genres: ['Adventure', 'Action', 'Open World'],
        platforms: ['Nintendo Switch'],
      ),
      Media(
        id: 'media_spirited_away',
        title: 'Spirited Away',
        type: 'anime',
        studioId: 'studio_ghibli',
        franchiseId: 'franchise_totoro',
        releaseYear: 2001,
        imageUrl: 'https://example.com/spirited_away.jpg',
        description: 'A young girl enters a magical bathhouse spirit world.',
        genres: ['Fantasy', 'Adventure'],
        platforms: ['Movie'],
      ),
      Media(
        id: 'media_elden_ring',
        title: 'Elden Ring',
        type: 'game',
        studioId: 'studio_fromsoftware',
        franchiseId: 'franchise_souls',
        releaseYear: 2022,
        imageUrl: 'https://example.com/elden_ring.jpg',
        description: 'A dark open-world action RPG with demanding combat.',
        genres: ['Action RPG', 'Fantasy'],
        platforms: ['PC', 'PlayStation 5', 'Xbox Series X|S'],
      ),
    ];

    for (final media in sampleMedia) {
      await mediaBox.put(media.id, media);
    }

    final collectionId = 'collection_favourites';
    final collection = AppCollection(
      id: collectionId,
      userId: 'user_1',
      name: 'Favourites',
      description: 'Demo collection for testing local storage.',
      isPublic: false,
    );
    await collectionBox.put(collection.id, collection);

    final collectionItems = [
      CollectionItem(
        id: 'collection_item_1',
        collectionId: collectionId,
        mediaId: 'media_zelda',
        order: 1,
      ),
      CollectionItem(
        id: 'collection_item_2',
        collectionId: collectionId,
        mediaId: 'media_elden_ring',
        order: 2,
      ),
    ];

    for (final item in collectionItems) {
      await collectionItemBox.put(item.id, item);
    }

    final userMediaEntries = [
      UserMedia(
        id: 'user_media_zelda',
        userId: 'user_1',
        mediaId: 'media_zelda',
        status: 'playing',
        progress: 12,
        rating: 9,
      ),
      UserMedia(
        id: 'user_media_elden_ring',
        userId: 'user_1',
        mediaId: 'media_elden_ring',
        status: 'completed',
        progress: 100,
        rating: 10,
      ),
    ];

    for (final item in userMediaEntries) {
      await userMediaBox.put(item.id, item);
    }
  }
}
