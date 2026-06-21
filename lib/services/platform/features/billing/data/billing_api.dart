import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/core/platform/browser_redirect.dart';

final billingApiProvider = Provider<BillingApi>((ref) {
  return BillingApi(ref.watch(dioProvider));
});

final billingCheckoutRedirectProvider = Provider<void Function(String)>((ref) {
  return redirectToUrl;
});

class BillingSubscription {
  const BillingSubscription({required this.plan, required this.status});

  final String plan;
  final String status;
}

class CheckoutSession {
  const CheckoutSession(this.checkoutUrl);

  final String checkoutUrl;
}

class BillingUsageMetric {
  const BillingUsageMetric({
    required this.used,
    required this.limit,
    required this.remaining,
    required this.source,
  });

  final int? used;
  final int? limit;
  final int? remaining;
  final String source;

  bool get isConnected => source != 'NOT_CONNECTED' && used != null;

  double get progress {
    final usedValue = used;
    final limitValue = limit;
    if (usedValue == null || limitValue == null || limitValue <= 0) {
      return 0;
    }
    return (usedValue / limitValue).clamp(0, 1).toDouble();
  }
}

class BillingUsage {
  const BillingUsage({
    required this.planCode,
    required this.subscriptionStatus,
    required this.metrics,
  });

  final String planCode;
  final String? subscriptionStatus;
  final Map<String, BillingUsageMetric> metrics;
}

class BillingPayment {
  const BillingPayment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paidAt,
    required this.createdAt,
    required this.receiptAvailable,
  });

  final String id;
  final int amount;
  final String currency;
  final String status;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final bool receiptAvailable;
}

class BillingPaymentPage {
  const BillingPaymentPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<BillingPayment> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}

class BillingReceipt {
  const BillingReceipt({
    required this.paymentId,
    required this.invoiceUrl,
    required this.invoicePdfUrl,
    required this.available,
  });

  final String paymentId;
  final String? invoiceUrl;
  final String? invoicePdfUrl;
  final bool available;
}

class BillingApi {
  const BillingApi(this._dio);

  final Dio _dio;

  Future<BillingSubscription?> getSubscription() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/billing/subscription',
      );
      final data = response.data ?? const <String, dynamic>{};
      final planCode = data['planCode'];
      return BillingSubscription(
        plan: planCode is String ? planCode.toUpperCase() : 'FREE',
        status: (data['status'] as String?) ?? 'UNKNOWN',
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<CheckoutSession> createCheckout({
    required String planCode,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/billing/checkout',
      data: {
        'planCode': planCode,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final checkoutUrl = data['checkoutUrl'];

    if (checkoutUrl is! String || checkoutUrl.isEmpty) {
      throw const FormatException('Invalid billing checkout response.');
    }

    return CheckoutSession(checkoutUrl);
  }

  Future<BillingUsage> getUsage() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/usage',
    );
    final data = response.data ?? const <String, dynamic>{};
    final usage = data['usage'];

    if (usage is! Map<String, dynamic>) {
      throw const FormatException('Invalid billing usage response.');
    }

    return BillingUsage(
      planCode: (data['planCode'] as String?)?.toUpperCase() ?? 'FREE',
      subscriptionStatus: data['subscriptionStatus'] as String?,
      metrics: usage.map((key, value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Invalid billing usage metric.');
        }
        return MapEntry(key, _metricFromJson(value));
      }),
    );
  }

  Future<BillingPaymentPage> getPayments({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/payments',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data ?? const <String, dynamic>{};
    final items = data['items'];

    if (items is! List) {
      throw const FormatException('Invalid billing payments response.');
    }

    return BillingPaymentPage(
      items: List.unmodifiable(
        items.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Invalid billing payment item.');
          }
          return _paymentFromJson(item);
        }),
      ),
      page: _readInt(data['page']) ?? page,
      size: _readInt(data['size']) ?? size,
      totalElements: _readInt(data['totalElements']) ?? items.length,
      totalPages: _readInt(data['totalPages']) ?? 1,
    );
  }

  Future<BillingReceipt> getReceipt(String paymentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/payments/$paymentId/receipt',
    );
    final data = response.data ?? const <String, dynamic>{};

    return BillingReceipt(
      paymentId: (data['paymentId'] as String?) ?? paymentId,
      invoiceUrl: data['invoiceUrl'] as String?,
      invoicePdfUrl: data['invoicePdfUrl'] as String?,
      available: data['available'] == true,
    );
  }

  static BillingUsageMetric _metricFromJson(Map<String, dynamic> data) {
    return BillingUsageMetric(
      used: _readInt(data['used']),
      limit: _readInt(data['limit']),
      remaining: _readInt(data['remaining']),
      source: (data['source'] as String?) ?? 'UNKNOWN',
    );
  }

  static BillingPayment _paymentFromJson(Map<String, dynamic> data) {
    final id = data['id'];
    final status = data['status'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid billing payment item.');
    }

    return BillingPayment(
      id: id,
      amount: _readInt(data['amount']) ?? 0,
      currency: (data['currency'] as String?) ?? 'usd',
      status: status,
      paidAt: _readDateTime(data['paidAt']),
      createdAt: _readDateTime(data['createdAt']),
      receiptAvailable: data['receiptAvailable'] == true,
    );
  }

  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
