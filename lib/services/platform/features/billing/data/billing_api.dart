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
}
