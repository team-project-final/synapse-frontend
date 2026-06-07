import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── NotificationCenterScreen (SCR-W-NOTI-001) ──

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 목록 API 연동
    const todayNotifs = [
      _Notification(
        icon: Icons.emoji_events,
        title: '레벨업! 지식 탐험가',
        time: '1시간 전',
        isRead: false,
        actionLabel: null,
        iconColor: AppColors.primary,
      ),
      _Notification(
        icon: Icons.style_outlined,
        title: 'AWS 스터디에 새 덱 공유됨',
        time: '3시간 전',
        isRead: true,
        actionLabel: '덱 확인하기 →',
        iconColor: AppColors.info,
      ),
      _Notification(
        icon: Icons.notifications_outlined,
        title: '오늘 복습할 카드 25장',
        time: '오전 9시',
        isRead: true,
        actionLabel: '복습 시작 →',
        iconColor: AppColors.success,
      ),
    ];

    const yesterdayNotifs = [
      _Notification(
        icon: Icons.groups_outlined,
        title: '머신러닝 스터디 그룹에 초대받았습니다',
        time: '어제 오후 6시',
        isRead: true,
        actionLabel: null,
        iconColor: AppColors.muted,
      ),
      _Notification(
        icon: Icons.star_outlined,
        title: '배지 획득: 7일 연속 학습',
        time: '어제 오전 10시',
        isRead: true,
        actionLabel: null,
        iconColor: AppColors.warning,
      ),
    ];

    const thisWeekNotifs = [
      _Notification(
        icon: Icons.download_outlined,
        title: '데이터 내보내기 완료',
        time: '3일 전',
        isRead: true,
        actionLabel: null,
        iconColor: AppColors.muted,
      ),
    ];

    final content = ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Today section
        Text(
          '오늘',
          style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...todayNotifs.map((n) => _NotificationItem(notif: n)),
        const SizedBox(height: AppSpacing.md),
        // Yesterday section
        Text(
          '어제',
          style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...yesterdayNotifs.map((n) => _NotificationItem(notif: n)),
        const SizedBox(height: AppSpacing.md),
        // This week section
        Text(
          '이번 주',
          style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...thisWeekNotifs.map((n) => _NotificationItem(notif: n)),
      ],
    );

    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Text('알림 센터', style: textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: '알림 설정',
                onPressed: () => context.go(AppRoutes.notificationSettings),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 팀원 구현 — 모두 읽음 처리 API 연동
                },
                child: const Text('모두 읽음'),
              ),
            ],
          ),
        ),
        // TabBar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '복습'),
            Tab(text: '커뮤니티'),
            Tab(text: '성취'),
          ],
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(4, (_) => content),
          ),
        ),
      ],
    );
  }
}

class _Notification {
  const _Notification({
    required this.icon,
    required this.title,
    required this.time,
    required this.isRead,
    required this.actionLabel,
    required this.iconColor,
  });
  final IconData icon;
  final String title;
  final String time;
  final bool isRead;
  final String? actionLabel;
  final Color iconColor;
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notif});
  final _Notification notif;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: notif.isRead
            ? AppColors.surface
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: notif.isRead
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: notif.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notif.icon, size: 18, color: notif.iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!notif.isRead) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        notif.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: notif.isRead ? null : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  notif.time,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                if (notif.actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () {
                      // TODO: 팀원 구현 — 알림 액션 처리
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(notif.actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── NotificationPreferenceScreen (SCR-W-NOTI-002) ──

class NotificationPreferenceScreen extends ConsumerStatefulWidget {
  const NotificationPreferenceScreen({super.key});

  @override
  ConsumerState<NotificationPreferenceScreen> createState() =>
      _NotificationPreferenceScreenState();
}

class _NotificationPreferenceScreenState
    extends ConsumerState<NotificationPreferenceScreen> {
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

  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _quietStart : _quietEnd;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietStart = picked;
        } else {
          _quietEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 설정 조회/저장 API 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('알림 설정', style: textTheme.headlineSmall),
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

        // Quiet hours with time pickers
        Text('방해금지 시간', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '이 시간 동안 Push 알림이 비활성화됩니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(isStart: true),
                child: Text('시작: ${_formatTime(_quietStart)}'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('~', style: textTheme.bodyMedium),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(isStart: false),
                child: Text('종료: ${_formatTime(_quietEnd)}'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
