import 'dart:convert';
import 'package:http/http.dart' as http;
import 'error.dart';

class RateLimitInfo {
  final int limit;
  final int remaining;
  final int reset;
  final String requestId;

  const RateLimitInfo({
    required this.limit,
    required this.remaining,
    required this.reset,
    required this.requestId,
  });
}

class XebokiHttpClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  XebokiHttpClient({
    required this.apiKey,
    this.baseUrl = 'https://api.xeboki.com',
  }) : _client = http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<(T, RateLimitInfo)> request<T>(
    String method,
    String path, {
    Map<String, String?>? query,
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJson,
  }) async {
    final params = query?.entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!))
        .toList();

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: params != null && params.isNotEmpty
          ? Map.fromEntries(params)
          : null,
    );

    http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: _headers);
      case 'POST':
        response = await _client.post(uri,
            headers: _headers, body: body != null ? jsonEncode(body) : null);
      case 'PUT':
        response = await _client.put(uri,
            headers: _headers, body: body != null ? jsonEncode(body) : null);
      case 'PATCH':
        response = await _client.patch(uri,
            headers: _headers, body: body != null ? jsonEncode(body) : null);
      case 'DELETE':
        response = await _client.delete(uri, headers: _headers);
      default:
        throw XebokiError(status: 0, message: 'Unknown HTTP method: $method');
    }

    final requestId = response.headers['x-request-id'];
    final rateLimit = RateLimitInfo(
      limit: int.tryParse(response.headers['x-ratelimit-limit'] ?? '') ?? 0,
      remaining:
          int.tryParse(response.headers['x-ratelimit-remaining'] ?? '') ?? 0,
      reset: int.tryParse(response.headers['x-ratelimit-reset'] ?? '') ?? 0,
      requestId: requestId ?? '',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'HTTP ${response.statusCode}';
      int? retryAfter;
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = (decoded['detail'] ?? decoded['message'] ?? message).toString();
      } catch (_) {}
      if (response.statusCode == 429) {
        retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
      }
      throw XebokiError(
        status: response.statusCode,
        message: message,
        requestId: requestId,
        retryAfter: retryAfter,
      );
    }

    if (response.statusCode == 204 || response.body.isEmpty) {
      return (fromJson(null), rateLimit);
    }

    final decoded = jsonDecode(response.body);
    return (fromJson(decoded), rateLimit);
  }

  void close() => _client.close();
}
