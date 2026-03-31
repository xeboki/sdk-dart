import '../http.dart';
import 'pos.dart' show ListResponse;

class AnalyticsReport {
  final String id, name, product, createdAt;
  final String? description;
  final List<String> metrics, availableGranularities;
  AnalyticsReport.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], product = j['product'], createdAt = j['created_at'],
        description = j['description'],
        metrics = List<String>.from(j['metrics'] ?? []),
        availableGranularities = List<String>.from(j['available_granularities'] ?? []);
}

class ExportResult {
  final String exportId, downloadUrl, format, expiresAt;
  ExportResult.fromJson(Map<String, dynamic> j)
      : exportId = j['export_id'], downloadUrl = j['download_url'],
        format = j['format'], expiresAt = j['expires_at'];
}

class AnalyticsClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  AnalyticsClient(this._http, this._onRateLimit);

  Future<ListResponse<AnalyticsReport>> listReports({String? product}) async {
    final (data, rl) = await _http.request('GET', '/v1/analytics/reports',
        query: {'product': product},
        fromJson: (j) => ListResponse<AnalyticsReport>(
          data: (j['data'] as List).map((e) => AnalyticsReport.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Map<String, dynamic>> getReport(String id, {
    String? startDate, String? endDate, String? granularity,
  }) async {
    final (data, rl) = await _http.request('GET', '/v1/analytics/reports/$id',
        query: {'start_date': startDate, 'end_date': endDate, 'granularity': granularity},
        fromJson: (j) => Map<String, dynamic>.from(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ExportResult> exportReport(String reportId, String format, {
    String? startDate, String? endDate,
  }) async {
    final (data, rl) = await _http.request('POST', '/v1/analytics/reports/export',
        body: {'report_id': reportId, 'format': format,
               'start_date': startDate, 'end_date': endDate},
        fromJson: (j) => ExportResult.fromJson(j));
    _onRateLimit(rl);
    return data;
  }
}
