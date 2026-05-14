import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '내 프로필',
      domain: 'GAMIFICATION',
      screenId: 'SCR-W-GAME-001',
      routeHint: '/gamification/profile',
    );
  }
}

class BadgeGalleryScreen extends ConsumerWidget {
  const BadgeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '배지 갤러리',
      domain: 'GAMIFICATION',
      screenId: 'SCR-W-GAME-002',
      routeHint: '/gamification/badges',
    );
  }
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '리더보드',
      domain: 'GAMIFICATION',
      screenId: 'SCR-W-GAME-003',
      routeHint: '/gamification/leaderboard',
    );
  }
}
