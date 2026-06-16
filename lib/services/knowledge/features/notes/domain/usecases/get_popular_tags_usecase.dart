import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class GetPopularTagsUseCase {
  const GetPopularTagsUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<List<PopularTag>> call() {
    return _repository.getPopularTags();
  }
}
