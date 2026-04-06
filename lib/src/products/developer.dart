import '../http.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ApiKey {
  final String id;
  final String name;
  final String keyPrefix;
  final List<String> scopes;
  final List<String>? locationIds;
  final bool isActive;
  final String createdAt;
  final String? expiresAt;
  final String? lastUsedAt;

  ApiKey.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['name'],
        keyPrefix = j['key_prefix'],
        scopes = List<String>.from(j['scopes'] ?? []),
        locationIds = j['location_ids'] != null
            ? List<String>.from(j['location_ids'])
            : null,
        isActive = j['is_active'] ?? true,
        createdAt = j['created_at'],
        expiresAt = j['expires_at'],
        lastUsedAt = j['last_used_at'];
}

class CreatedApiKey extends ApiKey {
  /// Full key — returned ONCE at creation, never stored server-side.
  final String key;
  final String warning;

  CreatedApiKey.fromJson(Map<String, dynamic> j)
      : key = j['key'],
        warning = j['warning'] ?? '',
        super.fromJson(j);
}

class Webhook {
  final String id;
  final String url;
  final List<String> events;
  final String? description;
  final bool isActive;
  final String secretPrefix;
  final String createdAt;
  final String? lastTriggeredAt;
  final int failureCount;

  Webhook.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        url = j['url'],
        events = List<String>.from(j['events'] ?? []),
        description = j['description'],
        isActive = j['is_active'] ?? true,
        secretPrefix = j['secret_prefix'] ?? '',
        createdAt = j['created_at'],
        lastTriggeredAt = j['last_triggered_at'],
        failureCount = j['failure_count'] ?? 0;
}

// ─── Client ───────────────────────────────────────────────────────────────────

/// Manage API keys and webhook endpoints for a subscriber.
///
/// Requires a POS JWT issued to an admin-role user.
/// All calls are scoped to the authenticated subscriber.
///
/// ```dart
/// final xeboki = XebokiClient(apiKey: 'xbk_live_...');
///
/// // List API keys
/// final keys = await xeboki.developer.listApiKeys();
///
/// // Create a key
/// final newKey = await xeboki.developer.createApiKey(
///   name: 'Mobile Storefront',
///   scopes: ['pos:read', 'orders:write'],
/// );
/// print(newKey.key); // Store securely — shown once only
///
/// // Register a webhook
/// final hook = await xeboki.developer.registerWebhook(
///   url: 'https://example.com/webhooks/xeboki',
///   events: ['order.created', 'order.status_changed'],
/// );
/// ```
class DeveloperClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;

  DeveloperClient(this._http, this._onRateLimit);

  // ── API Keys ──────────────────────────────────────────────────────────────

  Future<List<ApiKey>> listApiKeys() async {
    final (data, rl) = await _http.request('GET', '/v1/developer/api-keys',
        fromJson: (j) => (j as List).map((e) => ApiKey.fromJson(e)).toList());
    _onRateLimit(rl);
    return data;
  }

  Future<CreatedApiKey> createApiKey({
    required String name,
    required List<String> scopes,
    List<String>? locationIds,
    String? expiresAt,
  }) async {
    final (data, rl) = await _http.request('POST', '/v1/developer/api-keys',
        body: {
          'name': name,
          'scopes': scopes,
          if (locationIds != null) 'location_ids': locationIds,
          if (expiresAt != null) 'expires_at': expiresAt,
        },
        fromJson: (j) => CreatedApiKey.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<void> revokeApiKey(String keyId) async {
    final (_, rl) = await _http.request('DELETE',
        '/v1/developer/api-keys/$keyId',
        fromJson: (_) => null);
    _onRateLimit(rl);
  }

  // ── Webhooks ──────────────────────────────────────────────────────────────

  Future<List<Webhook>> listWebhooks() async {
    final (data, rl) = await _http.request('GET', '/v1/developer/webhooks',
        fromJson: (j) =>
            (j as List).map((e) => Webhook.fromJson(e)).toList());
    _onRateLimit(rl);
    return data;
  }

  Future<Webhook> registerWebhook({
    required String url,
    required List<String> events,
    String? description,
  }) async {
    final (data, rl) = await _http.request('POST', '/v1/developer/webhooks',
        body: {
          'url': url,
          'events': events,
          if (description != null) 'description': description,
        },
        fromJson: (j) => Webhook.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<void> deleteWebhook(String webhookId) async {
    final (_, rl) = await _http.request(
        'DELETE', '/v1/developer/webhooks/$webhookId',
        fromJson: (_) => null);
    _onRateLimit(rl);
  }

  Future<Map<String, dynamic>> testWebhook(
    String webhookId, {
    String event = 'order.created',
  }) async {
    final (data, rl) = await _http.request(
        'POST', '/v1/developer/webhooks/$webhookId/test',
        body: {'event': event},
        fromJson: (j) => Map<String, dynamic>.from(j));
    _onRateLimit(rl);
    return data;
  }

  // ── Discovery ─────────────────────────────────────────────────────────────

  Future<List<String>> listScopes() async {
    final (data, rl) = await _http.request('GET', '/v1/developer/scopes',
        fromJson: (j) => List<String>.from(j['scopes']));
    _onRateLimit(rl);
    return data;
  }

  Future<List<String>> listEvents() async {
    final (data, rl) = await _http.request('GET', '/v1/developer/events',
        fromJson: (j) => List<String>.from(j['events']));
    _onRateLimit(rl);
    return data;
  }
}
