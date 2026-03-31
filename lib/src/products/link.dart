import '../http.dart';
import 'pos.dart' show ListResponse;

class ShortLink {
  final String id, shortCode, shortUrl, destinationUrl, createdAt, updatedAt;
  final int clickCount;
  final bool isActive;
  final String? title;
  ShortLink.fromJson(Map<String, dynamic> j)
      : id = j['id'], shortCode = j['short_code'], shortUrl = j['short_url'],
        destinationUrl = j['destination_url'], createdAt = j['created_at'],
        updatedAt = j['updated_at'], clickCount = j['click_count'], isActive = j['is_active'],
        title = j['title'];
}

class LinkAnalytics {
  final String linkId;
  final int totalClicks, uniqueClicks;
  final List<Map<String, dynamic>> clicksByDay, topReferrers, topCountries;
  LinkAnalytics.fromJson(Map<String, dynamic> j)
      : linkId = j['link_id'], totalClicks = j['total_clicks'], uniqueClicks = j['unique_clicks'],
        clicksByDay = List<Map<String, dynamic>>.from(j['clicks_by_day'] ?? []),
        topReferrers = List<Map<String, dynamic>>.from(j['top_referrers'] ?? []),
        topCountries = List<Map<String, dynamic>>.from(j['top_countries'] ?? []);
}

class LinkClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  LinkClient(this._http, this._onRateLimit);

  Future<ListResponse<ShortLink>> listLinks({int? limit, int? offset}) async {
    final (data, rl) = await _http.request('GET', '/v1/link/links',
        query: {'limit': limit?.toString(), 'offset': offset?.toString()},
        fromJson: (j) => ListResponse<ShortLink>(
          data: (j['data'] as List).map((e) => ShortLink.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ShortLink> createLink(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/link/links',
        body: params, fromJson: (j) => ShortLink.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ShortLink> getLink(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/link/links/$id',
        fromJson: (j) => ShortLink.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ShortLink> updateLink(String id, Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('PATCH', '/v1/link/links/$id',
        body: params, fromJson: (j) => ShortLink.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<void> deleteLink(String id) async {
    final (_, rl) = await _http.request('DELETE', '/v1/link/links/$id',
        fromJson: (_) => null);
    _onRateLimit(rl);
  }

  Future<LinkAnalytics> getAnalytics(String id, {String? startDate, String? endDate}) async {
    final (data, rl) = await _http.request('GET', '/v1/link/analytics/$id',
        query: {'start_date': startDate, 'end_date': endDate},
        fromJson: (j) => LinkAnalytics.fromJson(j));
    _onRateLimit(rl);
    return data;
  }
}
