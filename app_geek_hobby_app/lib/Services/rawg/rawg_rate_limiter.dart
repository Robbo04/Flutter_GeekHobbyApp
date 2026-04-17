import 'package:hive/hive.dart';

import 'rawg_exceptions.dart';

/// Handles RAWG API rate limiting (20,000 requests per month)
class RawgRateLimiter {
  /// RAWG API free tier monthly limit
  static const int monthlyLimit = 20000;

  final Box<int> _statsBox;

  int _sessionRequests = 0;
  DateTime? _lastRequestTime;

  RawgRateLimiter(this._statsBox);

  // ==================== PUBLIC GETTERS ====================

  int get sessionRequests => _sessionRequests;

  DateTime? get lastRequestTime => _lastRequestTime;

  int get monthlyRequestsMade {
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    return _statsBox.get('requests_$currentMonth') ?? 0;
  }

  int get monthlyRequestsRemaining =>
      (monthlyLimit - monthlyRequestsMade).clamp(0, monthlyLimit);

  double get usagePercentage =>
      (monthlyRequestsMade / monthlyLimit * 100).clamp(0, 100);

  // ==================== METHODS ====================

  /// Check if rate limit has been exceeded, throws exception if so
  void checkRateLimit() {
    if (monthlyRequestsRemaining <= 0) {
      throw RawgRateLimitException(
        message:
            'RAWG API monthly limit reached ($monthlyLimit requests). Limit resets at the start of next month.',
        remainingRequests: monthlyRequestsRemaining,
        monthlyLimit: monthlyLimit,
      );
    }
  }

  /// Track a request (call after successful API call)
  void trackRequest() {
    _sessionRequests++;
    _lastRequestTime = DateTime.now();

    // Track monthly count
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    final currentCount = _statsBox.get('requests_$currentMonth') ?? 0;
    _statsBox.put('requests_$currentMonth', currentCount + 1);
  }
}
