import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/knowledge/features/search/data/datasources/knowledge_search_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/search/data/repositories/knowledge_search_repository_impl.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_mode.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/repositories/knowledge_search_repository.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/usecases/search_knowledge_usecase.dart';

final _knowledgeSearchRemoteDatasourceProvider =
    Provider<KnowledgeSearchRemoteDatasource>((Ref ref) {
  return KnowledgeSearchRemoteDatasource(ref.watch(dioProvider));
});

final _knowledgeSearchRepositoryProvider =
    Provider<KnowledgeSearchRepository>((Ref ref) {
  return KnowledgeSearchRepositoryImpl(
    ref.watch(_knowledgeSearchRemoteDatasourceProvider),
  );
});

final searchKnowledgeUseCaseProvider =
    Provider<SearchKnowledgeUseCase>((Ref ref) {
  return SearchKnowledgeUseCase(ref.watch(_knowledgeSearchRepositoryProvider));
});

class KnowledgeSearchState {
  const KnowledgeSearchState({
    required this.query,
    required this.mode,
    required this.result,
  });

  const KnowledgeSearchState.initial()
      : query = '',
        mode = KnowledgeSearchMode.semantic,
        result = const AsyncData<KnowledgeSearchResult>(
          KnowledgeSearchResult.empty(),
        );

  final String query;
  final KnowledgeSearchMode mode;
  final AsyncValue<KnowledgeSearchResult> result;

  bool get hasQuery => query.trim().isNotEmpty;

  KnowledgeSearchState copyWith({
    String? query,
    KnowledgeSearchMode? mode,
    AsyncValue<KnowledgeSearchResult>? result,
  }) {
    return KnowledgeSearchState(
      query: query ?? this.query,
      mode: mode ?? this.mode,
      result: result ?? this.result,
    );
  }
}

class KnowledgeSearchNotifier extends Notifier<KnowledgeSearchState> {
  static const Duration _debounceDuration = Duration(milliseconds: 350);

  Timer? _debounceTimer;
  int _requestId = 0;

  @override
  KnowledgeSearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const KnowledgeSearchState.initial();
  }

  void updateQuery(String query) {
    _debounceTimer?.cancel();
    final String trimmedQuery = query.trim();
    state = state.copyWith(query: query);

    if (trimmedQuery.isEmpty) {
      state = state.copyWith(
        result: const AsyncData<KnowledgeSearchResult>(
          KnowledgeSearchResult.empty(),
        ),
      );
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(_runSearch(trimmedQuery, state.mode));
    });
  }

  Future<void> submitSearch() async {
    _debounceTimer?.cancel();
    final String trimmedQuery = state.query.trim();
    if (trimmedQuery.isEmpty) {
      state = state.copyWith(
        result: const AsyncData<KnowledgeSearchResult>(
          KnowledgeSearchResult.empty(),
        ),
      );
      return;
    }

    await _runSearch(trimmedQuery, state.mode);
  }

  Future<void> setMode(KnowledgeSearchMode mode) async {
    if (state.mode == mode) {
      return;
    }

    _debounceTimer?.cancel();
    state = state.copyWith(mode: mode);

    final String trimmedQuery = state.query.trim();
    if (trimmedQuery.isEmpty) {
      return;
    }

    await _runSearch(trimmedQuery, mode);
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const KnowledgeSearchState.initial();
  }

  Future<void> _runSearch(
    String query,
    KnowledgeSearchMode mode,
  ) async {
    final int currentRequestId = ++_requestId;
    state = state.copyWith(
      result: const AsyncLoading<KnowledgeSearchResult>(),
    );

    try {
      final SearchKnowledgeUseCase useCase =
          ref.read(searchKnowledgeUseCaseProvider);
      final KnowledgeSearchResult result = await useCase(
        query: query,
        mode: mode,
      );

      if (currentRequestId != _requestId) {
        return;
      }

      state = state.copyWith(
        result: AsyncData<KnowledgeSearchResult>(result),
      );
    } catch (error, stackTrace) {
      if (currentRequestId != _requestId) {
        return;
      }

      state = state.copyWith(
        result: AsyncError<KnowledgeSearchResult>(error, stackTrace),
      );
    }
  }
}

final knowledgeSearchNotifierProvider =
    NotifierProvider<KnowledgeSearchNotifier, KnowledgeSearchState>(
  KnowledgeSearchNotifier.new,
);
