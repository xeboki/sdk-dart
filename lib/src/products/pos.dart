import '../http.dart';

class Order {
  final String id, orderNumber, status, locationId, employeeId, paymentMethod, createdAt, updatedAt;
  final double subtotal, tax, discount, total;
  final String? customerId, notes;
  final List<Map<String, dynamic>> items;

  Order.fromJson(Map<String, dynamic> j)
      : id = j['id'], orderNumber = j['order_number'], status = j['status'],
        locationId = j['location_id'], employeeId = j['employee_id'],
        paymentMethod = j['payment_method'], createdAt = j['created_at'],
        updatedAt = j['updated_at'], subtotal = (j['subtotal'] as num).toDouble(),
        tax = (j['tax'] as num).toDouble(), discount = (j['discount'] as num).toDouble(),
        total = (j['total'] as num).toDouble(),
        customerId = j['customer_id'], notes = j['notes'],
        items = List<Map<String, dynamic>>.from(j['items'] ?? []);
}

class Product {
  final String id, name, locationId, createdAt, updatedAt;
  final double price, taxRate;
  final bool isActive, trackInventory;
  final String? description, sku, barcode, categoryId, imageUrl;
  final double? cost;

  Product.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], locationId = j['location_id'],
        createdAt = j['created_at'], updatedAt = j['updated_at'],
        price = (j['price'] as num).toDouble(), taxRate = (j['tax_rate'] as num).toDouble(),
        isActive = j['is_active'] ?? true, trackInventory = j['track_inventory'] ?? false,
        description = j['description'], sku = j['sku'], barcode = j['barcode'],
        categoryId = j['category_id'], imageUrl = j['image_url'],
        cost = j['cost'] != null ? (j['cost'] as num).toDouble() : null;
}

class InventoryItem {
  final String id, productId, productName, locationId, unit, lastUpdated;
  final int quantity;
  final int? lowStockThreshold;

  InventoryItem.fromJson(Map<String, dynamic> j)
      : id = j['id'], productId = j['product_id'], productName = j['product_name'],
        locationId = j['location_id'], unit = j['unit'], lastUpdated = j['last_updated'],
        quantity = j['quantity'], lowStockThreshold = j['low_stock_threshold'];
}

class PosCustomer {
  final String id, name, createdAt, updatedAt;
  final String? email, phone, notes;
  final int? loyaltyPoints, visitCount;
  final double? totalSpend;

  PosCustomer.fromJson(Map<String, dynamic> j)
      : id = j['id'], name = j['name'], createdAt = j['created_at'], updatedAt = j['updated_at'],
        email = j['email'], phone = j['phone'], notes = j['notes'],
        loyaltyPoints = j['loyalty_points'], visitCount = j['visit_count'],
        totalSpend = j['total_spend'] != null ? (j['total_spend'] as num).toDouble() : null;
}

class SalesReport {
  final String locationId, startDate, endDate;
  final int totalOrders;
  final double totalRevenue, totalTax, totalDiscount, netRevenue, averageOrderValue;

  SalesReport.fromJson(Map<String, dynamic> j)
      : locationId = j['location_id'], startDate = j['start_date'], endDate = j['end_date'],
        totalOrders = j['total_orders'],
        totalRevenue = (j['total_revenue'] as num).toDouble(),
        totalTax = (j['total_tax'] as num).toDouble(),
        totalDiscount = (j['total_discount'] as num).toDouble(),
        netRevenue = (j['net_revenue'] as num).toDouble(),
        averageOrderValue = (j['average_order_value'] as num).toDouble();
}

class ListResponse<T> {
  final List<T> data;
  final int total, limit, offset;
  ListResponse({required this.data, required this.total, required this.limit, required this.offset});
}

class PosClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;

  PosClient(this._http, this._onRateLimit);

  Future<ListResponse<Order>> listOrders({
    int? limit, int? offset, String? status,
    String? locationId, String? customerId,
    String? startDate, String? endDate,
  }) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/orders',
        query: {'limit': limit?.toString(), 'offset': offset?.toString(),
                'status': status, 'location_id': locationId,
                'customer_id': customerId, 'start_date': startDate, 'end_date': endDate},
        fromJson: (j) => ListResponse<Order>(
          data: (j['data'] as List).map((e) => Order.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Order> createOrder(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/pos/orders',
        body: params, fromJson: (j) => Order.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<Order> getOrder(String id) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/orders/$id',
        fromJson: (j) => Order.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Product>> listProducts({
    int? limit, int? offset, String? categoryId,
    String? locationId, bool? isActive, String? search,
  }) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/products',
        query: {'limit': limit?.toString(), 'offset': offset?.toString(),
                'category_id': categoryId, 'location_id': locationId,
                'is_active': isActive?.toString(), 'search': search},
        fromJson: (j) => ListResponse<Product>(
          data: (j['data'] as List).map((e) => Product.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<Product> createProduct(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/pos/products',
        body: params, fromJson: (j) => Product.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('PUT', '/v1/pos/products/$id',
        body: params, fromJson: (j) => Product.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<InventoryItem>> listInventory({String? locationId, bool? lowStockOnly}) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/inventory',
        query: {'location_id': locationId, 'low_stock_only': lowStockOnly?.toString()},
        fromJson: (j) => ListResponse<InventoryItem>(
          data: (j['data'] as List).map((e) => InventoryItem.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<InventoryItem> updateInventory(String id, Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('PUT', '/v1/pos/inventory/$id',
        body: params, fromJson: (j) => InventoryItem.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<PosCustomer>> listCustomers({String? search, int? limit, int? offset}) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/customers',
        query: {'search': search, 'limit': limit?.toString(), 'offset': offset?.toString()},
        fromJson: (j) => ListResponse<PosCustomer>(
          data: (j['data'] as List).map((e) => PosCustomer.fromJson(e)).toList(),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }

  Future<PosCustomer> createCustomer(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request('POST', '/v1/pos/customers',
        body: params, fromJson: (j) => PosCustomer.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<SalesReport> getSalesReport({String? startDate, String? endDate, String? locationId}) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/reports/sales',
        query: {'start_date': startDate, 'end_date': endDate, 'location_id': locationId},
        fromJson: (j) => SalesReport.fromJson(j));
    _onRateLimit(rl);
    return data;
  }

  Future<ListResponse<Map<String, dynamic>>> listSessions({
    String? locationId, String? status, int? limit, int? offset,
  }) async {
    final (data, rl) = await _http.request('GET', '/v1/pos/sessions',
        query: {'location_id': locationId, 'status': status,
                'limit': limit?.toString(), 'offset': offset?.toString()},
        fromJson: (j) => ListResponse<Map<String, dynamic>>(
          data: List<Map<String, dynamic>>.from(j['data']),
          total: j['total'], limit: j['limit'], offset: j['offset'],
        ));
    _onRateLimit(rl);
    return data;
  }
}
