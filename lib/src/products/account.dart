import '../http.dart';
import 'pos.dart' show ListResponse;

class UserProfile {
  final int id;
  final String email, fullName, createdAt, updatedAt;
  final List<String> products;
  UserProfile.fromJson(Map<String, dynamic> j)
      : id = j['id'], email = j['email'], fullName = j['full_name'],
        createdAt = j['created_at'], updatedAt = j['updated_at'],
        products = List<String>.from(j['products'] ?? []);
}

class AccountSubscription {
  final String id, product, plan, status, currentPeriodStart, currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  AccountSubscription.fromJson(Map<String, dynamic> j)
      : id = j['id'], product = j['product'], plan = j['plan'], status = j['status'],
        currentPeriodStart = j['current_period_start'],
        currentPeriodEnd = j['current_period_end'],
        cancelAtPeriodEnd = j['cancel_at_period_end'] ?? false;
}

class AccountInvoice {
  final String id, currency, status, createdAt;
  final double amount;
  final String? description, pdfUrl, paidAt;
  AccountInvoice.fromJson(Map<String, dynamic> j)
      : id = j['id'], currency = j['currency'], status = j['status'],
        createdAt = j['created_at'], amount = (j['amount'] as num).toDouble(),
        description = j['description'], pdfUrl = j['pdf_url'], paidAt = j['paid_at'];
}

class PaymentMethod {
  final String id, type;
  final bool isDefault;
  final String? brand, last4;
  final int? expMonth, expYear;
  PaymentMethod.fromJson(Map<String, dynamic> j)
      : id = j['id'], type = j['type'], isDefault = j['is_default'] ?? false,
        brand = j['brand'], last4 = j['last4'],
        expMonth = j['exp_month'], expYear = j['exp_year'];
}

class AccountClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;
  AccountClient(this._http, this._onRateLimit);

  Future<UserProfile> getProfile() async {
    final (data, rl) = await _http.request('GET', '/v1/account/me',
        fromJson: (j) => UserProfile.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('PATCH', '/v1/account/me',
        body: params, fromJson: (j) => UserProfile.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<AccountSubscription>> listSubscriptions() async {
    final (data, rl) = await _http.request('GET', '/v1/account/subscriptions',
        fromJson: (j) => ListResponse<AccountSubscription>(
          data: (j['data'] as List).map((e) => AccountSubscription.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<AccountInvoice>> listInvoices({int? limit, int? offset}) async {
    final (data, rl) = await _http.request('GET', '/v1/account/invoices',
        query: {'limit': limit?.toString(), 'offset': offset?.toString()},
        fromJson: (j) => ListResponse<AccountInvoice>(
          data: (j['data'] as List).map((e) => AccountInvoice.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<PaymentMethod>> listPaymentMethods() async {
    final (data, rl) = await _http.request('GET', '/v1/account/payment-methods',
        fromJson: (j) => ListResponse<PaymentMethod>(
          data: (j['data'] as List).map((e) => PaymentMethod.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }
}
