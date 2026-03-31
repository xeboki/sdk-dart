/// Thrown when the Xeboki API returns a non-2xx response.
class XebokiError implements Exception {
  final int status;
  final String message;
  final String? requestId;
  final int? retryAfter;

  const XebokiError({
    required this.status,
    required this.message,
    this.requestId,
    this.retryAfter,
  });

  @override
  String toString() => 'XebokiError($status): $message'
      '${requestId != null ? ' [request: $requestId]' : ''}';
}
