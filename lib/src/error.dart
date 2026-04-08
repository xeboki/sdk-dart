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

/// Thrown when the API returns a 403 with a structured subscription error code.
///
/// Codes returned by the server:
///   `subscription_required`    — no active subscription
///   `free_plan_not_supported`  — subscriber is on the free tier
///   `ordering_app_not_in_plan` — paid plan does not include the Ordering App
class XebokiSubscriptionError implements Exception {
  final String code;
  final String message;
  final String? requestId;

  const XebokiSubscriptionError({
    required this.code,
    required this.message,
    this.requestId,
  });

  static const _codeToStatus = <String, XebokiSubscriptionCode>{
    'subscription_required':    XebokiSubscriptionCode.noSubscription,
    'free_plan_not_supported':  XebokiSubscriptionCode.freePlanBlocked,
    'ordering_app_not_in_plan': XebokiSubscriptionCode.featureNotInPlan,
  };

  /// Maps the server-side error code to a typed enum value.
  XebokiSubscriptionCode get subscriptionCode =>
      _codeToStatus[code] ?? XebokiSubscriptionCode.noSubscription;

  @override
  String toString() => 'XebokiSubscriptionError($code): $message';
}

/// Typed subscription block reason returned by [XebokiSubscriptionError].
enum XebokiSubscriptionCode {
  noSubscription,   // subscription_required
  freePlanBlocked,  // free_plan_not_supported
  featureNotInPlan, // ordering_app_not_in_plan
}
