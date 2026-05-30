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
}
