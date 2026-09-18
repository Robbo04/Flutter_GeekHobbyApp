import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/widgets/common/empty_state_widget.dart';
import 'package:app_geek_hobby_app/widgets/common/error_widget.dart';
import 'package:app_geek_hobby_app/widgets/carousels/item_carousel.dart';
import 'package:app_geek_hobby_app/widgets/common/offline_retry_banner.dart';
import 'package:app_geek_hobby_app/widgets/common/skeleton_placeholders.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/data/curated_lists.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/screens/search.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, this.autoPrimeCarousels = true});

  final bool autoPrimeCarousels;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  static const String _prefsBoxName = 'app_preferences';
  static const String _tabIndexKey = 'explore_tab_index';
  static const String _gamesScrollOffsetKey = 'explore_games_scroll_offset';
  static const String _animeScrollOffsetKey = 'explore_anime_scroll_offset';

  final RawgService _rawgService = RawgService.instance;
  final AniListService _aniListService = AniListService.instance;
  final Map<String, Future<List<Game>>> _gameFutures = {};
  final Map<String, Future<List<AnimeFranchise>>> _animeFutures = {};
  late final TabController _tabController;
  late final ScrollController _gamesScrollController;
  late final ScrollController _animeScrollController;
  String? _offlineMessage;

  @override
  void initState() {
    super.initState();
    final restored = _restorePreferences();
    _tabController = TabController(length: 2, vsync: this, initialIndex: restored.tabIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _storePreference(_tabIndexKey, _tabController.index.toString());
    });
    _gamesScrollController = ScrollController(initialScrollOffset: restored.gameOffset);
    _animeScrollController = ScrollController(initialScrollOffset: restored.animeOffset);
    if (widget.autoPrimeCarousels) {
      _primeCarousels();
    }
  }

  _ExploreRestoredState _restorePreferences() {
    if (!Hive.isBoxOpen(_prefsBoxName)) {
      return const _ExploreRestoredState();
    }

    final box = Hive.box<String>(_prefsBoxName);
    final tabIndex = int.tryParse(box.get(_tabIndexKey) ?? '') ?? 0;
    final gameOffset = double.tryParse(box.get(_gamesScrollOffsetKey) ?? '') ?? 0;
    final animeOffset = double.tryParse(box.get(_animeScrollOffsetKey) ?? '') ?? 0;

    return _ExploreRestoredState(
      tabIndex: tabIndex.clamp(0, 1),
      gameOffset: gameOffset,
      animeOffset: animeOffset,
    );
  }

  Future<void> _storePreference(String key, String value) async {
    if (!Hive.isBoxOpen(_prefsBoxName)) return;
    await Hive.box<String>(_prefsBoxName).put(key, value);
  }

  @override
  void dispose() {
    _storePreference(
      _gamesScrollOffsetKey,
      _gamesScrollController.hasClients
          ? _gamesScrollController.offset.toStringAsFixed(2)
          : '0',
    );
    _storePreference(
      _animeScrollOffsetKey,
      _animeScrollController.hasClients
          ? _animeScrollController.offset.toStringAsFixed(2)
          : '0',
    );
    _storePreference(_tabIndexKey, _tabController.index.toString());
    _tabController.dispose();
    _gamesScrollController.dispose();
    _animeScrollController.dispose();
    super.dispose();
  }

  Future<List<Game>> _fetchGameCarouselSafe(CarouselCategory category) async {
    try {
      return await _fetchGameCarousel(category);
    } catch (e) {
      if (mounted) {
        setState(() {
          _offlineMessage = 'Connection issue while loading explore content.';
        });
      }
      rethrow;
    }
  }

  Future<List<AnimeFranchise>> _fetchAnimeCarouselSafe(CarouselCategory category) async {
    try {
      return await _fetchAnimeCarousel(category);
    } catch (e) {
      if (mounted) {
        setState(() {
          _offlineMessage = 'Connection issue while loading explore content.';
        });
      }
      rethrow;
    }
  }

  List<CarouselCategory> _visibleGameCategories() {
    return ExploreCarousels.gameCarousels
        .where((category) => category.type != CarouselType.tag)
        .toList();
  }

  List<CarouselCategory> _visibleAnimeCategories() {
    return ExploreCarousels.animeCarousels;
  }

  String _categoryKey(CarouselCategory category) {
    return '${category.type.name}:${category.value ?? ''}';
  }

  void _primeCarousels() {
    for (final category in ExploreCarousels.gameCarousels.where((c) => c.type != CarouselType.tag)) {
      _gameFutures[_categoryKey(category)] = _fetchGameCarouselSafe(category);
    }

    for (final category in ExploreCarousels.animeCarousels) {
      _animeFutures[_categoryKey(category)] = _fetchAnimeCarouselSafe(category);
    }
  }

  Future<void> _refreshAllCarousels() async {
    setState(() {
      _offlineMessage = null;
      _gameFutures.clear();
      _animeFutures.clear();
      _primeCarousels();
    });

    try {
      await Future.wait([
        ..._gameFutures.values,
        ..._animeFutures.values,
      ]);
    } catch (_) {
      // Section-level errors are rendered inline by each carousel.
    }
  }

  void _retryGameCarousel(CarouselCategory category) {
    setState(() {
      _offlineMessage = null;
      _gameFutures[_categoryKey(category)] = _fetchGameCarouselSafe(category);
    });
  }

  void _retryAnimeCarousel(CarouselCategory category) {
    setState(() {
      _offlineMessage = null;
      _animeFutures[_categoryKey(category)] = _fetchAnimeCarouselSafe(category);
    });
  }

  // Helper method to fetch games based on carousel category
  Future<List<Game>> _fetchGameCarousel(CarouselCategory category) {
    switch (category.type) {
      case CarouselType.trending:
        return _rawgService.fetchTrending(minMetacritic: 0, minRatingsCount: 0);
      case CarouselType.comingSoon:
        return _rawgService.fetchComingSoon();
      case CarouselType.mostPlayed:
        return _rawgService.fetchMostPlayed();
      case CarouselType.genre:
        return _rawgService.fetchByGenre(genre: category.value!);
      default:
        return _rawgService.fetchGames();
    }
  }

  // Helper method to fetch anime based on carousel category
  Future<List<AnimeFranchise>> _fetchAnimeCarousel(CarouselCategory category) {
    switch (category.type) {
      case CarouselType.trending:
        return _aniListService.fetchTrendingFranchises(perPage: 20);
      case CarouselType.comingSoon:
        return _aniListService.fetchComingSoonFranchises(perPage: 20);
      case CarouselType.mostPlayed:
        return _aniListService.fetchMostPopularFranchises(perPage: 20);
      case CarouselType.genre:
        return _aniListService.fetchByGenreFranchises(
          genre: category.value!,
          perPage: 20,
        );
      default:
        return _aniListService.searchAnimeFranchises();
    }
  }

  Widget _buildGameTab() {
    return RefreshIndicator(
      onRefresh: _refreshAllCarousels,
      child: ListView(
        controller: _gamesScrollController,
        padding: AppSpacing.paddingAll8,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        children: [
          OfflineRetryBanner(
            isVisible: _offlineMessage != null,
            message: _offlineMessage ?? '',
            onRetry: _refreshAllCarousels,
          ),
          AppSpacing.verticalSm,
          AppSpacing.verticalMd,
          ..._visibleGameCategories().map((category) {
            return Column(
              children: [
                FutureBuilder<List<Game>>(
                  future: _gameFutures[_categoryKey(category)],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CarouselSkeleton();
                    } else if (snapshot.hasError) {
                      return AppErrorWidget.withRetry(
                        message: 'Could not load ${category.title.toLowerCase()}.',
                        onRetry: () => _retryGameCarousel(category),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return EmptyStateWidget.simple(
                        message: 'No ${category.title.toLowerCase()} found.',
                      );
                    }

                    final games = snapshot.data!;
                    return ItemCarousel(
                      title: category.title,
                      items: games,
                      getName: (item) => (item as Game).name,
                      titlePadding: AppSpacing.paddingH8,
                      carouselHeight: 225,
                      itemWidth: 112,
                      itemImageHeight: 170,
                      itemHorizontalMargin: 4,
                    );
                  },
                ),
                AppSpacing.verticalMd,
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnimeTab() {
    return RefreshIndicator(
      onRefresh: _refreshAllCarousels,
      child: ListView(
        controller: _animeScrollController,
        padding: AppSpacing.paddingAll8,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        children: [
          OfflineRetryBanner(
            isVisible: _offlineMessage != null,
            message: _offlineMessage ?? '',
            onRetry: _refreshAllCarousels,
          ),
          AppSpacing.verticalSm,
          AppSpacing.verticalMd,
          ..._visibleAnimeCategories().map((category) {
            return Column(
              children: [
                FutureBuilder<List<AnimeFranchise>>(
                  future: _animeFutures[_categoryKey(category)],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CarouselSkeleton();
                    } else if (snapshot.hasError) {
                      return AppErrorWidget.withRetry(
                        message: 'Could not load ${category.title.toLowerCase()}.',
                        onRetry: () => _retryAnimeCarousel(category),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return EmptyStateWidget.simple(
                        message: 'No ${category.title.toLowerCase()} found.',
                      );
                    }

                    final franchises = snapshot.data!;
                    return ItemCarousel(
                      title: category.title,
                      items: franchises,
                      getName: (item) => (item as AnimeFranchise).title,
                      titlePadding: AppSpacing.paddingH8,
                      carouselHeight: 225,
                      itemWidth: 112,
                      itemImageHeight: 170,
                      itemHorizontalMargin: 4,
                    );
                  },
                ),
                AppSpacing.verticalMd,
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 38.0,
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Games'),
            Tab(text: 'Anime'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGameTab(),
          _buildAnimeTab(),
        ],
      ),
    );
  }
}

class _ExploreRestoredState {
  const _ExploreRestoredState({
    this.tabIndex = 0,
    this.gameOffset = 0,
    this.animeOffset = 0,
  });

  final int tabIndex;
  final double gameOffset;
  final double animeOffset;
}
