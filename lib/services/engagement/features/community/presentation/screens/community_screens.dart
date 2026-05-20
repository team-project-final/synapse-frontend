import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [Tab(text: '내 그룹'), Tab(text: '탐색')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _EmptyGroupList(
                  message: '가입한 그룹이 없습니다',
                  actionLabel: '그룹 만들기',
                  onAction: () =>
                      context.go(AppRoutes.communityGroupNew),
                ),
                const _EmptyGroupList(
                  message: '공개 그룹이 없습니다',
                ),
                // TODO: 팀원 구현 — engagement-svc 그룹 목록 API 연동
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupList extends StatelessWidget {
  const _EmptyGroupList({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 64, color: AppColors.stone300),
          const SizedBox(height: AppSpacing.md),
          Text(message,
              style: textTheme.bodyLarge
                  ?.copyWith(color: AppColors.stone400)),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Group Detail (tab: members / shared content) ──

class CommunityGroupDetailScreen extends ConsumerWidget {
  const CommunityGroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('그룹명', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('멤버 0명 · 공유 덱 0개',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.stone500)),
                // TODO: 팀원 구현 — engagement-svc 그룹 상세 API 연동
              ],
            ),
          ),
          const TabBar(
              tabs: [Tab(text: '멤버'), Tab(text: '공유 콘텐츠')]),
          Expanded(
            child: TabBarView(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline,
                          size: 48, color: AppColors.stone300),
                      const SizedBox(height: AppSpacing.md),
                      Text('멤버가 없습니다',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone400)),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined,
                          size: 48, color: AppColors.stone300),
                      const SizedBox(height: AppSpacing.md),
                      Text('공유된 콘텐츠가 없습니다',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone400)),
                    ],
                  ),
                ),
                // TODO: 팀원 구현 — engagement-svc 멤버/콘텐츠 API 연동
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Remaining screens (placeholders) ──

class CommunityGroupEditorScreen extends ConsumerWidget {
  const CommunityGroupEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '그룹 생성/편집',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-003',
      routeHint: '/community/groups/new',
    );
  }
}

class SharedDecksScreen extends ConsumerWidget {
  const SharedDecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '공유 덱 탐색',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-004',
      routeHint: '/community/shared-decks',
    );
  }
}

class SharedDeckDetailScreen extends ConsumerWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '공유 덱 상세',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-005',
      routeHint: '/community/shared-decks/$deckId',
    );
  }
}

class SharedNotesScreen extends ConsumerWidget {
  const SharedNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '공유 노트 탐색',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-006',
      routeHint: '/community/shared-notes',
    );
  }
}
