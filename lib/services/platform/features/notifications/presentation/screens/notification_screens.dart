import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_settings_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/providers/unread_notification_count_provider.dart';

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
  bool _loading = true;
  bool _markingAll = false;
  String? _error;
  List<NotificationItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(notificationInboxApiProvider)
          .list(size: 50);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _loading = false;
      });
      unawaited(ref.read(unreadNotificationCountProvider.notifier).refresh());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '알림을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll || _items.every((n) => n.read)) return;
    setState(() => _markingAll = true);
    try {
      await ref.read(notificationInboxApiProvider).markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items.map((n) => n.copyWith(read: true)).toList();
        _markingAll = false;
      });
      unawaited(ref.read(unreadNotificationCountProvider.notifier).refresh());
    } catch (_) {
      if (!mounted) return;
      setState(() => _markingAll = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모두 읽음 처리에 실패했습니다.')),
      );
    }
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read) return;
    // 낙관적 갱신: 먼저 읽음 표시 후, 실패하면 되돌린다.
    setState(() {
      _items = _items
          .map((n) => n.id == item.id ? n.copyWith(read: true) : n)
          .toList();
    });
    try {
      await ref.read(notificationInboxApiProvider).markRead(item.id);
      unawaited(ref.read(unreadNotificationCountProvider.notifier).refresh());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((n) => n.id == item.id ? n.copyWith(read: false) : n)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                onPressed: _markingAll ? null : _markAllRead,
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
        // TabBarView — notificationType을 키워드 분류기로 탭에 매핑.
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBody(textTheme, null),
              _buildBody(textTheme, NotificationCategory.review),
              _buildBody(textTheme, NotificationCategory.community),
              _buildBody(textTheme, NotificationCategory.achievement),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(TextTheme textTheme, NotificationCategory? filter) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    final items = filter == null
        ? _items
        : _items
              .where((n) => notificationCategoryOf(n.type) == filter)
              .toList();
    if (items.isEmpty) {
      return Center(
        child: Text(
          '알림이 없습니다.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
      );
    }

    final sections = _groupBySection(items);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final section in sections) ...[
            Text(
              section.label,
              style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...section.items.map(
              (n) => _NotificationItemView(item: n, onTap: () => _markRead(n)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  List<_Section> _groupBySection(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final buckets = <String, List<NotificationItem>>{
      '오늘': [],
      '어제': [],
      '이번 주': [],
      '이전': [],
    };
    for (final n in items) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (!d.isBefore(today)) {
        buckets['오늘']!.add(n);
      } else if (!d.isBefore(yesterday)) {
        buckets['어제']!.add(n);
      } else if (!d.isBefore(weekAgo)) {
        buckets['이번 주']!.add(n);
      } else {
        buckets['이전']!.add(n);
      }
    }
    return buckets.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => _Section(e.key, e.value))
        .toList();
  }
}

class _Section {
  const _Section(this.label, this.items);
  final String label;
  final List<NotificationItem> items;
}

String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays == 1) return '어제';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${time.month}월 ${time.day}일';
}

({IconData icon, Color color}) _typeVisual(String type) {
  return switch (notificationCategoryOf(type)) {
    NotificationCategory.review => (
      icon: Icons.style_outlined,
      color: AppColors.success,
    ),
    NotificationCategory.community => (
      icon: Icons.groups_outlined,
      color: AppColors.info,
    ),
    NotificationCategory.achievement => (
      icon: Icons.emoji_events,
      color: AppColors.primary,
    ),
    NotificationCategory.other => (
      icon: Icons.notifications_none,
      color: AppColors.muted,
    ),
  };
}

class _NotificationItemView extends StatelessWidget {
  const _NotificationItemView({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = _typeVisual(item.type);
    final title = (item.title?.isNotEmpty ?? false) ? item.title! : '알림';

    return InkWell(
      onTap: item.read ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: item.read
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: item.read
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
                color: visual.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, size: 18, color: visual.color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!item.read) ...[
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
                          title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: item.read ? null : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.body?.isNotEmpty ?? false) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.body!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _relativeTime(item.createdAt),
                    style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
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
  List<List<bool>> _notifGrid = [
    [true, false, true], // 복습 리마인더
    [true, true, true], // 커뮤니티 활동
    [true, false, true], // 성취/배지
    [false, true, true], // 시스템 알림
  ];

  static const _categoryLabels = ['복습 리마인더', '커뮤니티 활동', '성취/배지', '시스템 알림'];

  static const _channelLabels = ['Push', 'Email', 'InApp'];

  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = await ref.read(notificationSettingsApiProvider).get();
      if (!mounted) return;
      setState(() {
        _notifGrid = settings.grid.map((row) => row.toList()).toList();
        _quietStart = _parseTime(settings.quietStart);
        _quietEnd = _parseTime(settings.quietEnd);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '알림 설정을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(notificationSettingsApiProvider).update(
        NotificationSettings(
          grid: _notifGrid,
          quietStart: _formatTime(_quietStart),
          quietEnd: _formatTime(_quietEnd),
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정이 저장되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정 저장에 실패했습니다.')),
      );
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 22;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final boundedHour = hour >= 0 && hour <= 23 ? hour : 22;
    final boundedMinute = minute >= 0 && minute <= 59 ? minute : 0;
    return TimeOfDay(hour: boundedHour, minute: boundedMinute);
  }

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

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

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
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
      ],
    );
  }
}
