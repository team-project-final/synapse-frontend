// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

void downloadCsv(String filename, String content) {
  // Excel이 한글을 올바로 읽도록 UTF-8 BOM(U+FEFF)을 앞에 붙인다.
  final bom = String.fromCharCode(0xFEFF);
  final bytes = utf8.encode('$bom$content');
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
