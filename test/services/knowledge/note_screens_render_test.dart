import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/presentation/screens/note_screens.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/providers/notes_providers.dart';

// AI Tutor 컨셉 reskin 후 노트 화면들이 데스크탑/모바일에서 RenderFlex 등
// 레이아웃 예외 없이 렌더링되는지 검증한다. analyze로는 못 잡는 런타임
// unbounded-constraints 크래시를 surface size를 바꿔가며 pump 후 확인한다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    // setSurfaceSize는 MediaQuery.sizeOf를 바꾸지 못하므로(테스트 기본 800px
    // 유지), 반응형 분기를 실제로 검증하려면 MediaQuery로 size를 명시 주입한다.
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
    'NoteListScreen': const NoteListScreen(),
    'NoteDetailScreen': const NoteDetailScreen(noteId: '1'),
    'NoteEditorScreen': const NoteEditorScreen(noteId: '1'),
    'NoteVersionsScreen': const NoteVersionsScreen(noteId: '1'),
    'TagManagementScreen': const TagManagementScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  // 1단계(API 연동): 상세 화면이 noteDetailProvider 데이터로 제목/태그를
  // 렌더하는지 검증한다. (본문은 contentMd 마크다운, 위키링크는 5단계로 분리)
  testWidgets('NoteDetail 상세 데이터 렌더 (API 연동)', (tester) async {
    final Note note = Note(
      id: '1',
      title: '정규화 기법 (Regularization)',
      contentMd: '# 정규화\n\nL1/L2 정규화는 과적합을 방지한다.',
      contentPlain: 'L1/L2 정규화는 과적합을 방지한다.',
      tags: const <String>['머신러닝', '딥러닝'],
      status: 'active',
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );

    final Note backlink = Note(
      id: '9',
      title: '과적합 노트',
      contentMd: '과적합 설명',
      contentPlain: '과적합은 학습 데이터에 과하게 맞춰진 상태다.',
      tags: const <String>['머신러닝'],
      status: 'active',
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );

    await tester.binding.setSurfaceSize(mobile);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteDetailProvider('1').overrideWith((Ref ref) => note),
          backlinksProvider('1').overrideWith((Ref ref) => <Note>[backlink]),
          outlinksProvider('1').overrideWith((Ref ref) => const <Note>[]),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(size: mobile),
            child: Scaffold(body: NoteDetailScreen(noteId: '1')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('정규화 기법 (Regularization)'), findsOneWidget);
    expect(find.text('#머신러닝'), findsOneWidget);
    // 백링크 연동: 라벨에 개수 + 백링크 노트 제목 렌더
    expect(find.text('백링크 1'), findsOneWidget);
    expect(find.text('과적합 노트'), findsOneWidget);
    // 아웃링크 연동: 라벨에 개수(0) 렌더
    expect(find.text('아웃링크 0'), findsOneWidget);
  });

  // 5a(API 연동): 목록 화면이 인기태그 필터칩 + notesListProvider 데이터를 렌더.
  testWidgets('NoteList 필터칩(인기태그) + 목록 렌더 (API 연동)', (tester) async {
    final List<Note> notes = <Note>[
      Note(
        id: '1',
        title: '정규화 기법',
        contentMd: '# 정규화',
        contentPlain: 'L1/L2 정규화',
        tags: const <String>['머신러닝'],
        status: 'active',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 2),
      ),
    ];

    await tester.binding.setSurfaceSize(desktop);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          popularTagsProvider.overrideWith(
            (Ref ref) => <PopularTag>[const PopularTag(tag: '머신러닝', count: 3)],
          ),
          notesListProvider(null).overrideWith((Ref ref) => notes),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(size: desktop),
            child: Scaffold(body: NoteListScreen()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('머신러닝'), findsOneWidget); // 필터칩
    expect(find.text('정규화 기법'), findsOneWidget); // 노트 카드
  });

  // 4단계(API 연동): 버전 이력 화면이 noteVersionsProvider 데이터로 버전 목록을 렌더.
  testWidgets('NoteVersions 버전 목록 렌더 (API 연동)', (tester) async {
    final List<NoteVersionSummary> versions = <NoteVersionSummary>[
      NoteVersionSummary(versionNo: 2, title: 'L2 정규화 설명 추가', createdAt: DateTime(2026, 6, 1, 14, 32)),
      NoteVersionSummary(versionNo: 1, title: '최초 작성', createdAt: DateTime(2026, 5, 30, 9, 15)),
    ];

    await tester.binding.setSurfaceSize(mobile);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteVersionsProvider('1').overrideWith((Ref ref) => versions),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(size: mobile),
            child: Scaffold(body: NoteVersionsScreen(noteId: '1')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('v2'), findsOneWidget);
    expect(find.text('L2 정규화 설명 추가'), findsOneWidget);
    expect(find.text('복원'), findsWidgets);
  });

  // v1 ④ 편집 화면: `[[` 입력 시 위키링크 자동완성 드롭다운이 크래시 없이
  // 뜨는지 확인한다. (드롭다운 진입 분기를 실제로 타게 한다)
  // noteId='new' 로 신규 작성 진입(기존 노트 로드 없이 즉시 에디터 렌더).
  // 제목칸이 첫 TextField 이므로 본문칸(.last)에 입력한다.
  testWidgets('NoteEditor [[ 자동완성 드롭다운 렌더', (tester) async {
    await pump(tester, const NoteEditorScreen(noteId: 'new'), desktop);
    await tester.enterText(find.byType(TextField).last, '핵심은 [[어텐');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('위키링크 자동완성'), findsOneWidget);
    expect(find.text('어텐션 메커니즘'), findsWidgets);
  });
}
