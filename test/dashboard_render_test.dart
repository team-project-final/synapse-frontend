import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  // 주어진 화면 크기로 DashboardScreen을 렌더링하고 예외가 없는지 확인한다.
  // RenderFlex unbounded-constraints 단언은 analyze로 안 잡히고 실제 레이아웃 시에만
  // 드러나므로, surface size를 바꿔가며 pump 후 takeException으로 검증한다.
  Future<void> pumpDashboard(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );

    // pumpAndSettle은 무한 애니메이션(LinearProgressIndicator 등)에서 hang 될 수
    // 있어 고정 시간으로 두 번 pump 한다.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('데스크탑(1440x900)에서 RenderFlex 예외 없이 렌더링된다',
      (tester) async {
    await pumpDashboard(tester, const Size(1440, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('모바일(390x844)에서 RenderFlex 예외 없이 렌더링된다',
      (tester) async {
    await pumpDashboard(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
}
