import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/learning/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:synapse_frontend/services/learning/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/entities/generated_card.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/repositories/ai_repository.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/usecases/generate_cards_usecase.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/usecases/qa_stream_usecase.dart';

// ── DI 체인 ──

final _aiRemoteDatasourceProvider = Provider<AiRemoteDatasource>((ref) {
  return AiRemoteDatasource(ref.watch(aiDioProvider));
});

final _aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(ref.watch(_aiRemoteDatasourceProvider));
});

final generateCardsUseCaseProvider = Provider<GenerateCardsUseCase>((ref) {
  return GenerateCardsUseCase(ref.watch(_aiRepositoryProvider));
});

final qaStreamUseCaseProvider = Provider<QaStreamUseCase>((ref) {
  return QaStreamUseCase(ref.watch(_aiRepositoryProvider));
});

// ── 카드 생성 대화 상태 ──

sealed class AiConvItem { const AiConvItem(); }

class AiTextMsg extends AiConvItem {
  const AiTextMsg({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class AiCardsMsg extends AiConvItem {
  const AiCardsMsg(this.cards);
  final List<GeneratedCard> cards;
}

class AiLoadingMsg extends AiConvItem {
  const AiLoadingMsg();
}

class AiErrorMsg extends AiConvItem {
  const AiErrorMsg(this.message);
  final String message;
}

class CardGenState {
  const CardGenState({this.conversation = const [], this.isLoading = false});
  final List<AiConvItem> conversation;
  final bool isLoading;

  CardGenState copyWith({List<AiConvItem>? conversation, bool? isLoading}) =>
      CardGenState(
        conversation: conversation ?? this.conversation,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CardGenNotifier extends Notifier<CardGenState> {
  @override
  CardGenState build() => const CardGenState();

  Future<void> generate({required String input, required int cardCount}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      conversation: [
        ...state.conversation,
        AiTextMsg(isUser: true, text: input),
        const AiLoadingMsg(),
      ],
      isLoading: true,
    );

    try {
      final useCase = ref.read(generateCardsUseCaseProvider);
      final cards = await useCase(noteContent: input, cardCount: cardCount);

      final conv = List<AiConvItem>.from(state.conversation)
        ..removeLast()
        ..add(AiTextMsg(
          isUser: false,
          text: '${cards.length}장의 카드를 만들었어요. 추가할 카드를 골라주세요 👇',
        ))
        ..add(AiCardsMsg(cards));
      state = state.copyWith(conversation: conv, isLoading: false);
    } on DioException catch (e) {
      final conv = List<AiConvItem>.from(state.conversation)
        ..removeLast()
        ..add(AiErrorMsg(
            '서버 오류 (${e.response?.statusCode ?? '연결 실패'}). 다시 시도해주세요.'));
      state = state.copyWith(conversation: conv, isLoading: false);
    } catch (_) {
      final conv = List<AiConvItem>.from(state.conversation)
        ..removeLast()
        ..add(const AiErrorMsg('카드 생성에 실패했습니다. 다시 시도해주세요.'));
      state = state.copyWith(conversation: conv, isLoading: false);
    }
  }
}

final cardGenNotifierProvider =
    NotifierProvider<CardGenNotifier, CardGenState>(CardGenNotifier.new);

// ── Q&A 스트리밍 상태 ──

class QaMessage {
  const QaMessage({required this.isUser, required this.text});
  final bool isUser;
  final String text;

  QaMessage copyWithText(String text) => QaMessage(isUser: isUser, text: text);
}

class QaState {
  const QaState({this.messages = const [], this.isStreaming = false});
  final List<QaMessage> messages;
  final bool isStreaming;

  QaState copyWith({List<QaMessage>? messages, bool? isStreaming}) => QaState(
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
      );
}

class QaNotifier extends Notifier<QaState> {
  @override
  QaState build() => const QaState();

  Future<void> sendMessage(String question) async {
    if (state.isStreaming) return;

    final withUser = [
      ...state.messages,
      QaMessage(isUser: true, text: question),
      const QaMessage(isUser: false, text: ''),
    ];
    final aiIndex = withUser.length - 1;
    state = state.copyWith(messages: withUser, isStreaming: true);

    final buffer = StringBuffer();
    try {
      final useCase = ref.read(qaStreamUseCaseProvider);
      await for (final chunk in useCase(question)) {
        buffer.write(chunk);
        final updated = List<QaMessage>.from(state.messages);
        updated[aiIndex] = updated[aiIndex].copyWithText(buffer.toString());
        state = state.copyWith(messages: updated);
      }
    } catch (_) {
      final updated = List<QaMessage>.from(state.messages);
      updated[aiIndex] =
          updated[aiIndex].copyWithText('오류가 발생했습니다. 다시 시도해주세요.');
      state = state.copyWith(messages: updated, isStreaming: false);
      return;
    }

    if (buffer.isEmpty) {
      final updated = List<QaMessage>.from(state.messages);
      updated[aiIndex] =
          updated[aiIndex].copyWithText('응답을 받지 못했습니다. 다시 시도해주세요.');
      state = state.copyWith(messages: updated, isStreaming: false);
      return;
    }

    state = state.copyWith(isStreaming: false);
  }
}

final qaNotifierProvider =
    NotifierProvider<QaNotifier, QaState>(QaNotifier.new);
