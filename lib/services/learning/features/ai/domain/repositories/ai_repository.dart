import 'package:synapse_frontend/services/learning/features/ai/domain/entities/generated_card.dart';

abstract class AiRepository {
  Future<List<GeneratedCard>> generateCards({
    required String noteContent,
    required int cardCount,
  });

  Stream<String> qaStream(String question);
}
