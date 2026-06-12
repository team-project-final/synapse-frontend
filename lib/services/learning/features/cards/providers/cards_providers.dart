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

// ── 데모용 더미 데이터 ─────────────────────────────────────────────────────
// 백엔드 미연결 상태에서 복습 탭 전체 흐름을 시연할 수 있도록 제공.
// API 성공 시 이 데이터는 사용되지 않음.

const _kMockSessionId = 'mock-session';

const _kMockDecks = <Deck>[
  Deck(id: 'mock-deck-1', name: '운영체제 핵심 개념', description: '프로세스, 스레드, 메모리 관리 등 OS 핵심 이론', color: '💻'),
  Deck(id: 'mock-deck-2', name: '자료구조와 알고리즘', description: '스택, 큐, 트리, 그래프, 정렬 알고리즘 총정리', color: '📊'),
  Deck(id: 'mock-deck-3', name: '네트워크 기초', description: 'HTTP, TCP/IP, DNS, 보안 프로토콜 개념 정리', color: '🌐'),
];

const _kMockFlashCards = <FlashCard>[
  FlashCard(id: 'mock-fc-1', deckId: 'mock-deck', cardType: 'basic', frontContent: '프로세스(Process)와 스레드(Thread)의 차이는?', backContent: '프로세스는 독립된 메모리 공간을 가지는 실행 단위.\n스레드는 프로세스 내 메모리를 공유하는 경량 실행 단위로, 컨텍스트 전환 비용이 더 낮습니다.'),
  FlashCard(id: 'mock-fc-2', deckId: 'mock-deck', cardType: 'basic', frontContent: 'TCP 3-way Handshake 순서는?', backContent: 'SYN → SYN-ACK → ACK\n클라이언트가 SYN을 보내고, 서버가 SYN-ACK로 응답하고, 클라이언트가 ACK로 연결을 확정합니다.'),
  FlashCard(id: 'mock-fc-3', deckId: 'mock-deck', cardType: 'basic', frontContent: '빅오 O(log n) 시간복잡도 알고리즘 예시는?', backContent: '이진 탐색(Binary Search).\n매 단계마다 탐색 범위가 절반으로 줄어들기 때문에 O(log n)입니다.'),
  FlashCard(id: 'mock-fc-4', deckId: 'mock-deck', cardType: 'basic', frontContent: '스택(Stack)과 큐(Queue)의 차이는?', backContent: '스택: LIFO — 가장 나중에 넣은 것을 먼저 꺼냄.\n큐: FIFO — 가장 먼저 넣은 것을 먼저 꺼냄.'),
  FlashCard(id: 'mock-fc-5', deckId: 'mock-deck', cardType: 'basic', frontContent: 'HTTP와 HTTPS의 차이는?', backContent: 'HTTPS = HTTP + TLS/SSL 암호화.\n데이터를 암호화해 중간자 공격(MITM)을 방지하고 서버를 인증합니다.'),
];

const _kMockReviewCards = <ReviewCard>[
  ReviewCard(
    cardId: 'mock-card-1',
    cardType: 'basic',
    frontContent: '프로세스(Process)와 스레드(Thread)의 차이는?',
    backContent: '프로세스는 독립된 메모리 공간을 가지는 실행 단위.\n스레드는 프로세스 내 메모리를 공유하는 경량 실행 단위로, 컨텍스트 전환 비용이 더 낮습니다.',
  ),
  ReviewCard(
    cardId: 'mock-card-2',
    cardType: 'basic',
    frontContent: 'TCP 3-way Handshake 순서는?',
    backContent: 'SYN → SYN-ACK → ACK\n클라이언트가 SYN을 보내고, 서버가 SYN-ACK로 응답하고, 클라이언트가 ACK로 연결을 확정합니다.',
  ),
  ReviewCard(
    cardId: 'mock-card-3',
    cardType: 'basic',
    frontContent: '빅오 O(log n) 시간복잡도 알고리즘 예시는?',
    backContent: '이진 탐색(Binary Search).\n매 단계마다 탐색 범위가 절반으로 줄어들기 때문에 O(log n)입니다.',
  ),
  ReviewCard(
    cardId: 'mock-card-4',
    cardType: 'basic',
    frontContent: '스택(Stack)과 큐(Queue)의 차이는?',
    backContent: '스택: LIFO — 가장 나중에 넣은 것을 먼저 꺼냄.\n큐: FIFO — 가장 먼저 넣은 것을 먼저 꺼냄.',
  ),
  ReviewCard(
    cardId: 'mock-card-5',
    cardType: 'basic',
    frontContent: 'HTTP와 HTTPS의 차이는?',
    backContent: 'HTTPS = HTTP + TLS/SSL 암호화.\n데이터를 암호화해 중간자 공격(MITM)을 방지하고 서버를 인증합니다.',
  ),
];

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
    try {
      final decks = await ref.watch(listDecksUseCaseProvider).call();
      return decks.isEmpty ? _kMockDecks : decks;
    } catch (_) {
      return _kMockDecks;
    }
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
  if (deckId.startsWith('mock-deck-')) return _kMockFlashCards;
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
    } catch (_) {
      state = const ReviewState(sessionId: _kMockSessionId, queue: _kMockReviewCards);
    }
  }

  Future<void> submitRating(int rating) async {
    final s = state;
    if (s.sessionId == null || s.currentCard == null || s.isSubmitting) return;
    state = s.copyWith(isSubmitting: true, error: null);

    // 더미 세션: API 없이 로컬에서 처리
    if (s.sessionId == _kMockSessionId) {
      final card = s.currentCard!;
      final intervalDays = rating >= 3 ? 9 : 1;
      final result = ReviewSubmitResult(
        cardId: card.cardId,
        rating: rating,
        newEaseFactor: 2.5,
        newIntervalDays: intervalDays,
        lapses: rating < 2 ? 1 : 0,
        dueDate: DateTime.now().add(Duration(days: intervalDays)),
      );
      final updatedResults = [...s.submittedResults, result];
      final nextIndex = s.currentIndex + 1;
      if (nextIndex >= s.queue.length) {
        final completed = ReviewSession(
          sessionId: _kMockSessionId,
          deckId: 'mock-deck',
          status: 'completed',
          totalCards: _kMockReviewCards.length,
          reviewedCards: _kMockReviewCards.length,
        );
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
      return;
    }

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
  try {
    final queue = await ref.read(getReviewQueueUseCaseProvider).call(deckId);
    return queue.length;
  } catch (_) {
    return _kMockReviewCards.length;
  }
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
