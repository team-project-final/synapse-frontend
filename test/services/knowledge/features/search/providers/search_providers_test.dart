import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_item.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_mode.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/repositories/knowledge_search_repository.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/usecases/search_knowledge_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/search/providers/search_providers.dart';

void main() {
  group('KnowledgeSearchNotifier', () {
    test('should load hybrid-backed semantic results when semantic mode submits', () async {
      final FakeKnowledgeSearchRepository repository =
          FakeKnowledgeSearchRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          searchKnowledgeUseCaseProvider.overrideWith(
            (Ref ref) => SearchKnowledgeUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final KnowledgeSearchNotifier notifier =
          container.read(knowledgeSearchNotifierProvider.notifier);

      notifier.updateQuery('regularization');
      await notifier.submitSearch();

      expect(repository.semanticQuery, 'regularization');
      expect(
        repository.keywordQuery,
        isNull,
      );
      expect(
        container.read(knowledgeSearchNotifierProvider).result.value?.items,
        hasLength(1),
      );
    });

    test('should call keyword search when mode changes to keyword', () async {
      final FakeKnowledgeSearchRepository repository =
          FakeKnowledgeSearchRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          searchKnowledgeUseCaseProvider.overrideWith(
            (Ref ref) => SearchKnowledgeUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final KnowledgeSearchNotifier notifier =
          container.read(knowledgeSearchNotifierProvider.notifier);

      notifier.updateQuery('graph');
      await notifier.setMode(KnowledgeSearchMode.keyword);

      expect(repository.keywordQuery, 'graph');
      expect(
        container.read(knowledgeSearchNotifierProvider).mode,
        KnowledgeSearchMode.keyword,
      );
    });

    test('should not call search when query is empty', () async {
      final FakeKnowledgeSearchRepository repository =
          FakeKnowledgeSearchRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          searchKnowledgeUseCaseProvider.overrideWith(
            (Ref ref) => SearchKnowledgeUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final KnowledgeSearchNotifier notifier =
          container.read(knowledgeSearchNotifierProvider.notifier);

      notifier.updateQuery('   ');
      await notifier.submitSearch();

      expect(repository.semanticQuery, isNull);
      expect(repository.keywordQuery, isNull);
      expect(
        container.read(knowledgeSearchNotifierProvider).hasQuery,
        isFalse,
      );
    });
  });
}

class FakeKnowledgeSearchRepository implements KnowledgeSearchRepository {
  String? semanticQuery;
  String? keywordQuery;

  @override
  Future<KnowledgeSearchResult> searchKeyword({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    keywordQuery = query;
    return const KnowledgeSearchResult(
      items: <KnowledgeSearchItem>[
        KnowledgeSearchItem(
          noteId: '2',
          title: 'Keyword Result',
          snippet: 'keyword snippet',
          highlights: <String>['keyword snippet'],
        ),
      ],
      totalCount: 1,
      hasNext: false,
    );
  }

  @override
  Future<KnowledgeSearchResult> searchSemantic({
    required String query,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    semanticQuery = query;
    return const KnowledgeSearchResult(
      items: <KnowledgeSearchItem>[
        KnowledgeSearchItem(
          noteId: '1',
          title: 'Semantic Result',
          snippet: 'semantic snippet',
          highlights: <String>['semantic snippet'],
        ),
      ],
      totalCount: 1,
      hasNext: false,
    );
  }
}
