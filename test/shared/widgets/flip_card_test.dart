import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/shared/widgets/flip_card.dart';

void main() {
  testWidgets('FlipCard shows front by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCard(
            front: Text('질문'),
            back: Text('정답'),
          ),
        ),
      ),
    );

    expect(find.text('질문'), findsOneWidget);
  });

  testWidgets('FlipCard flips on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCard(
            front: Text('질문'),
            back: Text('정답'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();

    expect(find.text('정답'), findsOneWidget);
  });
}
