part of '../settings_screens.dart';

// ── NotificationSettingsScreen (SCR-W-SETTINGS-003) ──

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // Category × channel grid state
  // Rows: 복습 리마인더, 커뮤니티 활동, 성취/배지, 시스템 알림
  // Columns: Push, Email, InApp
  final List<List<bool>> _notifGrid = [
    [true, false, true], // 복습 리마인더
    [true, true, true], // 커뮤니티 활동
    [true, false, true], // 성취/배지
    [false, true, true], // 시스템 알림
  ];

  static const _categoryLabels = ['복습 리마인더', '커뮤니티 활동', '성취/배지', '시스템 알림'];

  static const _channelLabels = ['Push', 'Email', 'InApp'];

  // RangeSlider는 start<=end를 요구하므로 방해금지 시간을 정렬된 범위로 둔다.
  RangeValues _quietHours = const RangeValues(0, 8);

  String _formatHour(double h) {
    final hour = h.toInt() % 24;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 설정 API 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const ConceptViewHead(title: '알림 설정'),
        const SizedBox(height: AppSpacing.lg),
        Text('카테고리별 알림 설정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),

        // Category × channel grid table
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    '카테고리',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(
                  3,
                  (i) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        _channelLabels[i],
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...List.generate(4, (row) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      _categoryLabels[row],
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  ...List.generate(
                    3,
                    (col) => Center(
                      child: Switch(
                        value: _notifGrid[row][col],
                        onChanged: (v) =>
                            setState(() => _notifGrid[row][col] = v),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Quiet hours
        Text('방해금지 시간', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatHour(_quietHours.start),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
            Text('~', style: textTheme.bodyMedium),
            Text(
              _formatHour(_quietHours.end),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        RangeSlider(
          values: _quietHours,
          min: 0,
          max: 24,
          divisions: 24,
          labels: RangeLabels(
            _formatHour(_quietHours.start),
            _formatHour(_quietHours.end),
          ),
          onChanged: (v) => setState(() => _quietHours = v),
        ),
        Text(
          '이 시간 동안 Push 알림이 비활성화됩니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
