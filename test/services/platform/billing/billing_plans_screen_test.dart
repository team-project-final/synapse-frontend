import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/billing/data/billing_api.dart';
import 'package:synapse_frontend/services/platform/features/billing/presentation/screens/billing_screens.dart';

void main() {
  testWidgets('paid plan button creates checkout and redirects', (
    tester,
  ) async {
    final api = _FakeBillingApi();
    final redirects = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billingApiProvider.overrideWithValue(api),
          billingCheckoutRedirectProvider.overrideWithValue(redirects.add),
        ],
        child: const MaterialApp(home: Scaffold(body: BillingPlansScreen())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('billing-plan-pro-button')));
    await tester.pumpAndSettle();

    expect(api.checkoutPlans, ['PRO']);
    expect(redirects, ['https://checkout.stripe.test/pro']);
  });

  testWidgets('free plan is displayed without checkout action', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billingApiProvider.overrideWithValue(_FakeBillingApi()),
          billingCheckoutRedirectProvider.overrideWithValue((_) {}),
        ],
        child: const MaterialApp(home: Scaffold(body: BillingPlansScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('billing-plan-free-current')), findsOneWidget);
    expect(find.byKey(const Key('billing-plan-free-button')), findsNothing);
  });
}

class _FakeBillingApi extends BillingApi {
  _FakeBillingApi() : super(Dio());

  final checkoutPlans = <String>[];

  @override
  Future<BillingSubscription?> getSubscription() async => null;

  @override
  Future<CheckoutSession> createCheckout({
    required String planCode,
    required String successUrl,
    required String cancelUrl,
  }) async {
    checkoutPlans.add(planCode);
    return CheckoutSession(
      'https://checkout.stripe.test/${planCode.toLowerCase()}',
    );
  }
}
