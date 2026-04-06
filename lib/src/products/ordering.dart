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

/// A single selectable variant of a product (e.g. "Red / L").
///
/// When [price] is null the parent product's price applies.
/// When [stock] is null inventory is not tracked for this variant.
class ProductVariant {
  final String id;
  final String label;              // "Red / L" — pre-formatted for display
  final Map<String, String> attributes; // {"Color": "Red", "Size": "L"}
  final String? sku, barcode, imageUrl;
  final double? price;             // null = inherit product price
  final double? compareAtPrice;
  final int stock;
  final Map<String, int> stockByLocation;
  final int sortOrder;

  ProductVariant.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        label = j['label']?.toString() ?? '',
        attributes = (j['attributes'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ?? {},
        sku = j['sku']?.toString(),
        barcode = j['barcode']?.toString(),
        imageUrl = j['image_url']?.toString(),
        price = j['price'] != null ? (j['price'] as num).toDouble() : null,
        compareAtPrice = j['compare_at_price'] != null
            ? (j['compare_at_price'] as num).toDouble()
            : null,
        stock = j['stock'] as int? ?? 0,
        stockByLocation = (j['stock_by_location'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            ) ?? {},
        sortOrder = j['sort_order'] as int? ?? 0;
}

/// Defines one axis of product variants (e.g. Size with values S / M / L).
class VariantOption {
  final String name;
  final List<String> values;

  VariantOption.fromJson(Map<String, dynamic> j)
      : name = j['name']?.toString() ?? '',
        values = (j['values'] as List? ?? []).map((e) => e.toString()).toList();
}

class OrderingProduct {
  final String id, name;
  final double price;
  final bool isActive, trackInventory;
  final String? description, imageUrl, categoryId, categoryName;
  final int? stockQuantity;
  final bool hasVariants;
  final List<VariantOption> variantOptions;
  final List<ProductVariant> variants;
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
        stockQuantity = j['stock_quantity'] as int? ?? j['stock'] as int?,
        hasVariants = j['has_variants'] as bool? ?? false,
        variantOptions = (j['variant_options'] as List? ?? [])
            .map((e) => VariantOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        variants = (j['variants'] as List? ?? [])
            .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
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
  final String? variantId, variantLabel;
  final Map<String, String> variantAttributes;
  final int quantity;
  final double unitPrice, totalPrice;
  final List<String> modifierNames;
  final String? notes;

  OrderingLineItem.fromJson(Map<String, dynamic> j)
      : productId = j['product_id']?.toString() ?? '',
        productName = j['product_name']?.toString() ?? '',
        variantId = j['variant_id']?.toString(),
        variantLabel = j['variant_label']?.toString(),
        variantAttributes = (j['variant_attributes'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ?? {},
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

/// A line item passed to [OrderingClient.createOrder].
class OrderingOrderItem {
  final String productId;

  /// Required when the product has variants (`hasVariants == true`).
  final String? variantId;

  final int quantity;
  final List<Map<String, dynamic>> modifiers;
  final String? notes;

  const OrderingOrderItem({
    required this.productId,
    this.variantId,
    required this.quantity,
    this.modifiers = const [],
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'quantity': quantity,
        if (modifiers.isNotEmpty) 'modifiers': modifiers,
        if (notes != null) 'notes': notes,
      };
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

// ── Key validation ────────────────────────────────────────────────────────────

enum KeyValidationStatus {
  valid,
  invalidKey,       // 401 — key not found or revoked
  noSubscription,   // 403 code: subscription_required
  freePlanBlocked,  // 403 code: free_plan_not_supported
  featureNotInPlan, // 403 code: ordering_app_not_in_plan
  networkError,     // connection failure
}

class KeyValidationResult {
  final bool valid;
  final String subscriberId;
  final String subStatus;
  final String subPlan;

  const KeyValidationResult({
    required this.valid,
    required this.subscriberId,
    required this.subStatus,
    required this.subPlan,
  });

  factory KeyValidationResult.fromJson(Map<String, dynamic> j) {
    final sub = j['subscription'] as Map<String, dynamic>?;
    return KeyValidationResult(
      valid:        j['valid'] as bool? ?? false,
      subscriberId: j['subscriber_id']?.toString() ?? '',
      subStatus:    sub?['status']?.toString() ?? '',
      subPlan:      sub?['plan']?.toString() ?? '',
    );
  }
}

/// Firebase configuration returned by [OrderingClient.getFirebaseConfig],
/// enabling direct Firestore reads for catalog, orders, and real-time tracking.
///
/// This is the same config the official Xeboki Ordering App uses to
/// initialise a secondary Firebase app and read data directly — no API
/// hop required for reads once the app is initialised.
class OrderingFirebaseConfig {
  final String apiKey;
  final String projectId;
  final String appId;
  final String authDomain;
  final String storageBucket;
  final String messagingSenderId;
  final String? customToken;

  OrderingFirebaseConfig.fromJson(Map<String, dynamic> j)
      : apiKey = j['api_key']?.toString() ?? '',
        projectId = j['project_id']?.toString() ?? '',
        appId = j['app_id']?.toString() ?? '',
        authDomain = j['auth_domain']?.toString() ?? '',
        storageBucket = j['storage_bucket']?.toString() ?? '',
        messagingSenderId = j['messaging_sender_id']?.toString() ?? '',
        customToken = j['custom_token']?.toString();
}

class StoreConfig {
  final String businessType, businessName, currencyCode, currencySymbol;
  final String timezone, taxLabel;
  final double taxRate;
  final String supportEmail, supportPhone, website;
  final Map<String, dynamic> address;

  StoreConfig.fromJson(Map<String, dynamic> j)
      : businessType   = j['business_type']?.toString() ?? '',
        businessName   = j['business_name']?.toString() ?? '',
        currencyCode   = j['currency_code']?.toString() ?? 'USD',
        currencySymbol = j['currency_symbol']?.toString() ?? '\$',
        timezone       = j['timezone']?.toString() ?? 'UTC',
        taxLabel       = j['tax_label']?.toString() ?? 'Tax',
        taxRate        = (j['tax_rate'] as num?)?.toDouble() ?? 0,
        supportEmail   = j['support_email']?.toString() ?? '',
        supportPhone   = j['support_phone']?.toString() ?? '',
        website        = j['website']?.toString() ?? '',
        address        = (j['address'] as Map?)?.cast<String, dynamic>() ?? {};
}

class StorefrontConfig {
  final String? storefrontSlug, customDomain;
  final bool isPublished;
  final String theme, primaryColor, secondaryColor, font;
  final String? logoUrl, faviconUrl, heroImageUrl, announcementBar;
  final String heroTitle, heroSubtitle, seoTitle, seoDescription;
  final List<String> featuredCategoryIds, featuredProductIds;
  final Map<String, String> socialLinks;
  final String? updatedAt;

  StorefrontConfig.fromJson(Map<String, dynamic> j)
      : storefrontSlug      = j['storefront_slug']?.toString(),
        customDomain        = j['custom_domain']?.toString(),
        isPublished         = j['is_published'] as bool? ?? false,
        theme               = j['theme']?.toString() ?? 'minimal',
        primaryColor        = j['primary_color']?.toString() ?? '#000000',
        secondaryColor      = j['secondary_color']?.toString() ?? '#ffffff',
        font                = j['font']?.toString() ?? 'inter',
        logoUrl             = j['logo_url']?.toString(),
        faviconUrl          = j['favicon_url']?.toString(),
        heroImageUrl        = j['hero_image_url']?.toString(),
        heroTitle           = j['hero_title']?.toString() ?? '',
        heroSubtitle        = j['hero_subtitle']?.toString() ?? '',
        featuredCategoryIds = (j['featured_category_ids'] as List? ?? []).map((e) => e.toString()).toList(),
        featuredProductIds  = (j['featured_product_ids'] as List? ?? []).map((e) => e.toString()).toList(),
        announcementBar     = j['announcement_bar']?.toString(),
        seoTitle            = j['seo_title']?.toString() ?? '',
        seoDescription      = j['seo_description']?.toString() ?? '',
        socialLinks         = (j['social_links'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
        updatedAt           = j['updated_at']?.toString();
}

class StripePaymentIntent {
  final String clientSecret, publishableKey, paymentIntentId, currency;
  final double amount;
  final String? connectedAccountId;

  StripePaymentIntent.fromJson(Map<String, dynamic> j)
      : clientSecret       = j['client_secret']?.toString() ?? '',
        publishableKey     = j['publishable_key']?.toString() ?? '',
        paymentIntentId    = j['payment_intent_id']?.toString() ?? '',
        currency           = j['currency']?.toString() ?? 'usd',
        amount             = (j['amount'] as num?)?.toDouble() ?? 0,
        connectedAccountId = j['connected_account_id']?.toString();
}

class GiftCard {
  final String id, code, currency, status;
  final double balance, initialValue;
  final String? expiresAt, issuedAt;

  GiftCard.fromJson(Map<String, dynamic> j)
      : id           = j['id']?.toString() ?? '',
        code         = j['code']?.toString() ?? '',
        balance      = (j['balance'] as num?)?.toDouble() ?? 0,
        initialValue = (j['initial_value'] as num?)?.toDouble() ?? 0,
        currency     = j['currency']?.toString() ?? 'USD',
        status       = j['status']?.toString() ?? 'active',
        expiresAt    = j['expires_at']?.toString(),
        issuedAt     = j['issued_at']?.toString();
}

class CustomerAddress {
  final String id, line1, city, postcode, country;
  final String? label, line2, state, createdAt;
  final bool isDefault;

  CustomerAddress.fromJson(Map<String, dynamic> j)
      : id         = j['id']?.toString() ?? '',
        label      = j['label']?.toString(),
        line1      = j['line1']?.toString() ?? '',
        line2      = j['line2']?.toString(),
        city       = j['city']?.toString() ?? '',
        state      = j['state']?.toString(),
        postcode   = j['postcode']?.toString() ?? '',
        country    = j['country']?.toString() ?? 'US',
        isDefault  = j['is_default'] as bool? ?? false,
        createdAt  = j['created_at']?.toString();
}

// ── Client ────────────────────────────────────────────────────────────────────

/// Customer-facing ordering API client.
///
/// ## Architecture note — Firestore-first
///
/// The official Xeboki Ordering App reads catalog, orders, customers, and
/// discounts **directly from the subscriber's Firestore** rather than going
/// through the REST API. This halves latency and removes API load at scale.
///
/// To adopt the same pattern in your app:
/// 1. Call [getFirebaseConfig] on startup to receive the subscriber's Firebase
///    project config + a custom auth token.
/// 2. Initialise a secondary `FirebaseApp` with the returned config.
/// 3. Sign in with `signInWithCustomToken(customToken)`.
/// 4. Read Firestore directly: `categories`, `products`, `orders`, `customers`.
///
/// All REST methods below remain available for simpler integrations or
/// environments where Firestore is not an option.
///
/// ```dart
/// final xeboki = XebokiClient(apiKey: 'xbk_live_...');
///
/// // Option A — Firestore-direct (recommended for real-time apps)
/// final fbConfig = await xeboki.ordering.getFirebaseConfig();
/// // … initialise secondary Firebase app with fbConfig …
///
/// // Option B — REST API (simpler, no Firebase dependency)
/// final products = await xeboki.ordering.listProducts(limit: 20);
/// final auth = await xeboki.ordering.loginCustomer(email: '...', password: '...');
/// ```
class OrderingClient {
  final XebokiHttpClient _http;
  final void Function(RateLimitInfo) _onRateLimit;

  OrderingClient(this._http, this._onRateLimit);

  // ── Startup validation ───────────────────────────────────────────────────────

  /// Validates the API key and POS subscription on app startup.
  ///
  /// Throws [XebokiException] with meaningful codes on failure:
  ///   status=401  → key invalid / revoked
  ///   status=403  → subscription_required | free_plan_not_supported | ordering_app_not_in_plan
  Future<KeyValidationResult> validateApiKey() async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/validate',
      fromJson: (j) =>
          KeyValidationResult.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Firebase config (Firestore-direct path) ─────────────────────────────────

  /// Returns the subscriber's Firebase project config + a short-lived custom
  /// auth token, enabling direct Firestore access for reads.
  ///
  /// Call this once on app startup and cache the result. The custom token
  /// expires in 1 hour — refresh via [validateApiKey] when needed.
  ///
  /// ```dart
  /// final fbConfig = await xeboki.ordering.getFirebaseConfig();
  /// await Firebase.initializeApp(
  ///   name: 'ordering_pro',
  ///   options: FirebaseOptions(
  ///     apiKey: fbConfig.apiKey, projectId: fbConfig.projectId,
  ///     appId: fbConfig.appId, authDomain: fbConfig.authDomain,
  ///     storageBucket: fbConfig.storageBucket,
  ///     messagingSenderId: fbConfig.messagingSenderId,
  ///   ),
  /// );
  /// await FirebaseAuth.instanceFor(app: secondaryApp)
  ///     .signInWithCustomToken(fbConfig.customToken!);
  /// ```
  Future<OrderingFirebaseConfig> getFirebaseConfig() async {
    final (data, rl) = await _http.request(
      'GET',
      '/v1/pos/firebase-config',
      fromJson: (j) => OrderingFirebaseConfig.fromJson(
          (j['firebase_config'] ?? j) as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── FCM token registration ────────────────────────────────────────────────────

  /// Registers a customer's FCM token so they receive push notifications
  /// for order status changes.
  ///
  /// [platform] — 'android' | 'ios' | 'web' (optional)
  /// [deviceId] — stable device identifier for dedup (optional)
  Future<void> registerCustomerFcmToken(
    String customerId,
    String fcmToken, {
    String? platform,
    String? deviceId,
  }) async {
    final (_, rl) = await _http.request(
      'POST',
      '/v1/pos/customers/fcm-token',
      body: {
        'customer_id': customerId,
        'fcm_token': fcmToken,
        if (platform != null) 'platform': platform,
        if (deviceId != null) 'device_id': deviceId,
      },
      fromJson: (_) => null,
    );
    _onRateLimit(rl);
  }

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
    required List<OrderingOrderItem> items,
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
        'items': items.map((i) => i.toJson()).toList(),
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

  // ── Store & storefront config ─────────────────────────────────────────────

  Future<StoreConfig> getStoreConfig() async {
    final (data, rl) = await _http.request(
      'GET', '/v1/pos/store-config',
      fromJson: (j) => StoreConfig.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<StorefrontConfig> getStorefrontConfig() async {
    final (data, rl) = await _http.request(
      'GET', '/v1/pos/storefront-config',
      fromJson: (j) => StorefrontConfig.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<StorefrontConfig> updateStorefrontConfig(Map<String, dynamic> params) async {
    final (data, rl) = await _http.request(
      'PUT', '/v1/pos/storefront-config',
      body: params,
      fromJson: (j) => StorefrontConfig.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Stripe ────────────────────────────────────────────────────────────────

  Future<StripePaymentIntent> createStripePaymentIntent(String orderId) async {
    final (data, rl) = await _http.request(
      'POST', '/v1/pos/orders/$orderId/stripe/intent',
      fromJson: (j) => StripePaymentIntent.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<Map<String, dynamic>> confirmStripePayment(
    String orderId,
    String paymentIntentId,
  ) async {
    final (data, rl) = await _http.request(
      'POST', '/v1/pos/orders/$orderId/stripe/confirm',
      body: {'payment_intent_id': paymentIntentId},
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Gift cards ────────────────────────────────────────────────────────────

  Future<GiftCard?> getGiftCard(String code) async {
    try {
      final (data, rl) = await _http.request(
        'GET', '/v1/pos/gift-cards/${Uri.encodeComponent(code.toUpperCase())}',
        fromJson: (j) => GiftCard.fromJson(j as Map<String, dynamic>),
      );
      _onRateLimit(rl);
      return data;
    } catch (_) {
      return null;
    }
  }

  // ── Product slug lookup ───────────────────────────────────────────────────

  Future<OrderingProduct?> getProductBySlug(String slug) async {
    try {
      final (data, rl) = await _http.request(
        'GET', '/v1/pos/catalog/slug/${Uri.encodeComponent(slug)}',
        fromJson: (j) => OrderingProduct.fromJson(
          ((j is Map && j['product'] != null) ? j['product'] : j) as Map<String, dynamic>,
        ),
      );
      _onRateLimit(rl);
      return data;
    } catch (_) {
      return null;
    }
  }

  // ── Customer profile update ───────────────────────────────────────────────

  Future<OrderingCustomer> updateCustomer(
    String customerId,
    Map<String, dynamic> updates,
  ) async {
    final (data, rl) = await _http.request(
      'PATCH', '/v1/pos/customers/$customerId',
      body: updates,
      fromJson: (j) => OrderingCustomer.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  // ── Customer address book ─────────────────────────────────────────────────

  Future<List<CustomerAddress>> listCustomerAddresses(String customerId) async {
    final (data, rl) = await _http.request(
      'GET', '/v1/pos/customers/$customerId/addresses',
      fromJson: (j) => (j['addresses'] as List? ?? [])
          .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<CustomerAddress> addCustomerAddress(
    String customerId,
    Map<String, dynamic> address,
  ) async {
    final (data, rl) = await _http.request(
      'POST', '/v1/pos/customers/$customerId/addresses',
      body: address,
      fromJson: (j) => CustomerAddress.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<CustomerAddress> updateCustomerAddress(
    String customerId,
    String addressId,
    Map<String, dynamic> address,
  ) async {
    final (data, rl) = await _http.request(
      'PUT', '/v1/pos/customers/$customerId/addresses/$addressId',
      body: address,
      fromJson: (j) => CustomerAddress.fromJson(j as Map<String, dynamic>),
    );
    _onRateLimit(rl);
    return data;
  }

  Future<void> deleteCustomerAddress(String customerId, String addressId) async {
    final (_, rl) = await _http.request(
      'DELETE', '/v1/pos/customers/$customerId/addresses/$addressId',
      fromJson: (_) => null,
    );
    _onRateLimit(rl);
  }
}
