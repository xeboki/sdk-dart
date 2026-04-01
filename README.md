# xeboki

Official Dart and Flutter SDK for the [Xeboki developer API](https://developers.xeboki.com). Supports all Dart platforms — Flutter (iOS, Android, Web, Desktop) and pure Dart server/CLI.

[![pub.dev](https://img.shields.io/pub/v/xeboki)](https://pub.dev/packages/xeboki)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Requirements

- Dart SDK 3.0 or later
- Flutter 3.10 or later (if using with Flutter)

## Installation

```yaml
# pubspec.yaml
dependencies:
  xeboki: ^1.0.0
```

Then run:

```bash
dart pub get
# or
flutter pub get
```

## Quick Start

```dart
import 'package:xeboki/xeboki.dart';

void main() async {
  final xeboki = XebokiClient(apiKey: 'xbk_live_...');

  // List the last 20 orders from your POS
  final response = await xeboki.pos.listOrders(limit: 20);
  print(response.data);

  // Check rate limit after any call
  final rl = xeboki.lastRateLimit;
  if (rl != null) {
    print('${rl.remaining}/${rl.limit} requests remaining');
  }

  xeboki.close();
}
```

## Authentication

Generate and manage API keys at [account.xeboki.com/developer](https://account.xeboki.com/developer).

| Key prefix     | Environment |
|----------------|-------------|
| `xbk_live_...` | Production  |
| `xbk_test_...` | Sandbox     |

**Never embed API keys directly in Flutter apps shipped to end users.** Use `--dart-define`, environment variables, or a secrets management system. Use `xbk_test_` keys during development.

## Client Configuration

```dart
// Simple
final xeboki = XebokiClient(apiKey: 'xbk_live_...');

// Custom base URL (e.g. self-hosted gateway)
final xeboki = XebokiClient(
  apiKey: 'xbk_live_...',
  baseUrl: 'https://api.yourcompany.com',
);
```

---

## Products

### `pos` — Point of Sale

Manage orders, products, inventory, customers, and sales reports.

#### Orders

```dart
// List orders with filters
final result = await xeboki.pos.listOrders(
  limit:      50,
  offset:     0,
  status:     'completed',
  locationId: 'loc_abc',
  startDate:  '2026-01-01',
  endDate:    '2026-03-31',
);
// result.data: List<Order>
// result.total: int

// Get a single order
final order = await xeboki.pos.getOrder('ord_abc123');
print('${order.orderNumber}: \$${order.total}');

// Create an order
final newOrder = await xeboki.pos.createOrder(
  locationId:    'loc_abc',
  paymentMethod: 'cash',
  items: [
    OrderItemRequest(productId: 'prod_1', quantity: 2),
    OrderItemRequest(
      productId: 'prod_2',
      quantity:  1,
      modifiers: [ModifierRequest(modifierId: 'mod_oat')],
    ),
  ],
  customerId: 'cust_xyz',
  discount:   5.00,
  notes:      'No ice please',
);
```

**`Order` fields**

| Field           | Type     | Description                                              |
|-----------------|----------|----------------------------------------------------------|
| `id`            | `String` | Unique order ID                                          |
| `orderNumber`   | `String` | Human-readable order number                              |
| `status`        | `String` | `pending`, `processing`, `completed`, `cancelled`, `refunded` |
| `items`         | `List<OrderItem>` | Line items                                      |
| `subtotal`      | `double` | Pre-tax, pre-discount total                              |
| `tax`           | `double` | Tax amount                                               |
| `discount`      | `double` | Discount applied                                         |
| `total`         | `double` | Final charged amount                                     |
| `locationId`    | `String` | Location that processed the order                        |
| `employeeId`    | `String` | Employee who processed the order                         |
| `paymentMethod` | `String` | Payment method used                                      |
| `createdAt`     | `String` | ISO 8601 timestamp                                       |

#### Products

```dart
// List products
final products = await xeboki.pos.listProducts(
  locationId: 'loc_abc',
  isActive:   true,
  search:     'espresso',
  limit:      100,
);

// Create a product
final product = await xeboki.pos.createProduct(
  name:           'Flat White',
  price:          4.50,
  locationId:     'loc_abc',
  taxRate:        0.10,
  trackInventory: true,
  categoryId:     'cat_coffee',
);

// Update a product
final updated = await xeboki.pos.updateProduct(
  'prod_abc',
  price: 4.75,
);
```

#### Inventory

```dart
// List inventory
final inventory = await xeboki.pos.listInventory(
  locationId:   'loc_abc',
  lowStockOnly: true,
);

// Adjust stock level
final item = await xeboki.pos.updateInventory(
  'inv_abc',
  quantity: 50,
  reason:   'restock',
  notes:    'Weekly delivery',
);
```

#### Customers

```dart
// Search customers
final customers = await xeboki.pos.listCustomers(
  search: 'jane',
  limit:  20,
);

// Create a customer
final customer = await xeboki.pos.createCustomer(
  name:  'Jane Doe',
  email: 'jane@example.com',
  phone: '+1-555-0100',
);
```

#### Sales Report

```dart
final report = await xeboki.pos.getSalesReport(
  startDate:  '2026-03-01',
  endDate:    '2026-03-31',
  locationId: 'loc_abc',
);
print('Revenue: \$${report.totalRevenue}');
print('Avg order: \$${report.averageOrderValue}');
print('Top products: ${report.topProducts}');
```

---

### `chat` — Customer Support

Manage conversations, messages, agents, contacts, and inboxes.

```dart
// List open conversations
final conversations = await xeboki.chat.listConversations(
  status:  'open',
  inboxId: 'inbox_web',
);

// Send a message
final message = await xeboki.chat.sendMessage(
  'conv_abc',
  content: 'How can I help you today?',
);

// Resolve a conversation
await xeboki.chat.updateConversation('conv_abc', status: 'resolved');

// Create a contact
final contact = await xeboki.chat.createContact(
  name:    'Alex Smith',
  email:   'alex@example.com',
  company: 'Acme Corp',
);

// List available agents
final agents = await xeboki.chat.listAgents(isAvailable: true);

// List inboxes
final inboxes = await xeboki.chat.listInboxes();
```

**Supported channels:** `web` · `email` · `sms` · `whatsapp` · `instagram` · `twitter`

---

### `link` — URL Shortener

```dart
// Create a short link
final link = await xeboki.link.createLink(
  destinationUrl: 'https://yoursite.com/campaign',
  title:          'Summer Sale',
  customCode:     'summer26',
  tags:           ['marketing', 'q2'],
);
print(link.shortUrl);  // https://xbk.io/summer26

// List links
final links = await xeboki.link.listLinks(
  isActive: true,
  tag:      'marketing',
);

// Get analytics
final analytics = await xeboki.link.getAnalytics(
  'lnk_abc',
  startDate: '2026-03-01',
  endDate:   '2026-03-31',
);
print('Clicks: ${analytics.totalClicks}');
print('Top countries: ${analytics.topCountries}');

// Update or delete
await xeboki.link.updateLink('lnk_abc', isActive: false);
await xeboki.link.deleteLink('lnk_abc');
```

---

### `removebg` — Background Removal

```dart
// Submit a background removal job
final job = await xeboki.removebg.removeBackground(
  imageUrl:     'https://example.com/photo.jpg',
  outputFormat: 'png',
);

// Poll until complete
final result = await xeboki.removebg.getJob(job.jobId);
if (result.status == 'completed') {
  print(result.resultUrl);
}
```

---

### `analytics` — Cross-Product Analytics

```dart
// List available reports
final reports = await xeboki.analytics.listReports(product: 'pos');

// Run a report
final data = await xeboki.analytics.getReport(
  'rep_revenue_daily',
  startDate: '2026-01-01',
  endDate:   '2026-03-31',
  groupBy:   'month',
);
print(data.summary);

// Export to CSV
final export = await xeboki.analytics.exportReport(
  reportId:  'rep_revenue_daily',
  format:    'csv',
  startDate: '2026-01-01',
  endDate:   '2026-03-31',
);
```

---

### `account` — Account Management

```dart
final account = await xeboki.account.getAccount();
final usage   = await xeboki.account.getUsage();
print('${usage.pos.used} / ${usage.pos.limit}');

// Create a webhook
await xeboki.account.createWebhook(
  url:    'https://yourserver.com/webhooks',
  events: ['order.completed', 'conversation.created'],
);

// Create an API key
final key = await xeboki.account.createApiKey(
  name:   'Flutter Production',
  scopes: ['pos:read', 'pos:write'],
);
print(key.key);  // shown only once
```

---

### `launchpad` — App Distribution

```dart
final apps = await xeboki.launchpad.listApps();

final release = await xeboki.launchpad.createRelease(
  'app_abc',
  version:      '2.4.0',
  releaseNotes: 'Performance improvements.',
  downloadUrl:  'https://cdn.example.com/app-2.4.0.apk',
  platform:     'android',
);
```

---

## Error Handling

All SDK methods throw `XebokiException` on non-2xx HTTP responses.

```dart
import 'package:xeboki/xeboki.dart';

try {
  final order = await xeboki.pos.createOrder(...);
} on XebokiException catch (e) {
  print('Status:     ${e.status}');
  print('Message:    ${e.message}');
  print('Request ID: ${e.requestId}');  // include in support tickets

  if (e.status == 429 && e.retryAfter != null) {
    print('Rate limited — retry after ${e.retryAfter}s');
  }
} catch (e) {
  print('Network or unexpected error: $e');
}
```

**`XebokiException` properties**

| Property     | Type      | Description                                              |
|--------------|-----------|----------------------------------------------------------|
| `status`     | `int`     | HTTP status code                                         |
| `message`    | `String`  | Human-readable error description                         |
| `requestId`  | `String?` | Unique request ID — include in support tickets           |
| `retryAfter` | `int?`    | Seconds to wait before retrying (only present on 429)    |

**Common status codes**

| Status | Meaning                                           |
|--------|---------------------------------------------------|
| `400`  | Bad request — check your parameters               |
| `401`  | Invalid or missing API key                        |
| `403`  | Insufficient scope / permissions                  |
| `404`  | Resource not found                                |
| `422`  | Validation error                                  |
| `429`  | Rate limit exceeded — check `retryAfter`          |
| `500`  | Server error — retry with exponential back-off    |

---

## Rate Limiting

Each product has its own daily request quota. The SDK surfaces live counters via `lastRateLimit` after every call.

```dart
final orders = await xeboki.pos.listOrders();

final rl = xeboki.lastRateLimit;
if (rl != null) {
  print('${rl.remaining} / ${rl.limit} requests remaining today');
  final resetAt = DateTime.fromMillisecondsSinceEpoch(rl.reset * 1000, isUtc: true);
  print('Resets at $resetAt');
}
```

**`RateLimitInfo` properties**

| Property    | Type     | Description                                    |
|-------------|----------|------------------------------------------------|
| `limit`     | `int`    | Daily request quota for this product           |
| `remaining` | `int`    | Requests remaining today                       |
| `reset`     | `int`    | Unix timestamp (UTC) when the counter resets   |
| `requestId` | `String` | ID of the most recent request                  |

---

## Resource Management

Call `xeboki.close()` to release the underlying HTTP client when you no longer need the SDK instance. For Flutter apps this is typically in `dispose()`.

```dart
class _MyWidgetState extends State<MyWidget> {
  late final XebokiClient _xeboki;

  @override
  void initState() {
    super.initState();
    _xeboki = XebokiClient(apiKey: const String.fromEnvironment('XEBOKI_API_KEY'));
  }

  @override
  void dispose() {
    _xeboki.close();
    super.dispose();
  }
}
```

---

## Flutter Usage

The SDK has no Flutter-specific dependencies and works on all Flutter platforms — iOS, Android, Web, macOS, Windows, and Linux.

### Riverpod integration

```dart
final xebokiProvider = Provider<XebokiClient>((ref) {
  final client = XebokiClient(apiKey: const String.fromEnvironment('XEBOKI_API_KEY'));
  ref.onDispose(client.close);
  return client;
});

final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final xeboki = ref.watch(xebokiProvider);
  final result = await xeboki.pos.listOrders(limit: 20);
  return result.data;
});
```

### Provider pattern

```dart
// main.dart
void main() {
  runApp(
    Provider<XebokiClient>(
      create: (_) => XebokiClient(apiKey: const String.fromEnvironment('XEBOKI_API_KEY')),
      dispose: (_, client) => client.close(),
      child: const MyApp(),
    ),
  );
}
```

---

## Support

- **Documentation:** [developers.xeboki.com](https://developers.xeboki.com)
- **Issues:** [github.com/xeboki/sdk-dart/issues](https://github.com/xeboki/sdk-dart/issues)
- **Email:** developers@xeboki.com

Include the `requestId` from `XebokiException` in all support requests.

## License

MIT
