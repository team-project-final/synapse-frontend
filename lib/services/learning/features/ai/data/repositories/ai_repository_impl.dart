import 'package:synapse_frontend/services/learning/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/entities/generated_card.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl(this._datasource);
  final AiRemoteDatasource _datasource;

  @override
  Future<List<GeneratedCard>> generateCards({
    required String noteContent,
    required int cardCount,
  }) async {
    final model = await _datasource.generateCards(
      noteContent: noteContent,
      cardCount: cardCount,
    );
    return model.cards
        .map((c) => GeneratedCard(front: c.front, back: c.back))
        .toList();
  }

  @override
  Stream<String> qaStream(String question) => _datasource.qaStream(question);
}
