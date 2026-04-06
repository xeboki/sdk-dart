import 'http.dart';
import 'products/pos.dart';
import 'products/chat.dart';
import 'products/link.dart';
import 'products/removebg.dart';
import 'products/analytics.dart';
import 'products/account.dart';
import 'products/launchpad.dart';
import 'products/ordering.dart';
import 'products/developer.dart';

export 'error.dart';
export 'http.dart' show RateLimitInfo;
export 'products/pos.dart';
export 'products/chat.dart';
export 'products/link.dart';
export 'products/removebg.dart';
export 'products/analytics.dart';
export 'products/account.dart';
export 'products/launchpad.dart';
export 'products/ordering.dart';
export 'products/developer.dart';

/// Main entry point for the Xeboki SDK.
///
/// ```dart
/// final xeboki = XebokiClient(apiKey: 'xbk_live_...');
///
/// // POS admin
/// final orders = await xeboki.pos.listOrders(limit: 20);
///
/// // Customer-facing ordering app
/// final products = await xeboki.ordering.listProducts(limit: 20);
/// final auth = await xeboki.ordering.loginCustomer(email: '...', password: '...');
///
/// // Manage API keys and webhooks (admin only)
/// final newKey = await xeboki.developer.createApiKey(
///   name: 'Mobile Storefront', scopes: ['pos:read']);
///
/// print(xeboki.lastRateLimit?.remaining);
/// ```
class XebokiClient {
  late final PosClient pos;
  late final OrderingClient ordering;
  late final ChatClient chat;
  late final LinkClient link;
  late final RemoveBGClient removebg;
  late final AnalyticsClient analytics;
  late final AccountClient account;
  late final LaunchpadClient launchpad;
  late final DeveloperClient developer;

  final XebokiHttpClient _http;
  RateLimitInfo? _lastRateLimit;

  /// Rate limit info from the most recent API call.
  RateLimitInfo? get lastRateLimit => _lastRateLimit;

  XebokiClient({
    required String apiKey,
    String baseUrl = 'https://api.xeboki.com',
  }) : _http = XebokiHttpClient(apiKey: apiKey, baseUrl: baseUrl) {
    void onRateLimit(RateLimitInfo info) => _lastRateLimit = info;
    pos       = PosClient(_http, onRateLimit);
    ordering  = OrderingClient(_http, onRateLimit);
    chat      = ChatClient(_http, onRateLimit);
    link      = LinkClient(_http, onRateLimit);
    removebg  = RemoveBGClient(_http, onRateLimit);
    analytics = AnalyticsClient(_http, onRateLimit);
    account   = AccountClient(_http, onRateLimit);
    launchpad = LaunchpadClient(_http, onRateLimit);
    developer = DeveloperClient(_http, onRateLimit);
  }

  /// Release underlying HTTP client resources.
  void close() => _http.close();
}
