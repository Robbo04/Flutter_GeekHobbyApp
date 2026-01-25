import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';
import 'package:app_geek_hobby_app/Services/collections_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Pages/anime_group_detail.dart';
import 'package:hive/hive.dart';

class AnimeDisplay extends StatefulWidget {
  final Anime anime;

  const AnimeDisplay({super.key, required this.anime});

  @override
  State<AnimeDisplay> createState() => _AnimeDisplayState();
}

class _AnimeDisplayState extends State<AnimeDisplay> {
  bool watched = false;
  late bool wishlisted;
  late int userRating;
  final _anilistService = AniListService.instance;
  bool _isInGroup = false;
  Map<String, dynamic>? _groupSummary;

  @override
  void initState() {
    super.initState();
    wishlisted = widget.anime.wishlist;
    userRating = widget.anime.userRating;
    _loadCollectionStatus();
    _checkGroupStatus();
  }

  void _checkGroupStatus() {
    final isInGroup = _anilistService.isInGroup(widget.anime.id);
    if (isInGroup) {
      final summary = _anilistService.getGroupSummary(widget.anime.id);
      setState(() {
        _isInGroup = true;
        _groupSummary = summary;
      });
    }
  }

  void _loadCollectionStatus() async {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    final isWatched = watchedBox.containsKey(widget.anime.id);
    if (mounted) {
      setState(() {
        watched = isWatched;
      });
    }
  }

  void updateWatched(bool value) async {
    debugPrint('updateWatched called with value: $value, anime id: ${widget.anime.id}');
    setState(() {
      watched = value;
      if (watched) wishlisted = false;
      widget.anime.wishlist = wishlisted;
    });

    try {
      if (value) {
        await CollectionsService.instance.addAnimeToWatched(widget.anime, removeFromWishlist: true);
        debugPrint('Successfully added to watched collection');
      } else {
        await CollectionsService.instance.removeAnimeFromWatched(widget.anime);
        debugPrint('Successfully removed from watched collection');
      }
    } catch (e, st) {
      debugPrint('CollectionsService watched error: $e\n$st');
      setState(() {
        watched = !value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update watched: $e')),
        );
      }
    }
  }

  void updateWishlist(bool value) async {
    debugPrint('updateWishlist called with value: $value, anime id: ${widget.anime.id}');
    setState(() {
      wishlisted = value;
      widget.anime.wishlist = wishlisted;
    });

    try {
      if (value) {
        await CollectionsService.instance.addAnimeToWishlist(widget.anime);
        debugPrint('Successfully added to wishlist collection');
      } else {
        await CollectionsService.instance.removeAnimeFromWishlist(widget.anime);
        debugPrint('Successfully removed from wishlist collection');
      }
    } catch (e, st) {
      debugPrint('CollectionsService wishlist error: $e\n$st');
      setState(() {
        wishlisted = !value;
        widget.anime.wishlist = wishlisted;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update wishlist: $e')),
        );
      }
    }
  }

  void updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.anime.userRating = rating;
    });
    await widget.anime.save();
  }

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Anime details",
      imageUrl: widget.anime.imageUrl,
      details: [
        Text(widget.anime.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // GROUP INDICATOR BUTTON
        if (_isInGroup && _groupSummary != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeGroupDetailPage(
                      animeId: widget.anime.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.collections_bookmark),
              label: Text(
                'Part of ${_groupSummary!['name']} Collection (${_groupSummary!['itemCount']} items)',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 219, 167, 227),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        
        Text(widget.anime.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.anime.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Runtime: ${widget.anime.runtime} minutes", style: const TextStyle(fontSize: 16)),
        Text("Seasons: ${widget.anime.seasons}", style: const TextStyle(fontSize: 16)),
        Text("Episodes: ${widget.anime.episodes}", style: const TextStyle(fontSize: 16)),
      ],
      owned: watched,
      wishlisted: wishlisted,
      onOwnedChanged: updateWatched,
      onWishlistChanged: updateWishlist,
      userRating: userRating,
      onUserRatingChanged: updateUserRating,
      ownedLabel: 'Watched', // Custom label for anime
    );
  }
}