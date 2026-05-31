import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/features/gamification/presentation/screens/gamification_screens.dart';

// 게이미피케이션 화면(프로필/배지/리더보드) reskin 후 데스크탑/모바일 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
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

  for (final entry in <String, Widget>{
    'GamificationProfileScreen': const GamificationProfileScreen(),
    'BadgeGalleryScreen': const BadgeGalleryScreen(),
    'LeaderboardScreen': const LeaderboardScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  // v1 ⑩: 프로필의 핵심 디테일(레벨/XP·스트릭 최고/배지 5/8)이 보이는지.
  testWidgets('GamificationProfile v1 디테일 노출', (tester) async {
    await pump(tester, const GamificationProfileScreen(), mobile);
    expect(find.text('레벨 7 · 지식 탐험가'), findsOneWidget);
    expect(find.text('Lv 8까지 360'), findsOneWidget);
    expect(find.text('연속 · 최고 21일'), findsOneWidget);
    expect(find.text('배지 5 / 8'), findsOneWidget);
  });
}
