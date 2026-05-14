import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '덱 목록',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-001',
      routeHint: '/decks',
    );
  }
}

class CardListScreen extends ConsumerWidget {
  const CardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '카드 목록',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-002',
      routeHint: '/decks/$deckId/cards',
    );
  }
}

class CardEditorScreen extends ConsumerWidget {
  const CardEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '카드 생성/편집',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-003',
      routeHint: '/cards/new',
    );
  }
}

class AiCardGenerationScreen extends ConsumerWidget {
  const AiCardGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: 'AI 카드 생성',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-004',
      routeHint: '/ai/cards',
    );
  }
}

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '복습 화면',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-005',
      routeHint: '/review',
    );
  }
}

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '세션 결과',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-006',
      routeHint: '/review/result',
    );
  }
}
