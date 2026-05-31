import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/features/community/presentation/screens/community_screens.dart';

// 커뮤니티 화면(그룹 목록/상세/에디터/공유덱/공유노트) reskin 후 렌더 검증.
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
    'CommunityGroupsScreen': const CommunityGroupsScreen(),
    'CommunityGroupDetailScreen':
        const CommunityGroupDetailScreen(groupId: '1'),
    'CommunityGroupEditorScreen': const CommunityGroupEditorScreen(),
    'SharedDecksScreen': const SharedDecksScreen(),
    'SharedDeckDetailScreen': const SharedDeckDetailScreen(deckId: '1'),
    'SharedNotesScreen': const SharedNotesScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  // v1 ⑪: 그룹 메타("승인제·8/20명·공유덱3") + 주간 랭킹(본인 강조)이 보이는지.
  testWidgets('CommunityGroups v1 디테일 노출', (tester) async {
    await pump(tester, const CommunityGroupsScreen(), mobile);
    expect(find.text('승인제 · 8/20명 · 공유덱 3'), findsOneWidget);
    expect(find.text('가입됨'), findsWidgets);
    expect(find.textContaining('🥇'), findsOneWidget);
    expect(find.textContaining('🥉 나'), findsOneWidget);
  });
}
