/// Official Dart/Flutter SDK for the Xeboki developer API.
///
/// ```dart
/// import 'package:xeboki/xeboki.dart';
///
/// final xeboki = XebokiClient(apiKey: 'xbk_live_...');
///
/// // POS
/// final orders = await xeboki.pos.listOrders(limit: 20, status: 'pending');
///
/// // Launchpad
/// final overview = await xeboki.launchpad.getOverview();
/// print('MRR: \$${overview.mrr}');
///
/// // Check rate limit after any call
/// print('Remaining: ${xeboki.lastRateLimit?.remaining}');
/// ```
library xeboki;

export 'src/client.dart';
