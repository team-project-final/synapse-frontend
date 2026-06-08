import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/shared/utils/csv.dart';

void main() {
  test('toCsv는 헤더와 행을 CRLF로 결합한다', () {
    final csv = toCsv(
      ['a', 'b'],
      [
        ['1', '2'],
        ['3', '4'],
      ],
    );
    expect(csv, 'a,b\r\n1,2\r\n3,4');
  });

  test('쉼표/따옴표/줄바꿈이 포함되면 인용·이스케이프된다', () {
    final csv = toCsv(
      ['x'],
      [
        ['a,b'],
        ['he said "hi"'],
        ['line1\nline2'],
      ],
    );
    expect(csv, 'x\r\n"a,b"\r\n"he said ""hi"""\r\n"line1\nline2"');
  });
}
