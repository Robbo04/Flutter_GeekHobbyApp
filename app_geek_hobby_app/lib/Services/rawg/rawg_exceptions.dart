/// Exception thrown when RAWG API rate limit is exceeded
class RawgRateLimitException implements Exception {
  final String message;
  final int remainingRequests;
  final int monthlyLimit;

  RawgRateLimitException({
    required this.message,
    required this.remainingRequests,
    required this.monthlyLimit,
  });

  @override
  String toString() => message;
}
