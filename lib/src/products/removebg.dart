import '../http.dart';

class ProcessedImage {
  final String id, resultUrl, format, createdAt;
  final int width, height, creditsUsed;
  ProcessedImage.fromJson(Map<String, dynamic> j)
      : id = j['id'], resultUrl = j['result_url'], format = j['format'],
        createdAt = j['created_at'], width = j['width'], height = j['height'],
        creditsUsed = j['credits_used'];
}

class QuotaInfo {
  final String plan, resetsAt;
  final int creditsTotal, creditsUsed, creditsRemaining;
  QuotaInfo.fromJson(Map<String, dynamic> j)
      : plan = j['plan'], resetsAt = j['resets_at'],
        creditsTotal = j['credits_total'], creditsUsed = j['credits_used'],
        creditsRemaining = j['credits_remaining'];
}

class BatchJob {
  final String id, status, createdAt;
  final int totalImages, processedImages, failedImages;
  final String? completedAt;
  final List<Map<String, dynamic>>? results;
  BatchJob.fromJson(Map<String, dynamic> j)
      : id = j['id'], status = j['status'], createdAt = j['created_at'],
        totalImages = j['total_images'], processedImages = j['processed_images'],
        failedImages = j['failed_images'], completedAt = j['completed_at'],
        results = j['results'] != null
            ? List<Map<String, dynamic>>.from(j['results'])
            : null;
}

class RemoveBGClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  RemoveBGClient(this._http, this._onRateLimit);

  Future<ProcessedImage> process({String? imageUrl, String? imageBase64,
      String? outputFormat, String? bgColor}) async {
    final (data, rl) = await _http.request('POST', '/v1/removebg/process',
        body: {'image_url': imageUrl, 'image_base64': imageBase64,
               'output_format': outputFormat, 'bg_color': bgColor},
        fromJson: (j) => ProcessedImage.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<QuotaInfo> getQuota() async {
    final (data, rl) = await _http.request('GET', '/v1/removebg/quota',
        fromJson: (j) => QuotaInfo.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<BatchJob> submitBatch(List<Map<String, dynamic>> images, {String? outputFormat}) async {
    final (data, rl) = await _http.request('POST', '/v1/removebg/batch',
        body: {'images': images, 'output_format': outputFormat},
        fromJson: (j) => BatchJob.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<BatchJob> getBatch(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/removebg/batch/$id',
        fromJson: (j) => BatchJob.fromJson(j));
    _onRateLimit(rl);
    return data;
  }
}
