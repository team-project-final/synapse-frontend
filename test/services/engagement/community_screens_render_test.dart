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

  // v1 ⑪: 그룹 메타("승인제·8/20명·공유덱3") + 가입 상태 핀이 목록에 보이는지.
  // board 디자인 통합(2026-06-01): 주간 랭킹은 그룹 상세 '공유 콘텐츠' 탭으로 이동
  // (상세 화면 렌더는 위 파라미터 테스트가 커버).
  testWidgets('CommunityGroups v1 디테일 노출', (tester) async {
    await pump(tester, const CommunityGroupsScreen(), mobile);
    expect(find.text('AWS 자격증 스터디'), findsOneWidget);
    expect(find.text('승인제 · 8/20명 · 공유덱 3'), findsOneWidget);
    expect(find.text('가입됨'), findsWidgets);
  });
}
