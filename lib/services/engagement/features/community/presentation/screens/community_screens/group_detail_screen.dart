part of '../community_screens.dart';

// -- Group Detail (API-backed) --

class CommunityGroupDetailScreen extends ConsumerWidget {
  const CommunityGroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailValue = ref.watch(communityGroupDetailProvider(groupId));

    return AppAsyncValueWidget<CommunityGroupDetail>(
      value: detailValue,
      loading: const AppLoadingWidget(label: '그룹 상세를 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '그룹 상세를 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(communityGroupDetailProvider(groupId)),
      ),
      data: (detail) => _CommunityGroupDetailView(detail: detail),
    );
  }
}

class _CommunityGroupDetailView extends ConsumerStatefulWidget {
  const _CommunityGroupDetailView({required this.detail});

  final CommunityGroupDetail detail;

  @override
  ConsumerState<_CommunityGroupDetailView> createState() =>
      _CommunityGroupDetailViewState();
}

class _CommunityGroupDetailViewState
    extends ConsumerState<_CommunityGroupDetailView> {
  bool _joining = false;
  bool _reporting = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final group = detail.group;
    final members = detail.members;
    final textTheme = Theme.of(context).textTheme;
    final sharedValue = ref.watch(groupSharedContentProvider(group.id));

    return ConceptPage(
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.surface,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.groups_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.visibilityLabel} · 멤버 ${detail.activeMemberCount}명 · ${group.ownerLabel}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.stone500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (group.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ConceptCard(
            child: Text(
              group.description,
              style: textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _joining ? null : _joinGroup,
                icon: _joining
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_outlined, size: 18),
                label: Text(group.isPublic ? '가입' : '가입 신청'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: _reporting ? null : _reportGroup,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('신고'),
            ),
          ],
        ),
        const ConceptSectionLabel('멤버'),
        if (members.isEmpty)
          const AppEmptyState(
            icon: Icons.people_outline,
            title: '표시할 멤버가 없습니다.',
          )
        else
          ConceptCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                for (var i = 0; i < members.length; i++)
                  _MemberRow(
                    member: members[i],
                    showDivider: i < members.length - 1,
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        const ConceptSectionLabel('그룹 공유 콘텐츠'),
        AppAsyncValueWidget<List<SharedContent>>(
          value: sharedValue,
          loading: const AppLoadingWidget(label: '공유 콘텐츠를 불러오는 중입니다.'),
          error: (error, _) {
            // 그룹 비멤버는 403 — 오류가 아니라 가입 유도 안내로 처리한다.
            final isForbidden =
                error is DioException && error.response?.statusCode == 403;
            if (isForbidden) {
              return Text(
                '가입 후 열람할 수 있습니다.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.stone500,
                ),
              );
            }
            return AppErrorWidget(
              message: '공유 콘텐츠를 불러오지 못했습니다.',
              onRetry: () =>
                  ref.invalidate(groupSharedContentProvider(group.id)),
            );
          },
          data: (items) {
            if (items.isEmpty) {
              return Text(
                '아직 공유된 콘텐츠가 없습니다.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.stone500,
                ),
              );
            }
            return ConceptCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  for (final item in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.title),
                      subtitle: item.description.isEmpty
                          ? null
                          : Text(item.description),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const ConceptSectionLabel('그룹 정보'),
        ConceptCard(
          child: Column(
            children: [
              _InfoRow(label: '그룹 ID', value: group.id),
              _InfoRow(label: '공개 상태', value: group.visibilityLabel),
              _InfoRow(label: '소유자', value: group.ownerLabel),
              _InfoRow(label: '생성일', value: group.createdLabel),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _joinGroup() async {
    final group = widget.detail.group;
    setState(() => _joining = true);
    try {
      final member = await ref.read(engagementApiProvider).joinGroup(group.id);
      ref.invalidate(communityGroupDetailProvider(group.id));
      if (mounted) {
        final message = member.active ? '그룹에 가입했습니다' : '가입 신청이 접수되었습니다';
        AppToast.show(context, message: message, type: ToastType.success);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '그룹 가입 요청을 처리하지 못했습니다',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _reportGroup() async {
    final group = widget.detail.group;
    final result = await ReportDialog.show(context, targetTitle: group.name);
    if (result == null) return;
    setState(() => _reporting = true);
    final detail = result['detail']?.trim();
    final reason = [
      result['reason'] ?? '',
      if (detail != null && detail.isNotEmpty) detail,
    ].where((part) => part.isNotEmpty).join(' · ');
    try {
      await ref
          .read(engagementApiProvider)
          .createReport(
            targetType: 'STUDY_GROUP',
            targetId: group.id,
            reason: reason,
          );
      if (mounted) {
        AppToast.show(context, message: '신고가 접수되었습니다', type: ToastType.success);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '신고를 접수하지 못했습니다',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.showDivider});

  final CommunityGroupMember member;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roleColor = member.role == 'OWNER'
        ? AppColors.primaryAmber
        : member.role == 'ADMIN'
        ? AppColors.primary
        : AppColors.stone500;

    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              member.userId.isEmpty ? '?' : member.userId.substring(0, 1),
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  member.joinedAt == null
                      ? member.statusLabel
                      : '${member.statusLabel} · ${member.joinedLabel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.stone500,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              member.roleLabel,
              style: textTheme.labelSmall?.copyWith(color: roleColor),
            ),
            backgroundColor: roleColor.withValues(alpha: 0.1),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
