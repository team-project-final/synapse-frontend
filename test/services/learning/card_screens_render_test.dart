import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/learning/features/cards/presentation/screens/card_screens.dart';

// AI Tutor 컨셉 reskin 후 카드/덱/복습 화면이 데스크탑/모바일에서 레이아웃
// 예외 없이 렌더링되는지 검증. setSurfaceSize는 MediaQuery를 못 바꾸므로
// MediaQuery로 size를 명시 주입해 반응형 분기를 실제로 태운다.
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
    'DeckListScreen': const DeckListScreen(),
    'CardListScreen': const CardListScreen(deckId: '1'),
    'CardEditorScreen': const CardEditorScreen(),
    'AiCardGenerationScreen': const AiCardGenerationScreen(),
    'ReviewScreen': const ReviewScreen(),
    'ReviewResultScreen': const ReviewResultScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }

  // v1 ⑤: gencard 체크 토글 시 addbar "N장 선택됨"이 갱신되는지.
  testWidgets('AiCardGeneration 카드 토글 → 선택 수 갱신', (tester) async {
    await pump(tester, const AiCardGenerationScreen(), desktop);
    expect(find.text('3장 선택됨'), findsOneWidget);
    // 미선택 4번째 카드(어텐션과 RNN) 체크 → 4장
    await tester.tap(find.text('Q. 어텐션과 RNN의 차이는?'));
    await tester.pump(const Duration(milliseconds: 300));
    // 체크박스 자체를 탭(텍스트 탭은 체크 안 됨) — 마지막 체크박스
    await tester.tap(find.byType(Checkbox).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('4장 선택됨'), findsOneWidget);
    // skip 사유: PR #18에서 AI 카드 생성 화면을 API 연동으로 재작성하며 기본 목업
    // 카드(3장 기본 표시)가 제거되어 이 검증이 무효가 됨.
    // TODO: 화면 소유자(#18) — 새 API 흐름에 맞게 테스트 갱신 후 skip 해제.
  }, skip: true);

  // v1 ⑥: "한 단계 더 힌트" 탭 시 2단계 힌트가 추가로 뜨는지.
  testWidgets('Review 단계별 AI 힌트 확장', (tester) async {
    await pump(tester, const ReviewScreen(), desktop);
    expect(find.text('💡 한 단계 더 힌트 받기'), findsOneWidget);
    await tester.tap(find.text('💡 한 단계 더 힌트 받기'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('힌트 2'), findsOneWidget);
    // 2단계까지 다 보여주면 버튼은 사라진다
    expect(find.text('💡 한 단계 더 힌트 받기'), findsNothing);
  });
}
