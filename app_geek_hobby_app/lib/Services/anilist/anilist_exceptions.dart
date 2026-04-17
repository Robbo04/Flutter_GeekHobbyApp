/// Exception thrown when AniList API rate limit is exceeded
class AniListRateLimitException implements Exception {
  final String message;
  final int requestsLastMinute;
  final int minuteLimit;
  
  AniListRateLimitException({
    required this.message,
    required this.requestsLastMinute,
    required this.minuteLimit,
  });
  
  @override
  String toString() => message;
}
