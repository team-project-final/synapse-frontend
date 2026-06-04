import 'package:synapse_frontend/services/learning/features/ai/domain/repositories/ai_repository.dart';

class QaStreamUseCase {
  const QaStreamUseCase(this._repo);
  final AiRepository _repo;

  Stream<String> call(String question) => _repo.qaStream(question);
}
