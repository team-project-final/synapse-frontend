import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/billing/data/billing_api.dart';

void main() {
  test('getSubscription maps current plan and status', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/billing/subscription');
        return ResponseBody.fromString(
          jsonEncode({'planCode': 'pro', 'status': 'ACTIVE'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = BillingApi(dio);

    final subscription = await api.getSubscription();

    expect(subscription?.plan, 'PRO');
    expect(subscription?.status, 'ACTIVE');
  });

  test('getSubscription treats 404 as no paid subscription', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        return ResponseBody.fromString('', 404);
      });
    final api = BillingApi(dio);

    final subscription = await api.getSubscription();

    expect(subscription, isNull);
  });

  test('createCheckout sends plan and returns checkout URL', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/billing/checkout');
        expect(options.method, 'POST');
        expect(options.data, {
          'planCode': 'PRO',
          'successUrl': 'http://127.0.0.1:8088/billing/success',
          'cancelUrl': 'http://127.0.0.1:8088/billing/cancel',
        });
        return ResponseBody.fromString(
          jsonEncode({'checkoutUrl': 'https://checkout.stripe.test/session'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = BillingApi(dio);

    final session = await api.createCheckout(
      planCode: 'PRO',
      successUrl: 'http://127.0.0.1:8088/billing/success',
      cancelUrl: 'http://127.0.0.1:8088/billing/cancel',
    );

    expect(session.checkoutUrl, 'https://checkout.stripe.test/session');
  });

  test('getUsage maps usage metrics', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/billing/usage');
        return ResponseBody.fromString(
          jsonEncode({
            'planCode': 'pro',
            'subscriptionStatus': 'ACTIVE',
            'usage': {
              'notes': {
                'used': 10,
                'limit': 100,
                'remaining': 90,
                'source': 'knowledge-svc',
              },
              'cards': {
                'used': null,
                'limit': 500,
                'remaining': null,
                'source': 'NOT_CONNECTED',
              },
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = BillingApi(dio);

    final usage = await api.getUsage();

    expect(usage.planCode, 'PRO');
    expect(usage.subscriptionStatus, 'ACTIVE');
    expect(usage.metrics['notes']?.used, 10);
    expect(usage.metrics['notes']?.progress, 0.1);
    expect(usage.metrics['cards']?.isConnected, isFalse);
  });

  test('getPayments maps payment page', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/billing/payments');
        expect(options.queryParameters, {'page': 0, 'size': 20});
        return ResponseBody.fromString(
          jsonEncode({
            'items': [
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'subscriptionId': '22222222-2222-2222-2222-222222222222',
                'amount': 9900,
                'currency': 'krw',
                'status': 'PAID',
                'paidAt': '2026-06-21T09:30:00Z',
                'createdAt': '2026-06-21T09:00:00Z',
                'receiptAvailable': true,
              },
            ],
            'page': 0,
            'size': 20,
            'totalElements': 1,
            'totalPages': 1,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = BillingApi(dio);

    final page = await api.getPayments();

    expect(page.items, hasLength(1));
    expect(page.items.single.amount, 9900);
    expect(page.items.single.currency, 'krw');
    expect(page.items.single.receiptAvailable, isTrue);
  });

  test('getReceipt maps invoice URLs', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(
          options.path,
          '/api/v1/billing/payments/11111111-1111-1111-1111-111111111111/receipt',
        );
        return ResponseBody.fromString(
          jsonEncode({
            'paymentId': '11111111-1111-1111-1111-111111111111',
            'invoiceUrl': 'https://billing.stripe.test/invoice',
            'invoicePdfUrl': 'https://billing.stripe.test/invoice.pdf',
            'available': true,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = BillingApi(dio);

    final receipt = await api.getReceipt(
      '11111111-1111-1111-1111-111111111111',
    );

    expect(receipt.available, isTrue);
    expect(receipt.invoicePdfUrl, 'https://billing.stripe.test/invoice.pdf');
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
