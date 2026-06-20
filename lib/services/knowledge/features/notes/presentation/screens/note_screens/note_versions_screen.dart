part of '../note_screens.dart';

// ── NoteVersionsScreen (SCR-W-NOTE-004) ──

class NoteVersionsScreen extends ConsumerStatefulWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteVersionsScreen> createState() => _NoteVersionsScreenState();
}

class _NoteVersionsScreenState extends ConsumerState<NoteVersionsScreen> {
  String? _selectedVersion;

  // TODO: 팀원 구현 — knowledge-svc 버전 이력 API 연동
  final _mockVersions = [
    {'version': 'v3', 'date': '2026-05-20 14:32', 'desc': 'L2 정규화 설명 추가'},
    {'version': 'v2', 'date': '2026-05-19 09:15', 'desc': '예시 코드 수정'},
    {'version': 'v1', 'date': '2026-05-18 20:00', 'desc': '최초 작성'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '버전 이력'),
        Text(
          '노트 ID: ${widget.noteId}',
          style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._mockVersions.map(
          (v) => _VersionItem(
            version: v['version']!,
            date: v['date']!,
            description: v['desc']!,
            isSelected: _selectedVersion == v['version'],
            onTap: () => setState(() => _selectedVersion = v['version']),
          ),
        ),
        if (_selectedVersion != null) ...[
          ConceptSectionLabel('변경 사항 ($_selectedVersion)'),
          const _DiffView(),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _VersionItem extends StatelessWidget {
  const _VersionItem({
    required this.version,
    required this.date,
    required this.description,
    this.isSelected = false,
    this.onTap,
  });
  final String version;
  final String date;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        onTap: onTap,
        highlightBorder: isSelected,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                version,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    date,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                // TODO: 팀원 구현 — 버전 복원 API 연동
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('복원'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffView extends StatelessWidget {
  const _DiffView();

  static const _oldLines = [
    _DiffLine('### L1 정규화 (Lasso)', false),
    _DiffLine('- 가중치의 절댓값 합을 페널티로 추가', false),
    _DiffLine('- 특성 선택 효과가 있음', true),
    _DiffLine('', false),
    _DiffLine('### L2 정규화 (Ridge)', false),
    _DiffLine('- 가중치의 제곱합을 페널티로 추가', false),
  ];

  static const _newLines = [
    _DiffLine('### L1 정규화 (Lasso)', false),
    _DiffLine('- 가중치의 절댓값 합을 페널티로 추가', false),
    _DiffLine('- 일부 가중치를 0으로 만들어 희소성 유도', true),
    _DiffLine('', false),
    _DiffLine('### L2 정규화 (Ridge)', false),
    _DiffLine('- 가중치의 제곱합을 페널티로 추가', false),
    _DiffLine('- 가중치를 작게 유지하되 0으로 만들지 않음', true),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final monoStyle =
        textTheme.bodySmall?.copyWith(fontFamily: 'monospace') ??
        const TextStyle(fontFamily: 'monospace', fontSize: 12);

    // 비균일 색 Border + borderRadius 조합으로 인한 렌더 이슈를 피하기 위해
    // ClipRRect로 모서리를 클립하고 내부를 분리한다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Old (left)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      color: AppColors.surface2,
                      child: Text(
                        '이전',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    ..._oldLines.map(
                      (line) => Container(
                        width: double.infinity,
                        color: line.changed ? const Color(0x20DC2626) : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Text(
                          line.changed ? '- ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.error : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: AppColors.border),
              // New (right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      color: AppColors.surface2,
                      child: Text(
                        '현재',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    ..._newLines.map(
                      (line) => Container(
                        width: double.infinity,
                        color: line.changed ? const Color(0x2016A34A) : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Text(
                          line.changed ? '+ ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.success : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffLine {
  const _DiffLine(this.text, this.changed);
  final String text;
  final bool changed;
}
