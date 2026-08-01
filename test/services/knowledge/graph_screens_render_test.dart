import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/knowledge/features/graph/presentation/screens/graph_screens.dart';
import 'package:synapse_frontend/services/knowledge/providers/knowledge_providers.dart';

import 'fake_knowledge_api.dart';

// 그래프 뷰/노트 그래프/클러스터 화면 reskin 후 데스크탑/모바일 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [knowledgeApiProvider.overrideWithValue(FakeKnowledgeApi())],
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
    'GraphViewScreen': const GraphViewScreen(),
    'GraphNoteScreen': const GraphNoteScreen(noteId: '1'),
    'GraphClustersScreen': const GraphClustersScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  // v1 ⑧: 태그 색상 범례 + AI 허브 분석 코멘트가 보이는지.
  testWidgets('GraphView 범례 + AI 허브 분석 노출', (tester) async {
    await pump(tester, const GraphViewScreen(), desktop);
    expect(find.text('머신러닝'), findsWidgets);
    expect(find.text('알고리즘'), findsWidgets);
    expect(find.textContaining('PageRank'), findsOneWidget);
  });
}
