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
