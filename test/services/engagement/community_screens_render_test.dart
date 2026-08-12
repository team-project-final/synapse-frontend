import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/services/engagement/features/community/presentation/screens/community_screens.dart';

import 'fake_engagement_api.dart';

// 커뮤니티 화면(그룹 목록/상세/에디터/공유덱/공유노트) reskin 후 렌더 검증.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Size size, {
    FakeEngagementApi? api,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engagementApiProvider.overrideWithValue(api ?? FakeEngagementApi()),
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

  testWidgets('그룹 상세에 그룹 공유 콘텐츠 목록이 노출된다', (tester) async {
    final api = FakeEngagementApi()
      ..groupSharedContent = [
        SharedContent(
          id: '21',
          shareToken: 'group-token-1',
          contentType: 'DECK',
          contentId: '301',
          ownerId: '100',
          title: '그룹 전용 덱',
          description: '그룹 멤버만 열람할 수 있습니다.',
          tags: const ['스터디'],
          downloadCount: 0,
          groupId: '1',
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      ];

    await pump(
      tester,
      const CommunityGroupDetailScreen(groupId: '1'),
      desktop,
      api: api,
    );
    await tester.scrollUntilVisible(find.text('그룹 전용 덱'), 200);

    expect(find.text('그룹 전용 덱'), findsOneWidget);
    expect(find.text('그룹 멤버만 열람할 수 있습니다.'), findsOneWidget);
  });

  testWidgets('그룹 공유 콘텐츠가 비면 빈 상태 문구가 노출된다', (tester) async {
    await pump(
      tester,
      const CommunityGroupDetailScreen(groupId: '1'),
      desktop,
      api: FakeEngagementApi(),
    );
    await tester.scrollUntilVisible(find.text('아직 공유된 콘텐츠가 없습니다.'), 200);

    expect(find.text('아직 공유된 콘텐츠가 없습니다.'), findsOneWidget);
  });

  testWidgets('그룹 공유 콘텐츠 403이면 가입 안내가 노출된다', (tester) async {
    final requestOptions = RequestOptions(
      path: '/api/v1/community/groups/1/shared-content',
    );
    final api = FakeEngagementApi()
      ..groupSharedContentError = DioException(
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 403,
        ),
      );

    await pump(
      tester,
      const CommunityGroupDetailScreen(groupId: '1'),
      desktop,
      api: api,
    );
    await tester.scrollUntilVisible(find.text('가입 후 열람할 수 있습니다.'), 200);

    expect(find.text('가입 후 열람할 수 있습니다.'), findsOneWidget);
    expect(find.text('공유 콘텐츠를 불러오지 못했습니다.'), findsNothing);
  });
}
