import 'package:synapse_frontend/core/platform/csv_download_stub.dart'
    if (dart.library.html) 'package:synapse_frontend/core/platform/csv_download_web.dart'
    as csv_download;

/// CSV 내용을 파일로 내려받는다(웹 전용). 비웹 플랫폼에서는 미지원.
void downloadCsv(String filename, String content) {
  csv_download.downloadCsv(filename, content);
}
