import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/billing/data/billing_api.dart';
import 'package:synapse_frontend/services/platform/features/billing/presentation/screens/billing_screens.dart';

// 결제 화면(플랜/내역/결제반환) reskin 후 데스크탑/모바일 렌더 검증.
// Plans/History는 init에서 API를 호출하므로 fake로 override한다.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Size size, {
    bool overrideBilling = false,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrideBilling
            ? [
                billingApiProvider.overrideWithValue(_FakeBillingApi()),
                billingCheckoutRedirectProvider.overrideWithValue((_) {}),
              ]
            : const [],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  const desktop = Size(1440, 900);
  const mobile = Size(390, 844);

  for (final size in [desktop, mobile]) {
    final label = size == desktop ? '데스크탑' : '모바일';
    testWidgets('BillingPlansScreen $label 렌더', (tester) async {
      await pump(tester, const BillingPlansScreen(), size,
          overrideBilling: true);
    });
    testWidgets('BillingHistoryScreen $label 렌더', (tester) async {
      await pump(
        tester,
        const BillingHistoryScreen(),
        size,
        overrideBilling: true,
      );
    });
    testWidgets('BillingReturnScreen(성공) $label 렌더', (tester) async {
      await pump(tester, const BillingReturnScreen(success: true), size);
    });
  }
}

class _FakeBillingApi extends BillingApi {
  _FakeBillingApi() : super(Dio());

  @override
  Future<BillingSubscription?> getSubscription() async => null;

  @override
  Future<CheckoutSession> createCheckout({
    required String planCode,
    required String successUrl,
    required String cancelUrl,
  }) async =>
      CheckoutSession('https://checkout.test/${planCode.toLowerCase()}');

  @override
  Future<PaymentHistoryPage> getPayments({int page = 0, int size = 20}) async =>
      const PaymentHistoryPage(
        items: [],
        page: 0,
        totalElements: 0,
        totalPages: 1,
      );
}
