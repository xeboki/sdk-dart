import '../http.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class QRResult {
  final String format;
  final String? base64;
  final String? svg;
  final bool watermarked;
  final int exportsUsed;

  QRResult.fromJson(Map<String, dynamic> j)
      : format      = j['format'],
        base64      = j['base64'],
        svg         = j['svg'],
        watermarked = j['watermarked'] ?? false,
        exportsUsed = j['exports_used'] ?? 0;
}

class BarcodeResult {
  final String format;
  final String base64;
  final bool watermarked;
  final int exportsUsed;

  BarcodeResult.fromJson(Map<String, dynamic> j)
      : format      = j['format'],
        base64      = j['base64'],
        watermarked = j['watermarked'] ?? false,
        exportsUsed = j['exports_used'] ?? 0;
}

class BatchQRResult {
  final int count;
  final List<Map<String, dynamic>> results;
  final int exportsUsed;

  BatchQRResult.fromJson(Map<String, dynamic> j)
      : count       = j['count'],
        results     = List<Map<String, dynamic>>.from(j['results']),
        exportsUsed = j['exports_used'] ?? 0;
}

class CodeUsage {
  final String plan;
  final int exportsUsed;
  final int? exportsLimit;
  final int? exportsRemaining;

  CodeUsage.fromJson(Map<String, dynamic> j)
      : plan             = j['plan'],
        exportsUsed      = j['exports_used'] ?? 0,
        exportsLimit     = j['exports_limit'],
        exportsRemaining = j['exports_remaining'];
}

class QRType {
  final String id, name, description;
  QRType.fromJson(Map<String, dynamic> j)
      : id          = j['id'],
        name        = j['name'],
        description = j['description'];
}

// ─── Client ───────────────────────────────────────────────────────────────────

class CodeClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;

  CodeClient(this._http, this._onRateLimit);

  /// Generate a single QR code. Returns base64 PNG or SVG.
  Future<QRResult> generateQR({
    required String data,
    String format = 'png',
    int scale = 10,
    String darkColor = '000000',
    String lightColor = 'ffffff',
  }) async {
    final (result, rl) = await _http.request('POST', '/v1/code/qr',
        body: {
          'data':        data,
          'format':      format,
          'scale':       scale,
          'dark_color':  darkColor,
          'light_color': lightColor,
        },
        fromJson: (j) => QRResult.fromJson(j));
    _onRateLimit(rl);
    return result;
  }

  /// Generate a linear barcode (Code 128, EAN-13, UPC-A, etc.).
  Future<BarcodeResult> generateBarcode({
    required String bcid,
    required String text,
    String format = 'png',
  }) async {
    final (result, rl) = await _http.request('POST', '/v1/code/barcode',
        body: {'bcid': bcid, 'text': text, 'format': format},
        fromJson: (j) => BarcodeResult.fromJson(j));
    _onRateLimit(rl);
    return result;
  }

  /// Batch-generate multiple QR codes. Requires Pro or Business plan.
  Future<BatchQRResult> batchQR({
    required List<String> dataItems,
    String format = 'png',
    int scale = 10,
    String darkColor = '000000',
    String lightColor = 'ffffff',
  }) async {
    final (result, rl) = await _http.request('POST', '/v1/code/batch/qr',
        body: {
          'items':       dataItems.map((d) => {'data': d}).toList(),
          'format':      format,
          'scale':       scale,
          'dark_color':  darkColor,
          'light_color': lightColor,
        },
        fromJson: (j) => BatchQRResult.fromJson(j));
    _onRateLimit(rl);
    return result;
  }

  /// Get current export usage for the authenticated API key.
  Future<CodeUsage> getUsage() async {
    final (result, rl) = await _http.request('GET', '/v1/code/usage',
        fromJson: (j) => CodeUsage.fromJson(j));
    _onRateLimit(rl);
    return result;
  }

  /// List all supported QR and barcode types.
  Future<List<QRType>> listTypes() async {
    final (result, rl) = await _http.request('GET', '/v1/code/types',
        fromJson: (j) => (j['qr_types'] as List).map((e) => QRType.fromJson(e)).toList());
    _onRateLimit(rl);
    return result;
  }
}
