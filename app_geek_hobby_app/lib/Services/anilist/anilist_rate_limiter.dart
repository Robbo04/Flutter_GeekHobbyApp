import 'package:hive/hive.dart';

import 'anilist_exceptions.dart';

/// Handles rate limiting for AniList API requests
class AniListRateLimiter {
  /// AniList API rate limit (requests per minute)
  static const int minuteLimit = 90;
  
  int _sessionRequests = 0;
  DateTime? _lastRequestTime;
  final List<DateTime> _recentRequests = [];
  final Box<int> _statsBox;

  AniListRateLimiter(this._statsBox);

  // ==================== PUBLIC GETTERS ====================

  int get sessionRequests => _sessionRequests;
  
  DateTime? get lastRequestTime => _lastRequestTime;
  
  int get requestsLastMinute {
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    _recentRequests.removeWhere((time) => time.isBefore(oneMinuteAgo));
    return _recentRequests.length;
  }
  
  int get todayRequestsMade {
    final today = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    return _statsBox.get('requests_$today') ?? 0;
  }

  // ==================== METHODS ====================

  /// Check if current requests exceed rate limit, throw exception if so
  void checkRateLimit() {
    final currentRequests = requestsLastMinute;
    if (currentRequests >= minuteLimit) {
      throw AniListRateLimitException(
        message: 'AniList API rate limit reached ($currentRequests/$minuteLimit requests per minute). Please wait a moment before trying again.',
        requestsLastMinute: currentRequests,
        minuteLimit: minuteLimit,
      );
    }
  }

  /// Track an API request for rate limiting and statistics
  void trackRequest() {
    _sessionRequests++;
    final now = DateTime.now();
    _lastRequestTime = now;
    _recentRequests.add(now);

    // Track daily count
    final today = '${now.year}-${now.month}-${now.day}';
    final currentCount = _statsBox.get('requests_$today') ?? 0;
    _statsBox.put('requests_$today', currentCount + 1);

    // Clean up old requests (keep only last minute)
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _recentRequests.removeWhere((time) => time.isBefore(oneMinuteAgo));
  }
}
