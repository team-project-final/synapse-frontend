import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/billing/data/billing_api.dart';
import 'package:synapse_frontend/services/platform/features/billing/presentation/screens/billing_screens.dart';

void main() {
  group('PaymentHistoryItem.fromJson', () {
    test('필드 매핑 + paidAt 우선 date', () {
      final item = PaymentHistoryItem.fromJson({
        'id': 'p1',
        'amount': 9900,
        'currency': 'KRW',
        'status': 'paid',
        'paidAt': '2026-05-01T00:00:00Z',
        'createdAt': '2026-04-30T00:00:00Z',
        'receiptAvailable': true,
      });

      expect(item.id, 'p1');
      expect(item.amount, 9900);
      expect(item.currency, 'KRW');
      expect(item.receiptAvailable, isTrue);
      expect(item.date, item.paidAt);
    });

    test('paidAt 없으면 date는 createdAt', () {
      final item = PaymentHistoryItem.fromJson({
        'id': 'p2',
        'createdAt': '2026-01-01T00:00:00Z',
      });
      expect(item.paidAt, isNull);
      expect(item.date, item.createdAt);
    });
  });

  group('BillingReceipt.fromJson', () {
    test('bestUrl은 PDF 우선', () {
      final receipt = BillingReceipt.fromJson({
        'available': true,
        'invoiceUrl': 'u',
        'invoicePdfUrl': 'p',
      });
      expect(receipt.bestUrl, 'p');
    });

    test('PDF 없으면 invoiceUrl', () {
      final receipt = BillingReceipt.fromJson({
        'available': true,
        'invoiceUrl': 'u',
      });
      expect(receipt.bestUrl, 'u');
    });
  });

  group('BillingHistoryScreen', () {
    Future<void> pump(
      WidgetTester tester,
      _FakeBillingApi api, {
      void Function(String)? onRedirect,
    }) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            billingApiProvider.overrideWithValue(api),
            billingCheckoutRedirectProvider.overrideWithValue(
              onRedirect ?? (_) {},
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BillingHistoryScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('결제 이력을 로드해 금액·상태를 표시한다', (tester) async {
      await pump(
        tester,
        _FakeBillingApi(
          payments: [
            PaymentHistoryItem(
              id: 'p1',
              amount: 9900,
              currency: 'KRW',
              status: 'paid',
              createdAt: DateTime(2026, 5, 1),
              receiptAvailable: true,
              paidAt: DateTime(2026, 5, 1),
            ),
          ],
        ),
      );

      expect(find.text('₩9,900'), findsOneWidget);
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('이력이 없으면 빈 상태와 요금제 보기 버튼', (tester) async {
      await pump(tester, _FakeBillingApi(payments: const []));
      expect(find.text('결제 이력이 없습니다'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '요금제 보기'), findsOneWidget);
    });

    testWidgets('영수증 버튼이 getReceipt의 PDF URL을 연다', (tester) async {
      String? opened;
      await pump(
        tester,
        _FakeBillingApi(
          payments: [
            PaymentHistoryItem(
              id: 'p1',
              amount: 9900,
              currency: 'KRW',
              status: 'paid',
              createdAt: DateTime(2026, 5, 1),
              receiptAvailable: true,
            ),
          ],
          receipt: const BillingReceipt(
            available: true,
            invoicePdfUrl: 'https://stripe.test/p1.pdf',
          ),
        ),
        onRedirect: (url) => opened = url,
      );

      await tester.tap(find.byTooltip('영수증 보기'));
      await tester.pumpAndSettle();

      expect(opened, 'https://stripe.test/p1.pdf');
    });
  });
}

class _FakeBillingApi extends BillingApi {
  _FakeBillingApi({this.payments = const [], this.receipt}) : super(Dio());

  final List<PaymentHistoryItem> payments;
  final BillingReceipt? receipt;

  @override
  Future<PaymentHistoryPage> getPayments({int page = 0, int size = 20}) async =>
      PaymentHistoryPage(
        items: payments,
        page: 0,
        totalElements: payments.length,
        totalPages: 1,
      );

  @override
  Future<BillingReceipt> getReceipt(String paymentId) async =>
      receipt ?? const BillingReceipt(available: false);
}
