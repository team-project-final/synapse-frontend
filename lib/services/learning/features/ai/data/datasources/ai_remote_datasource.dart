import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/learning/features/ai/data/models/ai_card_generate_response_model.dart';

class AiRemoteDatasource {
  const AiRemoteDatasource(this._dio);
  final Dio _dio;

  Future<AiCardGenerateResponseModel> generateCards({
    required String noteContent,
    required int cardCount,
  }) async {
    final prompt = '다음 내용에서 $cardCount개의 플래시카드를 생성해주세요:\n\n$noteContent';
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/cards/generate',
      data: {
        'prompt': prompt,
        'max_tokens': cardCount * 150 + 512,
        'temperature': 0.7,
      },
    );
    return AiCardGenerateResponseModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  // 백엔드 SSE 형식:
  //   data: {"text": "..."}\n\n  (청크)
  //   data: {"sources": [...], "done": true}\n\n
  //   data: [DONE]\n\n
  Stream<String> qaStream(String question) async* {
    final response = await _dio.post<ResponseBody>(
      '/ai/qa',
      data: {'question': question, 'stream': true},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final lineBuffer = StringBuffer();
    await for (final chunk
        in response.data!.stream.cast<List<int>>().transform(utf8.decoder)) {
      lineBuffer.write(chunk);
      final raw = lineBuffer.toString();
      final lines = raw.split('\n');
      lineBuffer.clear();

      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('data: ')) continue;
        final payload = line.substring(6);
        if (payload == '[DONE]') return;
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final text = json['text'];
          if (text != null) yield text as String;
        } catch (_) {}
      }
      // 마지막 줄은 불완전할 수 있으므로 버퍼에 유지
      lineBuffer.write(lines.last);
    }
  }
}
