import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/presentation/screens/note_screens.dart';

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
}
