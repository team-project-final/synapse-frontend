import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/learning_review_api.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

final learningReviewApiProvider = Provider<LearningReviewApi>((ref) {
  return LearningReviewApi(ref.watch(dioProvider));
});

final learningDecksProvider = FutureProvider.autoDispose<LearningDeckPage>((
  ref,
) async {
  final tenant = await ref.watch(currentTenantProvider.future);
  return ref.watch(learningReviewApiProvider).listDecks(tenantId: tenant.id);
});

final reviewNotifierProvider = NotifierProvider<ReviewNotifier, ReviewState>(
  ReviewNotifier.new,
);

class ReviewState {
  const ReviewState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.decks = const [],
    this.selectedDeckId,
    this.session,
    this.cards = const [],
    this.currentIndex = 0,
    this.results = const [],
    this.completedSession,
    this.startedAt,
    this.cardStartedAt,
    this.elapsedMs = 0,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final List<LearningDeck> decks;
  final String? selectedDeckId;
  final ReviewSession? session;
  final List<ReviewCard> cards;
  final int currentIndex;
  final List<ReviewSubmitResult> results;
  final ReviewSession? completedSession;
  final DateTime? startedAt;
  final DateTime? cardStartedAt;
  final int elapsedMs;

  ReviewCard? get currentCard {
    if (currentIndex < 0 || currentIndex >= cards.length) return null;
    return cards[currentIndex];
  }

  int get totalCards =>
      cards.isNotEmpty ? cards.length : session?.totalCards ?? 0;

  int get reviewedCards => results.length;

  bool get hasNoDecks =>
      !isLoading && session == null && decks.isEmpty && errorMessage == null;

  bool get hasNoDueCards =>
      !isLoading && session != null && cards.isEmpty && errorMessage == null;

  bool get isCompleted => completedSession != null;

  int get rememberedCount =>
      results.where((result) => result.isRemembered).length;

  double get accuracy {
    if (results.isEmpty) return 0;
    return rememberedCount / results.length;
  }

  String get selectedDeckName {
    final selected = selectedDeckId;
    if (selected == null) return '선택한 덱';
    for (final deck in decks) {
      if (deck.id == selected) return deck.name;
    }
    return '선택한 덱';
  }

  ReviewState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    List<LearningDeck>? decks,
    Object? selectedDeckId = _unset,
    Object? session = _unset,
    List<ReviewCard>? cards,
    int? currentIndex,
    List<ReviewSubmitResult>? results,
    Object? completedSession = _unset,
    Object? startedAt = _unset,
    Object? cardStartedAt = _unset,
    int? elapsedMs,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      decks: decks ?? this.decks,
      selectedDeckId: identical(selectedDeckId, _unset)
          ? this.selectedDeckId
          : selectedDeckId as String?,
      session: identical(session, _unset)
          ? this.session
          : session as ReviewSession?,
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      completedSession: identical(completedSession, _unset)
          ? this.completedSession
          : completedSession as ReviewSession?,
      startedAt: identical(startedAt, _unset)
          ? this.startedAt
          : startedAt as DateTime?,
      cardStartedAt: identical(cardStartedAt, _unset)
          ? this.cardStartedAt
          : cardStartedAt as DateTime?,
      elapsedMs: elapsedMs ?? this.elapsedMs,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  @override
  ReviewState build() => const ReviewState();

  Future<void> start({String? deckId}) async {
    state = ReviewState(
      isLoading: true,
      selectedDeckId: _blankToNull(deckId),
      startedAt: DateTime.now(),
    );

    try {
      final tenant = await ref.read(currentTenantProvider.future);
      final api = ref.read(learningReviewApiProvider);
      final requestedDeckId = _blankToNull(deckId);
      final decks = requestedDeckId == null
          ? (await api.listDecks(tenantId: tenant.id)).items
          : const <LearningDeck>[];
      final selectedDeckId =
          requestedDeckId ?? (decks.isEmpty ? null : decks.first.id);

      if (selectedDeckId == null) {
        state = const ReviewState(decks: []);
        return;
      }

      final session = await api.startSession(
        tenantId: tenant.id,
        deckId: selectedDeckId,
      );
      final cards = await api.getReviewQueue(
        tenantId: tenant.id,
        deckId: selectedDeckId,
      );

      state = ReviewState(
        decks: decks,
        selectedDeckId: selectedDeckId,
        session: session,
        cards: cards,
        startedAt: DateTime.now(),
        cardStartedAt: DateTime.now(),
      );
    } catch (error) {
      state = ReviewState(
        selectedDeckId: _blankToNull(deckId),
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<bool> submitRating(int rating, {required int timeSpentMs}) async {
    final session = state.session;
    final card = state.currentCard;
    if (session == null || card == null || state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final tenant = await ref.read(currentTenantProvider.future);
      final api = ref.read(learningReviewApiProvider);
      final result = await api.submitReview(
        tenantId: tenant.id,
        sessionId: session.id,
        cardId: card.id,
        rating: rating,
        timeSpentMs: timeSpentMs,
      );
      final results = [...state.results, result];
      final nextIndex = state.currentIndex + 1;

      if (nextIndex >= state.cards.length) {
        final completed = await api.completeSession(
          tenantId: tenant.id,
          sessionId: session.id,
        );
        state = state.copyWith(
          isSubmitting: false,
          results: results,
          completedSession: completed,
          currentIndex: state.currentIndex,
          elapsedMs: _elapsedMs(state.startedAt),
          cardStartedAt: null,
        );
        return true;
      }

      state = state.copyWith(
        isSubmitting: false,
        results: results,
        currentIndex: nextIndex,
        cardStartedAt: DateTime.now(),
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }
}

const _unset = Object();

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

int _elapsedMs(DateTime? startedAt) {
  if (startedAt == null) return 0;
  return DateTime.now().difference(startedAt).inMilliseconds;
}

String _friendlyError(Object error) {
  final text = error.toString();
  if (text.isEmpty) return '복습 데이터를 불러오지 못했습니다.';
  return text;
}
