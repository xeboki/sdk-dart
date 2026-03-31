import '../http.dart';
import 'pos.dart' show ListResponse;

class LaunchpadCustomer {
  final String id, name, email, createdAt, updatedAt;
  final String? phone;
  LaunchpadCustomer.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], email = j['email'],
        createdAt = j['created_at'], updatedAt = j['updated_at'], phone = j['phone'];
}

class Plan {
  final String id, name, currency, interval, createdAt;
  final double price;
  final int intervalCount, trialDays;
  final bool isActive;
  final List<String> features;
  final String? description;
  Plan.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], currency = j['currency'],
        interval = j['interval'], createdAt = j['created_at'],
        price = (j['price'] as num).toDouble(), intervalCount = j['interval_count'],
        trialDays = j['trial_days'], isActive = j['is_active'],
        features = List<String>.from(j['features'] ?? []), description = j['description'];
}

class LaunchpadSubscription {
  final String id, customerId, planId, planName, status, currentPeriodStart, currentPeriodEnd, createdAt;
  final bool cancelAtPeriodEnd;
  final String? trialEnd;
  LaunchpadSubscription.fromJson(Map<String, dynamic> j)
      : id = j['id'], customerId = j['customer_id'], planId = j['plan_id'],
        planName = j['plan_name'], status = j['status'],
        currentPeriodStart = j['current_period_start'],
        currentPeriodEnd = j['current_period_end'], createdAt = j['created_at'],
        cancelAtPeriodEnd = j['cancel_at_period_end'] ?? false, trialEnd = j['trial_end'];
}

class LaunchpadInvoice {
  final String id, customerId, currency, status, createdAt;
  final double amount;
  final String? subscriptionId, pdfUrl, paidAt;
  LaunchpadInvoice.fromJson(Map<String, dynamic> j)
      : id = j['id'], customerId = j['customer_id'], currency = j['currency'],
        status = j['status'], createdAt = j['created_at'],
        amount = (j['amount'] as num).toDouble(),
        subscriptionId = j['subscription_id'], pdfUrl = j['pdf_url'], paidAt = j['paid_at'];
}

class Coupon {
  final String id, code, discountType, createdAt;
  final double discountValue;
  final int timesRedeemed;
  final bool isActive;
  final int? maxRedemptions;
  final String? expiresAt;
  Coupon.fromJson(Map<String, dynamic> j)
      : id = j['id'], code = j['code'], discountType = j['discount_type'],
        createdAt = j['created_at'], discountValue = (j['discount_value'] as num).toDouble(),
        timesRedeemed = j['times_redeemed'], isActive = j['is_active'],
        maxRedemptions = j['max_redemptions'], expiresAt = j['expires_at'];
}

class LaunchpadOverview {
  final double mrr, arr, churnRate, mrrGrowthPercent;
  final int activeSubscriptions, newSubscriptionsThisMonth, cancelledThisMonth;
  LaunchpadOverview.fromJson(Map<String, dynamic> j)
      : mrr = (j['mrr'] as num).toDouble(), arr = (j['arr'] as num).toDouble(),
        churnRate = (j['churn_rate'] as num).toDouble(),
        mrrGrowthPercent = (j['mrr_growth_percent'] as num).toDouble(),
        activeSubscriptions = j['active_subscriptions'],
        newSubscriptionsThisMonth = j['new_subscriptions_this_month'],
        cancelledThisMonth = j['cancelled_this_month'];
}

class LaunchpadClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  LaunchpadClient(this._http, this._onRateLimit);

  Future<ListResponse<LaunchpadCustomer>> listCustomers({int? limit, int? offset, String? search}) async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/customers',
        query: {'limit': limit?.toString(), 'offset': offset?.toString(), 'search': search},
        fromJson: (j) => ListResponse<LaunchpadCustomer>(
          data: (j['data'] as List).map((e) => LaunchpadCustomer.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<LaunchpadCustomer> createCustomer(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/launchpad/customers',
        body: params, fromJson: (j) => LaunchpadCustomer.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<LaunchpadCustomer> getCustomer(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/customers/$id',
        fromJson: (j) => LaunchpadCustomer.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<LaunchpadSubscription>> listSubscriptions({String? customerId, String? status}) async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/subscriptions',
        query: {'customer_id': customerId, 'status': status},
        fromJson: (j) => ListResponse<LaunchpadSubscription>(
          data: (j['data'] as List).map((e) => LaunchpadSubscription.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<LaunchpadSubscription> createSubscription(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/launchpad/subscriptions',
        body: params, fromJson: (j) => LaunchpadSubscription.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<void> cancelSubscription(String id) async {
    final (_, rl) = await _http.request('DELETE', '/v1/launchpad/subscriptions/$id',
        fromJson: (_) => null);
    _onRateLimit(rl);
  }

  Future<ListResponse<Plan>> listPlans() async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/plans',
        fromJson: (j) => ListResponse<Plan>(
          data: (j['data'] as List).map((e) => Plan.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<LaunchpadInvoice>> listInvoices({String? customerId, int? limit}) async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/invoices',
        query: {'customer_id': customerId, 'limit': limit?.toString()},
        fromJson: (j) => ListResponse<LaunchpadInvoice>(
          data: (j['data'] as List).map((e) => LaunchpadInvoice.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Coupon>> listCoupons() async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/coupons',
        fromJson: (j) => ListResponse<Coupon>(
          data: (j['data'] as List).map((e) => Coupon.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Coupon> createCoupon(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/launchpad/coupons',
        body: params, fromJson: (j) => Coupon.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<LaunchpadOverview> getOverview() async {
    final (data, rl) = await _http.request('GET', '/v1/launchpad/analytics/overview',
        fromJson: (j) => LaunchpadOverview.fromJson(j));
    _onRateLimit(rl);
    return data;
  }
}
