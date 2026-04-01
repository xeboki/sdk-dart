import '../http.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class OrderingCategory {
  final String id, name;
  final String? icon, color;
  final int sortOrder;
  final bool isActive;

  OrderingCategory.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        icon = j['icon']?.toString(),
        color = j['color']?.toString(),
        sortOrder = j['sort_order'] as int? ?? 0,
        isActive = j['is_active'] as bool? ?? true;
}

class ModifierOption {
  final String id, name;
  final double priceAdjustment;
  final bool isAvailable;

  ModifierOption.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        priceAdjustment = (j['price_adjustment'] as num?)?.toDouble() ?? 0,
        isAvailable = j['is_available'] as bool? ?? true;
}

class ModifierGroup {
  final String id, name;
  final bool required;
  final int? minSelections, maxSelections;
  final List<ModifierOption> options;

  ModifierGroup.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        required = j['required'] as bool? ?? false,
        minSelections = j['min_selections'] as int?,
        maxSelections = j['max_selections'] as int?,
        options = (j['options'] as List? ?? [])
            .map((e) => ModifierOption.fromJson(e as Map<String, dynamic>))
            .toList();
}

class OrderingProduct {
  final String id, name;
  final double price;
  final bool isActive, trackInventory;
  final String? description, imageUrl, categoryId, categoryName;
  final int? stockQuantity;
  final List<ModifierGroup> modifierGroups;
  final List<String> tags;

  OrderingProduct.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        price = (j['price'] as num?)?.toDouble() ?? 0,
        isActive = j['is_active'] as bool? ?? true,
        trackInventory = j['track_inventory'] as bool? ?? false,
        description = j['description']?.toString(),
        imageUrl = j['image_url']?.toString(),
        categoryId = j['category_id']?.toString(),
        categoryName = j['category_name']?.toString(),
        stockQuantity = j['stock_quantity'] as int?,
        modifierGroups = (j['modifier_groups'] as List? ?? [])
            .map((e) => ModifierGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
        tags = (j['tags'] as List? ?? []).map((e) => e.toString()).toList();

  bool get inStock => !trackInventory || (stockQuantity ?? 1) > 0;
}

class OrderingCustomer {
  final String id, name;
  final String? email, phone;
  final double storeCredit;
  final int loyaltyPoints;

  OrderingCustomer.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = (j['name'] ?? j['full_name'])?.toString() ?? '',
        email = j['email']?.toString(),
        phone = j['phone']?.toString(),
        storeCredit = (j['store_credit'] as num?)?.toDouble() ?? 0,
        loyaltyPoints = j['loyalty_points'] as int? ?? 0;
}

class CustomerAuth {
  final OrderingCustomer customer;
  final String token;

  CustomerAuth({required this.customer, required this.token});

  factory CustomerAuth.fromJson(Map<String, dynamic> j) => CustomerAuth(
        customer: OrderingCustomer.fromJson(j['customer'] as Map<String, dynamic>),
        token: j['token']?.toString() ?? '',
      );
}

class OrderingLineItem {
  final String productId, productName;
  final int quantity;
  final double unitPrice, totalPrice;
  final List<String> modifierNames;
  final String? notes;

  OrderingLineItem.fromJson(Map<String, dynamic> j)
      : productId = j['product_id']?.toString() ?? '',
        productName = j['product_name']?.toString() ?? '',
        quantity = j['quantity'] as int? ?? 1,
        unitPrice = (j['unit_price'] as num?)?.toDouble() ?? 0,
        totalPrice = (j['total_price'] as num?)?.toDouble() ?? 0,
        modifierNames =
            (j['modifier_names'] as List? ?? []).map((e) => e.toString()).toList(),
        notes = j['notes']?.toString();
}

class OrderingOrder {
  final String id, orderNumber, status, orderType;
  final double subtotal, tax, discount, total, paidTotal;
  final List<OrderingLineItem> items;
  final String? customerId, tableId, notes, reference, deliveryAddress, scheduledAt;
  final DateTime createdAt;

  OrderingOrder.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        orderNumber = j['order_number']?.toString() ?? '',
        status = j['status']?.toString() ?? 'pending',
        orderType = j['order_type']?.toString() ?? 'pickup',
        subtotal = (j['subtotal'] as num?)?.toDouble() ?? 0,
        tax = (j['tax'] as num?)?.toDouble() ?? 0,
        discount = (j['discount'] as num?)?.toDouble() ?? 0,
        total = (j['total'] as num?)?.toDouble() ?? 0,
        paidTotal = (j['paid_total'] as num?)?.toDouble() ?? 0,
        items = (j['items'] as List? ?? [])
            .map((e) => OrderingLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customerId = j['customer_id']?.toString(),
        tableId = j['table_id']?.toString(),
        notes = j['notes']?.toString(),
        reference = j['reference']?.toString(),
        deliveryAddress = j['delivery_address']?.toString(),
        scheduledAt = j['scheduled_at']?.toString(),
        createdAt = j['created_at'] != null
            ? DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now()
            : DateTime.now();

  bool get isActive =>
      ['pending', 'confirmed', 'processing', 'ready'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class DiscountValidation {
  final bool valid;
  final String? type, reason;
  final double? value, discountAmount;

  DiscountValidation.fromJson(Map<String, dynamic> j)
      : valid = j['valid'] as bool? ?? false,
        type = j['type']?.toString(),
        reason = j['reason']?.toString(),
        value = (j['value'] as num?)?.toDouble(),
        discountAmount = (j['discount_amount'] as num?)?.toDouble();
}

class OrderingAppointment {
  final String id, status, serviceId, serviceName;
  final String? customerId, customerName, staffId, staffName, notes;
  final DateTime startTime;
  final int durationMinutes;

  OrderingAppointment.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        status = j['status']?.toString() ?? 'pending',
        serviceId = j['service_id']?.toString() ?? '',
        serviceName = j['service_name']?.toString() ?? '',
        customerId = j['customer_id']?.toString(),
        customerName = j['customer_name']?.toString(),
        staffId = j['staff_id']?.toString(),
        staffName = j['staff_name']?.toString(),
        notes = j['notes']?.toString(),
        startTime = j['start_time'] != null
            ? DateTime.tryParse(j['start_time'].toString()) ?? DateTime.now()
            : DateTime.now(),
        durationMinutes = j['duration_minutes'] as int? ?? 60;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
}

class OrderingTable {
  final String id, name, status;
  final int? capacity;
  final String? section;

  OrderingTable.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        status = j['status']?.toString() ?? 'available',
        capacity = j['capacity'] as int?,
        section = j['section']?.toString();

  bool get isAvailable => status == 'available';
}

class OrderingStaff {
  final String id, name;
  final String? role, avatarUrl;
  final bool isActive;

  OrderingStaff.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        name = j['name']?.toString() ?? '',
        role = j['role']?.toString(),
        avatarUrl = j['avatar_url']?.toString(),
        isActive = j['is_active'] as bool? ?? true;
}

class OrderingListResponse<T> {
  final List<T> data;
  final int total, limit, offset;

  const OrderingListResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
  });
}

// ── Client ────────────────────────────────────────────────────────────────────

/// Customer-facing ordering API client.
///
/// Handles catalog browsing, customer auth, cart checkout, order tracking,
/// appointment booking, and table selection — all from the customer perspective.
///
/// ```dart
/// final xeboki = XebokiClient(apiKey: 'xbk_live_...');
/// final products = await xeboki.ordering.listProducts(limit: 20);
/// final auth = await xeboki.ordering.loginCustomer(email: '...', password: '...');
/// ```
class OrderingClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;

  OrderingClient(this._http, this._onRateLimit);

  // ── Catalog ─────────────────────────────────────────────────────────────────

  Future<OrderingListResponse<OrderingCategory>> listCategories({
    String? locationId,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/catalog/categories',
      query: {'location_id': locationId},
      fromJson: (j) {
        final list = (j['categories'] ?? j['data'] ?? (j is List ? j : [])) as List;
        return OrderingListResponse<OrderingCategory>(
          data: list
              .map((e) => OrderingCategory.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: (j is Map ? j['limit'] as int? : null) ?? 50,
          offset: (j is Map ? j['offset'] as int? : null) ?? 0,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingListResponse<OrderingProduct>> listProducts({
    String? categoryId,
    String? search,
    String? locationId,
    int limit = 40,
    int offset = 0,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/catalog/products',
      query: {
        'category_id': categoryId,
        'search': search,
        'location_id': locationId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      fromJson: (j) {
        final list =
            ((j['products'] ?? j['data'] ?? (j is List ? j : [])) as List);
        return OrderingListResponse<OrderingProduct>(
          data: list
              .map((e) => OrderingProduct.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: limit,
          offset: offset,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingProduct> getProduct(String id) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/catalog/products/$id',
      fromJson: (j) =>
          OrderingProduct.fromJson((j['product'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Customer Auth ────────────────────────────────────────────────────────────

  Future<CustomerAuth> registerCustomer({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/customers/register',
      body: {
        'email': email,
        'password': password,
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      },
      fromJson: (j) => CustomerAuth.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<CustomerAuth> loginCustomer({
    required String email,
    required String password,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/customers/login',
      body: {'email': email, 'password': password},
      fromJson: (j) => CustomerAuth.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingCustomer?> getCustomer(String id) async {
    try {
      final (data, rl) = await _http.request(
        'GET',
        '/v1/pos/customers/$id',
        fromJson: (j) => OrderingCustomer.fromJson(
            (j['customer'] ?? j) as Map<String, dynamic>),
      );
      _onRateLimit(rl);
      return data;
    } catch (_) {
      return null;
    }
  }

  // ── Discounts ────────────────────────────────────────────────────────────────

  Future<DiscountValidation> validateDiscount(
    String code, {
    double? orderTotal,
    String? locationId,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/discounts/validate',
      body: {
        'code': code,
        if (orderTotal != null) 'order_total': orderTotal,
        if (locationId != null) 'location_id': locationId,
      },
      fromJson: (j) => DiscountValidation.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Orders ───────────────────────────────────────────────────────────────────

  Future<OrderingListResponse<OrderingOrder>> listOrders({
    String? customerId,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/orders',
      query: {
        'customer_id': customerId,
        'status': status,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      fromJson: (j) {
        final list =
            ((j['orders'] ?? j['data'] ?? (j is List ? j : [])) as List);
        return OrderingListResponse<OrderingOrder>(
          data: list
              .map((e) => OrderingOrder.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: limit,
          offset: offset,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingOrder> getOrder(String id) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/orders/$id',
      fromJson: (j) =>
          OrderingOrder.fromJson((j['order'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingOrder> createOrder({
    required String orderType,
    required List<Map<String, dynamic>> items,
    String? customerId,
    String? notes,
    String? tableId,
    String? scheduledAt,
    String? deliveryAddress,
    String? idempotencyKey,
    int? loyaltyPointsRedeemed,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/orders',
      body: {
        'order_type': orderType,
        'items': items,
        if (customerId != null) 'customer_id': customerId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (tableId != null) 'table_id': tableId,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        if (loyaltyPointsRedeemed != null && loyaltyPointsRedeemed > 0)
          'loyalty_points_redeemed': loyaltyPointsRedeemed,
      },
      fromJson: (j) =>
          OrderingOrder.fromJson((j['order'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingOrder> payOrder(
    String id, {
    required String method,
    required double amount,
    String? reference,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/orders/$id/pay',
      body: {
        'method': method,
        'amount': amount,
        if (reference != null) 'reference': reference,
      },
      fromJson: (j) =>
          OrderingOrder.fromJson((j['order'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Tables ───────────────────────────────────────────────────────────────────

  Future<OrderingListResponse<OrderingTable>> listTables({
    String? locationId,
    String? status,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/tables',
      query: {'location_id': locationId, 'status': status},
      fromJson: (j) {
        final list =
            ((j['tables'] ?? j['data'] ?? (j is List ? j : [])) as List);
        return OrderingListResponse<OrderingTable>(
          data: list
              .map((e) => OrderingTable.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: 50,
          offset: 0,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Appointments ─────────────────────────────────────────────────────────────

  Future<OrderingListResponse<OrderingAppointment>> listAppointments({
    String? customerId,
    String? status,
    String? date,
    String? staffId,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/appointments',
      query: {
        'customer_id': customerId,
        'status': status,
        'date': date,
        'staff_id': staffId,
      },
      fromJson: (j) {
        final list =
            ((j['appointments'] ?? j['data'] ?? (j is List ? j : [])) as List);
        return OrderingListResponse<OrderingAppointment>(
          data: list
              .map((e) =>
                  OrderingAppointment.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: 50,
          offset: 0,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingAppointment> createAppointment({
    required String customerId,
    required String serviceId,
    String? staffId,
    required String startTime,
    int durationMinutes = 60,
    String? notes,
  }) async {
    final (data, rl) = await _http.request(
      'POST',
      '/v1/pos/appointments',
      body: {
        'customer_id': customerId,
        'service_id': serviceId,
        if (staffId != null) 'staff_id': staffId,
        'start_time': startTime,
        'duration_minutes': durationMinutes,
        if (notes != null) 'notes': notes,
      },
      fromJson: (j) => OrderingAppointment.fromJson(
          (j['appointment'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<OrderingAppointment> updateAppointmentStatus(
      String id, String status) async {
    final (data, rl) = await _http.request(
      'PATCH',
      '/v1/pos/appointments/$id/status',
      body: {'status': status},
      fromJson: (j) => OrderingAppointment.fromJson(
          (j['appointment'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Staff ─────────────────────────────────────────────────────────────────────

  Future<OrderingListResponse<OrderingStaff>> listStaff({
    String? locationId,
    bool? isActive,
  }) async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/staff',
      query: {
        'location_id': locationId,
        'is_active': isActive?.toString(),
      },
      fromJson: (j) {
        final list =
            ((j['staff'] ?? j['data'] ?? (j is List ? j : [])) as List);
        return OrderingListResponse<OrderingStaff>(
          data: list
              .map((e) => OrderingStaff.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (j is Map ? j['total'] as int? : null) ?? list.length,
          limit: 50,
          offset: 0,
        );
      },
    );
    _onRateLimit(rl);
    return data;
  }
}
