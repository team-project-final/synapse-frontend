/// 간단한 CSV 직렬화 (RFC 4180 인용 규칙, CRLF 줄바꿈).
String toCsv(List<String> headers, List<List<String>> rows) {
  final lines = <String>[_row(headers), ...rows.map(_row)];
  return lines.join('\r\n');
}

String _row(List<String> fields) => fields.map(_escape).join(',');

String _escape(String value) {
  if (value.contains('"') ||
      value.contains(',') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
