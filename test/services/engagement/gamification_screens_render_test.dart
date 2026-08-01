import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/services/engagement/features/gamification/presentation/screens/gamification_screens.dart';

import 'fake_engagement_api.dart';

// 게이미피케이션 화면(프로필/배지/리더보드) reskin 후 데스크탑/모바일 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engagementApiProvider.overrideWithValue(FakeEngagementApi()),
        ],
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

  testWidgets('GamificationProfile API 디테일 노출', (tester) async {
    await pump(tester, const GamificationProfileScreen(), mobile);
    expect(find.text('레벨 5 · 누적 1,240 XP'), findsOneWidget);
    expect(find.text('Lv 6까지 360'), findsOneWidget);
    expect(find.text('연속 · 최고 9일'), findsOneWidget);
    expect(find.text('획득 배지 2'), findsOneWidget);
  });
}
