import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        iconColor: AppColors.primaryAmber,
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
        iconColor: AppColors.stone500,
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

    final content = ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Today section
        Text('오늘',
            style: textTheme.labelMedium
                ?.copyWith(color: AppColors.stone400)),
        const SizedBox(height: AppSpacing.sm),
        ...todayNotifs.map((n) => _NotificationItem(notif: n)),
        const SizedBox(height: AppSpacing.md),
        // Yesterday section
        Text('어제',
            style: textTheme.labelMedium
                ?.copyWith(color: AppColors.stone400)),
        const SizedBox(height: AppSpacing.sm),
        ...yesterdayNotifs.map((n) => _NotificationItem(notif: n)),
      ],
    );

    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.sm, 0),
          child: Row(
            children: [
              Text('알림 센터', style: textTheme.titleLarge),
              const Spacer(),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: notif.isRead ? null : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: notif.isRead ? AppColors.stone200 : colorScheme.primary.withValues(alpha: 0.2),
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
                          color: AppColors.info,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(notif.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: notif.isRead ? null : FontWeight.w600,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(notif.time,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone400)),
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
  bool _reviewReminder = true;
  bool _communityNotif = true;
  bool _achievementNotif = true;
  bool _emailNotif = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 설정 조회/저장 API 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('알림 설정', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Text('알림 설정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          title: const Text('복습 리마인더'),
          subtitle: const Text('매일 복습 시간에 알림을 받습니다'),
          value: _reviewReminder,
          onChanged: (v) => setState(() => _reviewReminder = v),
        ),
        SwitchListTile(
          title: const Text('커뮤니티 알림'),
          subtitle: const Text('그룹 활동 및 새 콘텐츠 알림'),
          value: _communityNotif,
          onChanged: (v) => setState(() => _communityNotif = v),
        ),
        SwitchListTile(
          title: const Text('성취/배지 알림'),
          subtitle: const Text('레벨업 및 배지 획득 알림'),
          value: _achievementNotif,
          onChanged: (v) => setState(() => _achievementNotif = v),
        ),
        SwitchListTile(
          title: const Text('이메일 알림'),
          subtitle: const Text('이메일로 주요 알림을 받습니다'),
          value: _emailNotif,
          onChanged: (v) => setState(() => _emailNotif = v),
        ),
        const Divider(),
        ListTile(
          title: const Text('방해금지 시간'),
          subtitle: const Text('22:00 ~ 08:00'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — 방해금지 시간 설정 다이얼로그
            },
            child: const Text('설정'),
          ),
        ),
      ],
    );
  }
}
