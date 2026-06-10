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

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.receiptAvailable,
    this.paidAt,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      receiptAvailable: json['receiptAvailable'] as bool? ?? false,
      paidAt: DateTime.tryParse(json['paidAt'] as String? ?? '')?.toLocal(),
    );
  }

  final String id;
  final int amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final bool receiptAvailable;
  final DateTime? paidAt;

  DateTime get date => paidAt ?? createdAt;
}

class PaymentHistoryPage {
  const PaymentHistoryPage({
    required this.items,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  final List<PaymentHistoryItem> items;
  final int page;
  final int totalElements;
  final int totalPages;
}

class BillingReceipt {
  const BillingReceipt({
    required this.available,
    this.invoiceUrl,
    this.invoicePdfUrl,
  });

  factory BillingReceipt.fromJson(Map<String, dynamic> json) {
    return BillingReceipt(
      available: json['available'] as bool? ?? false,
      invoiceUrl: json['invoiceUrl'] as String?,
      invoicePdfUrl: json['invoicePdfUrl'] as String?,
    );
  }

  final bool available;
  final String? invoiceUrl;
  final String? invoicePdfUrl;

  /// PDF 우선, 없으면 일반 인보이스 URL.
  String? get bestUrl => invoicePdfUrl ?? invoiceUrl;
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

  Future<PaymentHistoryPage> getPayments({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/payments',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data ?? const <String, dynamic>{};
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PaymentHistoryItem.fromJson)
        .toList();
    return PaymentHistoryPage(
      items: items,
      page: (data['page'] as num?)?.toInt() ?? 0,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<BillingReceipt> getReceipt(String paymentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/payments/$paymentId/receipt',
    );
    return BillingReceipt.fromJson(response.data ?? const <String, dynamic>{});
  }
}
