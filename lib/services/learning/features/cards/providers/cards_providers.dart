import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/datasources/cards_remote_datasource.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/repositories/cards_repository_impl.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_stats.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_submit_result.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/batch_create_cards_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/complete_review_session_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/create_card_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/create_deck_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/delete_card_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/delete_deck_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/get_review_queue_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/list_cards_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/list_decks_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/start_review_session_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/submit_review_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/update_card_usecase.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/usecases/update_deck_usecase.dart';

typedef SharedDeckParams = ({String deckId, String sharedContentId, String shareToken});

// ── DI 체인 ──

final _cardsRemoteDatasourceProvider = Provider<CardsRemoteDatasource>((ref) {
  return CardsRemoteDatasource(ref.watch(learningDioProvider));
});

final _cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepositoryImpl(ref.watch(_cardsRemoteDatasourceProvider));
});

// ── UseCase 프로바이더 ──

final listDecksUseCaseProvider = Provider<ListDecksUseCase>((ref) {
  return ListDecksUseCase(ref.watch(_cardsRepositoryProvider));
});

final createDeckUseCaseProvider = Provider<CreateDeckUseCase>((ref) {
  return CreateDeckUseCase(ref.watch(_cardsRepositoryProvider));
});

final updateDeckUseCaseProvider = Provider<UpdateDeckUseCase>((ref) {
  return UpdateDeckUseCase(ref.watch(_cardsRepositoryProvider));
});

final deleteDeckUseCaseProvider = Provider<DeleteDeckUseCase>((ref) {
  return DeleteDeckUseCase(ref.watch(_cardsRepositoryProvider));
});

final listCardsUseCaseProvider = Provider<ListCardsUseCase>((ref) {
  return ListCardsUseCase(ref.watch(_cardsRepositoryProvider));
});

final createCardUseCaseProvider = Provider<CreateCardUseCase>((ref) {
  return CreateCardUseCase(ref.watch(_cardsRepositoryProvider));
});

final batchCreateCardsUseCaseProvider = Provider<BatchCreateCardsUseCase>((ref) {
  return BatchCreateCardsUseCase(ref.watch(_cardsRepositoryProvider));
});

final updateCardUseCaseProvider = Provider<UpdateCardUseCase>((ref) {
  return UpdateCardUseCase(ref.watch(_cardsRepositoryProvider));
});

final deleteCardUseCaseProvider = Provider<DeleteCardUseCase>((ref) {
  return DeleteCardUseCase(ref.watch(_cardsRepositoryProvider));
});

final startReviewSessionUseCaseProvider = Provider<StartReviewSessionUseCase>((ref) {
  return StartReviewSessionUseCase(ref.watch(_cardsRepositoryProvider));
});

final getReviewQueueUseCaseProvider = Provider<GetReviewQueueUseCase>((ref) {
  return GetReviewQueueUseCase(ref.watch(_cardsRepositoryProvider));
});

final submitReviewUseCaseProvider = Provider<SubmitReviewUseCase>((ref) {
  return SubmitReviewUseCase(ref.watch(_cardsRepositoryProvider));
});

final completeReviewSessionUseCaseProvider = Provider<CompleteReviewSessionUseCase>((ref) {
  return CompleteReviewSessionUseCase(ref.watch(_cardsRepositoryProvider));
});

// ── 선택된 덱 ID (ReviewScreen으로 전달) ──

class SelectedDeckIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedDeckIdProvider =
    NotifierProvider<SelectedDeckIdNotifier, String?>(SelectedDeckIdNotifier.new);

// ── DeckList ViewModel ──

class DeckListNotifier extends AsyncNotifier<List<Deck>> {
  @override
  Future<List<Deck>> build() async {
    return ref.watch(listDecksUseCaseProvider).call();
  }

  Future<void> createDeck({required String name, String? description, String? color}) async {
    await ref.read(createDeckUseCaseProvider).call(name: name, description: description, color: color);
    ref.invalidateSelf();
  }

  Future<void> deleteDeck(String deckId) async {
    await ref.read(deleteDeckUseCaseProvider).call(deckId);
    ref.invalidateSelf();
  }
}

final deckListNotifierProvider =
    AsyncNotifierProvider<DeckListNotifier, List<Deck>>(DeckListNotifier.new);

// ── CardList (FutureProvider.family — deckId별 독립 캐시) ──

final cardListProvider = FutureProvider.family<List<FlashCard>, String>((ref, deckId) async {
  return ref.watch(listCardsUseCaseProvider).call(deckId);
});

// ── Review ViewModel ──

class ReviewState {
  const ReviewState({
    this.sessionId,
    this.queue = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isCompleted = false,
    this.completedSession,
    this.submittedResults = const [],
    this.error,
  });

  final String? sessionId;
  final List<ReviewCard> queue;
  final int currentIndex;
  final bool isLoading;
  final bool isSubmitting;
  final bool isCompleted;
  final ReviewSession? completedSession;
  final List<ReviewSubmitResult> submittedResults;
  final String? error;

  ReviewCard? get currentCard =>
      queue.isNotEmpty && currentIndex < queue.length ? queue[currentIndex] : null;

  int get total => queue.length;
  int get reviewed => currentIndex;

  double get accuracy {
    if (submittedResults.isEmpty) return 0;
    final correct = submittedResults.where((r) => r.rating >= 3).length;
    return correct / submittedResults.length;
  }

  int get earnedXp => submittedResults.fold(0, (sum, r) => sum + r.rating * 5);

  ReviewState copyWith({
    String? sessionId,
    List<ReviewCard>? queue,
    int? currentIndex,
    bool? isLoading,
    bool? isSubmitting,
    bool? isCompleted,
    ReviewSession? completedSession,
    List<ReviewSubmitResult>? submittedResults,
    String? error,
  }) {
    return ReviewState(
      sessionId: sessionId ?? this.sessionId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      completedSession: completedSession ?? this.completedSession,
      submittedResults: submittedResults ?? this.submittedResults,
      error: error ?? this.error,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  @override
  ReviewState build() => const ReviewState();

  Future<void> startSession(String deckId) async {
    state = const ReviewState(isLoading: true);
    try {
      final session = await ref.read(startReviewSessionUseCaseProvider).call(deckId);
      final queue = await ref.read(getReviewQueueUseCaseProvider).call(deckId);
      state = ReviewState(sessionId: session.sessionId, queue: queue);
    } catch (e) {
      state = ReviewState(error: e.toString());
    }
  }

  Future<void> submitRating(int rating) async {
    final s = state;
    if (s.sessionId == null || s.currentCard == null || s.isSubmitting) return;
    state = s.copyWith(isSubmitting: true, error: null);
    try {
      final result = await ref.read(submitReviewUseCaseProvider).call(
        sessionId: s.sessionId!,
        cardId: s.currentCard!.cardId,
        rating: rating,
      );
      final updatedResults = [...s.submittedResults, result];
      final nextIndex = s.currentIndex + 1;
      if (nextIndex >= s.queue.length) {
        final completed = await ref.read(completeReviewSessionUseCaseProvider).call(s.sessionId!);
        state = s.copyWith(
          currentIndex: nextIndex,
          isSubmitting: false,
          isCompleted: true,
          completedSession: completed,
          submittedResults: updatedResults,
        );
      } else {
        state = s.copyWith(currentIndex: nextIndex, isSubmitting: false, submittedResults: updatedResults);
      }
    } catch (e) {
      state = s.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  void reset() => state = const ReviewState();
}

final reviewNotifierProvider =
    NotifierProvider<ReviewNotifier, ReviewState>(ReviewNotifier.new);

// ── 오늘 복습 큐 카드 수 (ReviewStartScreen에서 사용) ──

final reviewQueueCountProvider = FutureProvider.family<int, String>((ref, deckId) async {
  final queue = await ref.read(getReviewQueueUseCaseProvider).call(deckId);
  return queue.length;
});

// ── 공유 덱 카드 미리보기 (SharedDeckDetailScreen에서 사용) ──

final sharedDeckCardsProvider = FutureProvider.family<List<FlashCard>, SharedDeckParams>((ref, params) async {
  return ref.read(_cardsRepositoryProvider).getSharedDeckCards(
    params.deckId,
    sharedContentId: params.sharedContentId,
    shareToken: params.shareToken,
  );
});

// ── 복습 통계 개요 (대시보드 타일 + DashboardStatsScreen) ──

final reviewStatsOverviewProvider = FutureProvider<ReviewStats>((ref) async {
  return ref.read(_cardsRepositoryProvider).getStatsOverview();
});

// ── 복습 히트맵 (DashboardHeatmapScreen) ──

final reviewStatsHeatmapProvider = FutureProvider<ReviewHeatmap>((ref) async {
  return ref.read(_cardsRepositoryProvider).getStatsHeatmap();
});

// ── 기억 유지율 (DashboardStatsScreen 기억 유지율 차트) ──

final reviewStatsRetentionProvider = FutureProvider<ReviewRetention>((ref) async {
  return ref.read(_cardsRepositoryProvider).getStatsRetention();
});
