/// Dynamic carousel categories for the Explore page
/// 
/// Add category names that will be used to search/filter items from APIs
/// The Explore page will automatically fetch items matching these categories

class ExploreCarousels {
  // Each carousel configuration
  static const List<CarouselCategory> gameCarousels = [
    CarouselCategory(title: '🎮 Trending Now', type: CarouselType.trending),
    CarouselCategory(title: '🎮 Coming Soon', type: CarouselType.comingSoon),
    CarouselCategory(title: '🎮 Most Popular Games', type: CarouselType.mostPlayed),
    CarouselCategory(title: '🎮 Horror Games', type: CarouselType.tag, value: 'survival-horror'),
    CarouselCategory(title: '🎮 Free to Play', type: CarouselType.tag, value: 'free-to-play'),
    CarouselCategory(title: '🎮 Indie Games', type: CarouselType.genre, value: 'indie'),
    CarouselCategory(title: '🎮 RPG', type: CarouselType.genre, value: 'role-playing-games-rpg'),
    CarouselCategory(title: '🎮 Action', type: CarouselType.genre, value: 'action'),
  ];

  static const List<CarouselCategory> animeCarousels = [
    CarouselCategory(title: '📺 Trending Anime', type: CarouselType.trending),
    CarouselCategory(title: '📺 Coming Soon', type: CarouselType.comingSoon),
    CarouselCategory(title: '📺 Most Popular Anime', type: CarouselType.mostPlayed),
    CarouselCategory(title: '📺 Action Anime', type: CarouselType.genre, value: 'Action'),
    CarouselCategory(title: '📺 Comedy Anime', type: CarouselType.genre, value: 'Comedy'),
    CarouselCategory(title: '📺 Romance Anime', type: CarouselType.genre, value: 'Romance'),
    CarouselCategory(title: '📺 Sci-Fi Anime', type: CarouselType.genre, value: 'Sci-Fi'),
  ];
}

/// Carousel category configuration
class CarouselCategory {
  final String title;           // Display name for the carousel
  final CarouselType type;      // Type of category (trending, genre, tag, etc.)
  final String? value;          // API value for the category (genre slug, tag, etc.)

  const CarouselCategory({
    required this.title,
    required this.type,
    this.value,
  });
}

/// Types of carousel categories
enum CarouselType {
  trending,    // Fetch trending items (recent popularity)
  comingSoon,  // Fetch upcoming/unreleased items
  mostPlayed,  // Fetch all-time most popular items
  genre,       // Filter by genre
  tag,         // Filter by tag
  search,      // Search by keyword
}
