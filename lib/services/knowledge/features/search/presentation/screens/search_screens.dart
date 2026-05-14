import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '통합 검색',
      domain: 'SEARCH',
      screenId: 'SCR-W-SEARCH-001',
      routeHint: '/search',
    );
  }
}

class AiQaScreen extends ConsumerWidget {
  const AiQaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: 'AI Q&A',
      domain: 'SEARCH',
      screenId: 'SCR-W-SEARCH-002',
      routeHint: '/qa',
    );
  }
}
