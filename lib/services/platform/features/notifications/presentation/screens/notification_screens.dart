import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/providers/notification_providers.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';

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
    final notificationsValue = ref.watch(notificationCenterProvider);
    final page = notificationsValue.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );
    final unreadCount = page?.unreadCount ?? 0;
    final isCompact = MediaQuery.sizeOf(context).width < 480;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '알림 센터',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: () =>
                    ref.read(notificationCenterProvider.notifier).refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: '알림 설정',
                onPressed: () => context.go(AppRoutes.notificationSettings),
              ),
              if (isCompact)
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: '모두 읽음',
                  onPressed: unreadCount == 0
                      ? null
                      : () => ref
                            .read(notificationCenterProvider.notifier)
                            .markAllRead(),
                )
              else
                TextButton.icon(
                  onPressed: unreadCount == 0
                      ? null
                      : () => ref
                            .read(notificationCenterProvider.notifier)
                            .markAllRead(),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(
                    '모두 읽음${unreadCount == 0 ? '' : ' ($unreadCount)'}',
                  ),
                ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '복습'),
            Tab(text: '커뮤니티'),
            Tab(text: '성취'),
          ],
        ),
        Expanded(
          child: AppAsyncValueWidget<NotificationPage>(
            value: notificationsValue,
            loading: const AppLoadingWidget(label: '알림을 불러오는 중입니다.'),
            empty: const AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: '도착한 알림이 없습니다.',
            ),
            isEmpty: (data) => data.notifications.isEmpty,
            error: (error, _) => AppErrorWidget(
              message: '알림을 불러오지 못했습니다.',
              onRetry: () =>
                  ref.read(notificationCenterProvider.notifier).refresh(),
            ),
            data: (data) => TabBarView(
              controller: _tabController,
              children: [
                _NotificationList(notifications: data.notifications),
                _NotificationList(
                  notifications: data.notifications,
                  category: PlatformNotificationCategory.review,
                ),
                _NotificationList(
                  notifications: data.notifications,
                  category: PlatformNotificationCategory.community,
                ),
                _NotificationList(
                  notifications: data.notifications,
                  category: PlatformNotificationCategory.achievement,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.notifications, this.category});

  final List<PlatformNotification> notifications;
  final PlatformNotificationCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = category == null
        ? notifications
        : notifications
              .where((item) => item.category == category)
              .toList(growable: false);

    if (visible.isEmpty) {
      return AppEmptyState(
        icon: Icons.notifications_none_outlined,
        title: category == null
            ? '도착한 알림이 없습니다.'
            : '${category!.label} 알림이 없습니다.',
      );
    }

    final grouped = _groupNotifications(visible);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final entry in grouped.entries) ...[
          Text(
            entry.key,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final notification in entry.value)
            _NotificationItem(notification: notification),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  const _NotificationItem({required this.notification});

  final PlatformNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final icon = _iconForCategory(notification.category);
    final iconColor = _colorForCategory(notification.category);
    final actionLabel = _actionLabelForCategory(notification.category);

    Future<void> handleTap() async {
      if (!notification.isRead) {
        await ref
            .read(notificationCenterProvider.notifier)
            .markRead(notification.id);
      }
      final actionUrl = notification.actionUrl;
      if (context.mounted && actionUrl != null && actionUrl.startsWith('/')) {
        context.go(actionUrl);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: notification.isRead
            ? AppColors.surface
            : AppColors.primary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: handleTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!notification.isRead) ...[
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
                              notification.title,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: notification.isRead
                                    ? null
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (notification.body != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          notification.body!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatNotificationTime(notification.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      if (notification.actionUrl != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        TextButton(
                          onPressed: handleTap,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(actionLabel),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, List<PlatformNotification>> _groupNotifications(
  List<PlatformNotification> notifications,
) {
  final grouped = <String, List<PlatformNotification>>{};
  for (final notification in notifications) {
    final label = _groupLabel(notification.createdAt);
    grouped.putIfAbsent(label, () => []).add(notification);
  }
  return grouped;
}

String _groupLabel(DateTime? createdAt) {
  if (createdAt == null) return '이전';
  final now = DateTime.now();
  final local = createdAt.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(local.year, local.month, local.day);
  final days = today.difference(itemDay).inDays;
  if (days == 0) return '오늘';
  if (days == 1) return '어제';
  if (days < 7) return '이번 주';
  return '이전';
}

String _formatNotificationTime(DateTime? createdAt) {
  if (createdAt == null) return '방금 전';
  final diff = DateTime.now().difference(createdAt.toLocal());
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays == 1) return '어제';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  final local = createdAt.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

IconData _iconForCategory(PlatformNotificationCategory category) {
  return switch (category) {
    PlatformNotificationCategory.review => Icons.notifications_outlined,
    PlatformNotificationCategory.community => Icons.groups_outlined,
    PlatformNotificationCategory.achievement => Icons.emoji_events_outlined,
    PlatformNotificationCategory.system => Icons.info_outline,
  };
}

Color _colorForCategory(PlatformNotificationCategory category) {
  return switch (category) {
    PlatformNotificationCategory.review => AppColors.success,
    PlatformNotificationCategory.community => AppColors.info,
    PlatformNotificationCategory.achievement => AppColors.primary,
    PlatformNotificationCategory.system => AppColors.muted,
  };
}

String _actionLabelForCategory(PlatformNotificationCategory category) {
  return switch (category) {
    PlatformNotificationCategory.review => '복습 시작',
    PlatformNotificationCategory.community => '확인하기',
    PlatformNotificationCategory.achievement => '성취 보기',
    PlatformNotificationCategory.system => '자세히 보기',
  };
}

// ── NotificationPreferenceScreen (SCR-W-NOTI-002) ──

class NotificationPreferenceScreen extends ConsumerWidget {
  const NotificationPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesValue = ref.watch(notificationPreferencesProvider);
    return AppAsyncValueWidget<NotificationPreferences>(
      value: preferencesValue,
      loading: const AppLoadingWidget(label: '알림 설정을 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '알림 설정을 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(notificationPreferencesProvider),
      ),
      data: (preferences) =>
          _NotificationPreferenceContent(preferences: preferences),
    );
  }
}

class _NotificationPreferenceContent extends ConsumerWidget {
  const _NotificationPreferenceContent({required this.preferences});

  final NotificationPreferences preferences;

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final initial = _parseTimeOfDay(
      isStart ? preferences.quietHoursStart : preferences.quietHoursEnd,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!context.mounted || picked == null) return;
    await ref
        .read(notificationPreferencesProvider.notifier)
        .setQuietHours(
          start: isStart
              ? _formatTimeOfDay(picked)
              : preferences.quietHoursStart,
          end: isStart ? preferences.quietHoursEnd : _formatTimeOfDay(picked),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('알림 설정', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Text('카테고리별 알림 설정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
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
                for (final channel in NotificationChannel.values)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        channel.label,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            for (final category in PlatformNotificationCategory.values)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(category.label, style: textTheme.bodyMedium),
                  ),
                  for (final channel in NotificationChannel.values)
                    Center(
                      child: Switch(
                        value: preferences
                            .channelsFor(category)
                            .isEnabled(channel),
                        onChanged: (enabled) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .updateChannel(
                              category: category,
                              channel: channel,
                              enabled: enabled,
                            ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
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
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context, ref, isStart: true),
                icon: const Icon(Icons.bedtime_outlined, size: 18),
                label: Text('시작: ${preferences.quietHoursStart}'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('~', style: textTheme.bodyMedium),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context, ref, isStart: false),
                icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                label: Text('종료: ${preferences.quietHoursEnd}'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

TimeOfDay _parseTimeOfDay(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return const TimeOfDay(hour: 22, minute: 0);
  return TimeOfDay(
    hour: int.tryParse(parts[0])?.clamp(0, 23) ?? 22,
    minute: int.tryParse(parts[1])?.clamp(0, 59) ?? 0,
  );
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
