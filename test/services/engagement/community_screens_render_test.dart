import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/services/engagement/features/community/presentation/screens/community_screens.dart';

import 'fake_engagement_api.dart';

// 커뮤니티 화면(그룹 목록/상세/에디터/공유덱/공유노트) reskin 후 렌더 검증.
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
    'CommunityGroupsScreen': const CommunityGroupsScreen(),
    'CommunityGroupDetailScreen': const CommunityGroupDetailScreen(
      groupId: '1',
    ),
    'CommunityGroupEditorScreen': const CommunityGroupEditorScreen(),
    'SharedDecksScreen': const SharedDecksScreen(),
    'SharedDeckDetailScreen': const SharedDeckDetailScreen(
      deckId: 'deck-token-1',
    ),
    'SharedNotesScreen': const SharedNotesScreen(),
    'SharedNoteDetailScreen': const SharedNoteDetailScreen(
      noteId: 'note-token-1',
    ),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  testWidgets('CommunityGroups API-backed 디테일 노출', (tester) async {
    await pump(tester, const CommunityGroupsScreen(), mobile);
    expect(find.text('AWS 자격증 스터디'), findsOneWidget);
    expect(find.textContaining('소유자 #100'), findsOneWidget);
    expect(find.text('클라우드 자격증 준비를 위한 그룹입니다.'), findsOneWidget);
    expect(find.text('보기'), findsWidgets);
  });

  testWidgets('CommunityGroupDetail API-backed 멤버 노출', (tester) async {
    await pump(tester, const CommunityGroupDetailScreen(groupId: '1'), mobile);
    expect(find.text('AWS 자격증 스터디'), findsOneWidget);
    expect(find.textContaining('멤버 2명'), findsOneWidget);
    expect(find.text('사용자 #100'), findsOneWidget);
    expect(find.text('소유자'), findsWidgets);
  });
}
