import 'package:synapse_frontend/services/learning/features/ai/domain/entities/generated_card.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/repositories/ai_repository.dart';

class GenerateCardsUseCase {
  const GenerateCardsUseCase(this._repo);
  final AiRepository _repo;

  Future<List<GeneratedCard>> call({
    required String noteContent,
    required int cardCount,
  }) =>
      _repo.generateCards(noteContent: noteContent, cardCount: cardCount);
}
