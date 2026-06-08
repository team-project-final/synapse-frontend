part of '../community_screens.dart';

// ── SharedNoteDetailScreen (SCR-W-COMM-006) ──
// 공유 노트 상세. 공유 덱 상세(SharedDeckDetailScreen)의 노트 버전.
// 복사하기(fork) · 신고 · (소유자)공유 취소 + 본문/태그/백링크 미리보기.

class SharedNoteDetailScreen extends ConsumerWidget {
  const SharedNoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  // TODO: 팀원 구현 — 실제 소유자 여부로 교체. 데모용으로 공유 취소 노출.
  static const bool _isSharedByMe = true;

  static const _title = '정규화 기법 (Regularization)';
  static const _tags = ['머신러닝', '딥러닝', '과적합'];
  static const _body =
      'L1/L2 정규화는 모델의 과적합을 막기 위해 손실 함수에 가중치 페널티를 '
      '더하는 기법입니다.\n\n'
      '• L1(Lasso): 가중치의 절댓값 합을 페널티로 두어 일부 가중치를 0으로 만들어 '
      '특성 선택 효과가 있습니다.\n'
      '• L2(Ridge): 가중치의 제곱 합을 페널티로 두어 가중치를 전반적으로 작게 '
      '유지합니다.\n\n'
      'Dropout, Early Stopping 과 함께 쓰면 일반화 성능이 더 좋아집니다.';
  static const _backlinks = ['과적합 방지', '경사 하강법', 'L2 Ridge 회귀'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — engagement-svc 공유 노트 상세 API 연동 (noteId: $noteId)
    return ConceptPage(
      children: [
        // Header
        Text(_title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '이러닝',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.schedule, size: 14, color: AppColors.stone400),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '3일 전 수정',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.bookmark_border,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '백링크 ${_backlinks.length}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Tags
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [for (final t in _tags) ConceptTag('#$t')],
        ),
        const SizedBox(height: AppSpacing.md),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  AppToast.show(
                    context,
                    message: '노트가 내 라이브러리에 복사되었습니다',
                    type: ToastType.success,
                  );
                  // TODO: 팀원 구현 — 노트 복사(fork) API 연동
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => ReportDialog.show(context, targetTitle: _title),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('신고'),
            ),
          ],
        ),
        // 내가 공유한 콘텐츠면 공유 취소(삭제) 가능.
        if (_isSharedByMe) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: '공유 취소',
                content: '이 노트의 공유를 취소하면 그룹에서 더 이상 보이지 않습니다. 계속할까요?',
                confirmLabel: '공유 취소',
                isDestructive: true,
              );
              if (ok == true && context.mounted) {
                AppToast.show(
                  context,
                  message: '공유가 취소되었습니다',
                  type: ToastType.success,
                );
                // TODO: 팀원 구현 — 공유 취소(삭제) API 연동
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('공유 취소'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        // Body preview
        Text('본문 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Text(
            _body,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Backlinks
        Text('연결된 노트', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        for (final b in _backlinks)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link, color: AppColors.primary),
            title: Text(b, style: textTheme.bodyMedium),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.stone400,
            ),
            onTap: () {
              // TODO: 팀원 구현 — 연결 노트로 이동
            },
          ),
      ],
    );
  }
}
