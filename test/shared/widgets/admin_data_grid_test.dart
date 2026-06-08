import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/shared/widgets/admin_data_grid.dart';

void main() {
  Future<void> pumpGrid(WidgetTester tester, AdminDataGrid grid) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: grid),
      ),
    );
  }

  const columns = [DataColumn(label: Text('A'))];
  final rows = [
    const DataRow(cells: [DataCell(Text('row'))]),
  ];

  testWidgets('onSearch는 검색어 제출 시 호출된다', (tester) async {
    String? submitted;
    await pumpGrid(
      tester,
      AdminDataGrid(
        columns: columns,
        rows: rows,
        onSearch: (v) => submitted = v,
      ),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, 'hello');
  });

  testWidgets('검색 콜백이 없으면 검색창이 비활성이다', (tester) async {
    await pumpGrid(tester, AdminDataGrid(columns: columns, rows: rows));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('onFilterSelected는 칩 선택 시 라벨을 전달한다(전체=null)', (tester) async {
    final selected = <String?>[];
    await pumpGrid(
      tester,
      AdminDataGrid(
        columns: columns,
        rows: rows,
        filters: const ['활성', '정지'],
        onFilterSelected: selected.add,
      ),
    );

    await tester.tap(find.text('정지'));
    await tester.pump();
    await tester.tap(find.text('전체'));
    await tester.pump();

    expect(selected, ['정지', null]);
  });

  testWidgets('페이지네이션: 다음 버튼은 마지막 페이지가 아닐 때만 활성', (tester) async {
    int? requested;
    await pumpGrid(
      tester,
      AdminDataGrid(
        columns: columns,
        rows: rows,
        page: 0,
        totalPages: 3,
        totalElements: 50,
        onPageChanged: (p) => requested = p,
      ),
    );

    expect(find.text('1 / 3 · 총 50건'), findsOneWidget);

    // 이전(왼쪽)은 첫 페이지라 비활성, 다음(오른쪽)은 활성.
    final prev = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left));
    expect(prev.onPressed, isNull);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    expect(requested, 1);
  });
}
