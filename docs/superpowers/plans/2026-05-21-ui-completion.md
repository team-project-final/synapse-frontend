# Synapse Frontend UI Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete all 52 screens defined in 06/06A screen definition docs to UI-only level (mock data, no business logic), plus 13 shared components.

**Architecture:** Flutter 3.x with Riverpod (manual providers), GoRouter, Material Design 3. All screens use mock data with `// TODO: 팀원 구현 —` markers for API integration points. Screens follow existing patterns: `ConsumerWidget` for simple screens, `ConsumerStatefulWidget` for screens with local state. Admin screens use a separate `AdminShell` layout.

**Tech Stack:** Flutter 3.x, Riverpod (manual), GoRouter, CustomPaint (graph/heatmap), Material 3 widgets. No external chart library — use CustomPaint for charts and graphs to avoid dependency bloat.

---

## Source Materials

| Doc | Role | Path |
|---|---|---|
| Spec | Design decisions and scope | `docs/superpowers/specs/2026-05-21-ui-completion-design.md` |
| Theme | Color tokens, spacing | `lib/core/theme/app_colors.dart`, `app_spacing.dart`, `app_theme.dart` |
| Router | All route definitions | `lib/core/router/app_router.dart` |
| Routes | Route constants | `lib/core/constants/app_routes.dart` |
| AppShell | Main layout pattern | `lib/shared/widgets/app_shell.dart` |
| SideNav | Navigation pattern | `lib/shared/widgets/side_nav.dart` |
| Existing screens | Code patterns to follow | `lib/services/*/features/*/presentation/screens/*_screens.dart` |

## Conventions (apply to ALL tasks)

1. **Imports**: Always `package:synapse_frontend/...` absolute imports. Always import `app_colors.dart`, `app_spacing.dart`.
2. **Widget type**: Use `ConsumerWidget` unless the screen needs `TextEditingController`, `TabController`, or local `setState` — then use `ConsumerStatefulWidget`.
3. **Mock data**: Declare as private `_MockXxx` classes with `const` constructor. Use `const _mockXxx = [...]` for lists.
4. **TODO markers**: `// TODO: 팀원 구현 — {service}-svc {endpoint description}` on every mock data block.
5. **Responsive**: Check `MediaQuery.sizeOf(context).width < 600` for mobile. Use `isMobile` variable.
6. **Theme access**: `Theme.of(context).textTheme` for text styles, `Theme.of(context).colorScheme` for dynamic colors, `AppColors.*` for fixed design tokens.
7. **Spacing**: Use `AppSpacing.*` constants (xxs=2, xs=4, sm=8, md=16, lg=24, xl=32, xxl=48).
8. **Navigation**: `context.go(AppRoutes.xxx)` for navigation. Use helper methods like `AppRoutes.noteDetailPath(id)` for parameterized routes.
9. **Verify**: After each task, run `flutter analyze` and fix any warnings before committing.
10. **Commit message**: `feat(ui): {한국어 설명}` format.

---

## Pre-flight

- [ ] **Step P1: Ensure clean working state**

```bash
git status --short
```
Expected: clean or only the spec file.

- [ ] **Step P2: Create feature branch**

```bash
git checkout dev
git pull origin dev
git checkout -b feat/ui-completion
```

---

## Task 1: Toast + ConfirmDialog + ReportDialog (공통 다이얼로그 3종)

**Files:**
- Create: `lib/shared/widgets/toast.dart`
- Create: `lib/shared/widgets/confirm_dialog.dart`
- Create: `lib/shared/widgets/report_dialog.dart`

- [ ] **Step 1.1: Create Toast widget**

```dart
// lib/shared/widgets/toast.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

enum ToastType { success, error, info }

abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (icon, color) = switch (type) {
      ToastType.success => (Icons.check_circle, AppColors.success),
      ToastType.error => (Icons.error, AppColors.error),
      ToastType.info => (Icons.info, AppColors.info),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: duration,
        ),
      );
  }
}
```

- [ ] **Step 1.2: Create ConfirmDialog widget**

```dart
// lib/shared/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.content,
    this.confirmLabel = '확인',
    this.cancelLabel = '취소',
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = '확인',
    String cancelLabel = '취소',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
```

- [ ] **Step 1.3: Create ReportDialog widget**

```dart
// lib/shared/widgets/report_dialog.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({this.targetTitle, super.key});

  final String? targetTitle;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? targetTitle,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ReportDialog(targetTitle: targetTitle),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _detailController = TextEditingController();

  static const _reasons = [
    '스팸 또는 광고',
    '부적절한 콘텐츠',
    '저작권 침해',
    '혐오 발언',
    '개인정보 노출',
    '기타',
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('신고하기'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.targetTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text('대상: ${widget.targetTitle}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ..._reasons.map(
              (reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (v) => setState(() => _selectedReason = v),
                dense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: '상세 설명 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () => Navigator.of(context).pop({
                    'reason': _selectedReason!,
                    'detail': _detailController.text,
                  }),
          child: const Text('제출'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 1.4: Verify**

```bash
flutter analyze lib/shared/widgets/toast.dart lib/shared/widgets/confirm_dialog.dart lib/shared/widgets/report_dialog.dart
```
Expected: No issues found.

- [ ] **Step 1.5: Commit**

```bash
git add lib/shared/widgets/toast.dart lib/shared/widgets/confirm_dialog.dart lib/shared/widgets/report_dialog.dart
git commit -m "feat(ui): 공통 다이얼로그 3종 추가 (Toast, ConfirmDialog, ReportDialog)"
```

---

## Task 2: CommandPalette (Cmd+K 커맨드 팔레트)

**Files:**
- Create: `lib/shared/widgets/command_palette.dart`
- Modify: `lib/shared/widgets/app_shell.dart` (Cmd+K 단축키 바인딩)

- [ ] **Step 2.1: Create CommandPalette widget**

```dart
// lib/shared/widgets/command_palette.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class CommandPaletteItem {
  const CommandPaletteItem({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? subtitle;
}

class CommandPalette extends StatefulWidget {
  const CommandPalette({
    required this.items,
    required this.onSelect,
    super.key,
  });

  final List<CommandPaletteItem> items;
  final ValueChanged<CommandPaletteItem> onSelect;

  static Future<void> show(
    BuildContext context, {
    required List<CommandPaletteItem> items,
    required ValueChanged<CommandPaletteItem> onSelect,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CommandPalette(items: items, onSelect: onSelect),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  List<CommandPaletteItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _selectedIndex = 0;
      _filtered = query.isEmpty
          ? widget.items
          : widget.items
              .where((item) =>
                  item.label.toLowerCase().contains(query.toLowerCase()) ||
                  (item.subtitle?.toLowerCase().contains(query.toLowerCase()) ??
                      false))
              .toList();
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() =>
          _selectedIndex = (_selectedIndex + 1).clamp(0, _filtered.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() =>
          _selectedIndex = (_selectedIndex - 1).clamp(0, _filtered.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        _filtered.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onSelect(_filtered[_selectedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKey,
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding:
            const EdgeInsets.only(top: 80, left: AppSpacing.lg, right: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '명령어 검색... (↑↓ 이동, Enter 선택)',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: _filter,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    final isSelected = index == _selectedIndex;
                    return ListTile(
                      leading: Icon(item.icon, size: 20),
                      title: Text(item.label),
                      subtitle: item.subtitle != null
                          ? Text(item.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.stone400))
                          : null,
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelect(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2.2: Add Cmd+K binding to AppShell**

In `lib/shared/widgets/app_shell.dart`, add import at top:

```dart
import 'package:synapse_frontend/shared/widgets/command_palette.dart';
```

Add a `CallbackShortcuts` wrapper around the `Scaffold` in the `build` method. Find the `return Scaffold(` line and wrap:

```dart
    // ── Command palette items ──
    const paletteItems = [
      CommandPaletteItem(
          icon: Icons.dashboard_outlined, label: '대시보드', route: '/'),
      CommandPaletteItem(
          icon: Icons.description_outlined, label: '노트', route: '/notes'),
      CommandPaletteItem(
          icon: Icons.add, label: '새 노트', route: '/notes/new/edit'),
      CommandPaletteItem(
          icon: Icons.style_outlined, label: '덱', route: '/decks'),
      CommandPaletteItem(
          icon: Icons.refresh, label: '복습 시작', route: '/review'),
      CommandPaletteItem(
          icon: Icons.hub_outlined, label: '그래프', route: '/graph'),
      CommandPaletteItem(
          icon: Icons.search, label: '검색', route: '/search'),
      CommandPaletteItem(
          icon: Icons.smart_toy_outlined, label: 'AI Q&A', route: '/qa'),
      CommandPaletteItem(
          icon: Icons.groups_outlined,
          label: '커뮤니티',
          route: '/community/groups'),
      CommandPaletteItem(
          icon: Icons.settings_outlined,
          label: '설정',
          route: '/settings/profile'),
    ];

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          CommandPalette.show(
            context,
            items: paletteItems,
            onSelect: (item) => context.go(item.route),
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          CommandPalette.show(
            context,
            items: paletteItems,
            onSelect: (item) => context.go(item.route),
          );
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          // ... existing Scaffold content unchanged ...
        ),
      ),
    );
```

Also add `import 'package:flutter/services.dart';` at top.

- [ ] **Step 2.3: Verify and commit**

```bash
flutter analyze lib/shared/widgets/command_palette.dart lib/shared/widgets/app_shell.dart
git add lib/shared/widgets/command_palette.dart lib/shared/widgets/app_shell.dart
git commit -m "feat(ui): CommandPalette 추가 (Cmd+K / Ctrl+K 커맨드 팔레트)"
```

---

## Task 3: OnboardingChecklist + CelebrationParticle + LevelUpCelebration

**Files:**
- Create: `lib/shared/widgets/onboarding_checklist.dart`
- Create: `lib/shared/widgets/celebration_particle.dart`
- Create: `lib/shared/widgets/level_up_celebration.dart`

- [ ] **Step 3.1: Create CelebrationParticle widget**

```dart
// lib/shared/widgets/celebration_particle.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CelebrationParticle extends StatefulWidget {
  const CelebrationParticle({
    this.particleCount = 30,
    this.colors,
    this.duration = const Duration(milliseconds: 600),
    this.onComplete,
    super.key,
  });

  final int particleCount;
  final List<Color>? colors;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<CelebrationParticle> createState() => _CelebrationParticleState();
}

class _CelebrationParticleState extends State<CelebrationParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    final colors = widget.colors ??
        [
          Colors.amber,
          Colors.orange,
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.purple,
        ];
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        speed: 100 + _random.nextDouble() * 200,
        size: 4 + _random.nextDouble() * 6,
        color: colors[_random.nextInt(colors.length)],
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final distance = p.speed * progress;
      final dx = center.dx + math.cos(p.angle) * distance;
      final dy = center.dy + math.sin(p.angle) * distance - (50 * progress);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
```

- [ ] **Step 3.2: Create LevelUpCelebration widget**

```dart
// lib/shared/widgets/level_up_celebration.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/celebration_particle.dart';

class LevelUpCelebration extends StatelessWidget {
  const LevelUpCelebration({
    required this.previousLevel,
    required this.newLevel,
    required this.rewards,
    required this.onDismiss,
    super.key,
  });

  final int previousLevel;
  final int newLevel;
  final List<String> rewards;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required int previousLevel,
    required int newLevel,
    List<String> rewards = const [],
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LevelUpCelebration(
        previousLevel: previousLevel,
        newLevel: newLevel,
        rewards: rewards,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        const Positioned.fill(
          child: CelebrationParticle(
            particleCount: 50,
            colors: [AppColors.primaryAmber, AppColors.warning, Colors.orange],
            duration: Duration(milliseconds: 1200),
          ),
        ),
        Center(
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration,
                      size: 48, color: AppColors.primaryAmber),
                  const SizedBox(height: AppSpacing.md),
                  Text('레벨 업!', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lv.$previousLevel',
                          style: textTheme.titleLarge
                              ?.copyWith(color: AppColors.stone400)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Icon(Icons.arrow_forward,
                            color: AppColors.primaryAmber),
                      ),
                      Text('Lv.$newLevel',
                          style: textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryAmber,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (rewards.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text('보상', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    ...rewards.map((r) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: AppColors.primaryAmber),
                              const SizedBox(width: AppSpacing.xs),
                              Text(r),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: onDismiss,
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3.3: Create OnboardingChecklist widget**

```dart
// lib/shared/widgets/onboarding_checklist.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class OnboardingChecklist extends StatefulWidget {
  const OnboardingChecklist({super.key});

  @override
  State<OnboardingChecklist> createState() => _OnboardingChecklistState();
}

class _OnboardingChecklistState extends State<OnboardingChecklist> {
  bool _isExpanded = true;

  // TODO: 팀원 구현 — 실제 완료 상태는 Provider로 관리
  final _steps = [
    _OnboardingStep(
      icon: Icons.description_outlined,
      label: '첫 번째 노트 작성',
      subtitle: '마크다운으로 노트를 작성해보세요',
      isCompleted: false,
    ),
    _OnboardingStep(
      icon: Icons.style_outlined,
      label: '첫 번째 카드 생성',
      subtitle: 'AI로 플래시카드를 만들어보세요',
      isCompleted: false,
    ),
    _OnboardingStep(
      icon: Icons.refresh,
      label: '첫 번째 복습 완료',
      subtitle: '카드를 복습하고 기억을 강화하세요',
      isCompleted: false,
    ),
  ];

  int get _completedCount => _steps.where((s) => s.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch,
                      color: AppColors.primaryAmber),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('시작하기', style: textTheme.titleSmall),
                        Text('$_completedCount / ${_steps.length} 완료',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.stone500)),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: _completedCount / _steps.length,
                    backgroundColor: AppColors.stone200,
                    color: AppColors.primaryAmber,
                  ).run((w) => SizedBox(width: 60, child: w)),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(_isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...List.generate(_steps.length, (i) {
              final step = _steps[i];
              return ListTile(
                leading: step.isCompleted
                    ? const Icon(Icons.check_circle,
                        color: AppColors.success)
                    : Icon(step.icon, color: AppColors.stone400),
                title: Text(
                  step.label,
                  style: textTheme.bodyMedium?.copyWith(
                    decoration:
                        step.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(step.subtitle,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone500)),
                dense: true,
              );
            }),
          ],
        ],
      ),
    );
  }
}

// Extension to allow inline widget wrapping
extension _WidgetRun on Widget {
  Widget run(Widget Function(Widget) fn) => fn(this);
}

class _OnboardingStep {
  _OnboardingStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isCompleted,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isCompleted;
}
```

- [ ] **Step 3.4: Verify and commit**

```bash
flutter analyze lib/shared/widgets/celebration_particle.dart lib/shared/widgets/level_up_celebration.dart lib/shared/widgets/onboarding_checklist.dart
git add lib/shared/widgets/celebration_particle.dart lib/shared/widgets/level_up_celebration.dart lib/shared/widgets/onboarding_checklist.dart
git commit -m "feat(ui): OnboardingChecklist, CelebrationParticle, LevelUpCelebration 추가"
```

---

## Task 4: AIGenerateLoading + CodeBlock (AI/코드 컴포넌트)

**Files:**
- Create: `lib/shared/widgets/ai_generate_loading.dart`
- Create: `lib/shared/widgets/code_block.dart`

- [ ] **Step 4.1: Create AIGenerateLoading widget**

```dart
// lib/shared/widgets/ai_generate_loading.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AIGenerateLoading extends StatefulWidget {
  const AIGenerateLoading({
    this.message = 'AI가 카드를 생성하고 있습니다...',
    this.progress,
    this.cardCount = 3,
    super.key,
  });

  final String message;
  final double? progress;
  final int cardCount;

  @override
  State<AIGenerateLoading> createState() => _AIGenerateLoadingState();
}

class _AIGenerateLoadingState extends State<AIGenerateLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.smart_toy_outlined,
            size: 40, color: AppColors.primaryAmber),
        const SizedBox(height: AppSpacing.md),
        Text(widget.message, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        if (widget.progress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: AppColors.stone200,
              color: AppColors.primaryAmber,
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.stone200,
              color: AppColors.primaryAmber,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(widget.cardCount, (index) {
          return AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) {
              final shimmerValue = (_shimmerController.value + index * 0.2) % 1.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.stone100,
                        AppColors.stone200,
                        AppColors.stone100,
                      ],
                      stops: [
                        (shimmerValue - 0.3).clamp(0.0, 1.0),
                        shimmerValue,
                        (shimmerValue + 0.3).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
```

- [ ] **Step 4.2: Create CodeBlock widget**

```dart
// lib/shared/widgets/code_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock({
    required this.code,
    this.language,
    super.key,
  });

  final String code;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.stone800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.stone700,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (language != null)
                  Text(language!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  color: AppColors.stone400,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      AppToast.show(context,
                          message: '복사됨', type: ToastType.success);
                    }
                  },
                  tooltip: '복사',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'GeistMono',
                fontSize: 13,
                color: AppColors.stone100,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4.3: Verify and commit**

```bash
flutter analyze lib/shared/widgets/ai_generate_loading.dart lib/shared/widgets/code_block.dart
git add lib/shared/widgets/ai_generate_loading.dart lib/shared/widgets/code_block.dart
git commit -m "feat(ui): AIGenerateLoading, CodeBlock 공통 컴포넌트 추가"
```

---

## Task 5: Auth 플레이스홀더 3개 교체 (MFA, 비밀번호 재설정, OAuth 동의)

**Files:**
- Modify: `lib/services/platform/features/auth/presentation/screens/auth_screens.dart`

- [ ] **Step 5.1: Read current auth_screens.dart to find placeholder classes**

Read the file and locate `MfaScreen`, `PasswordResetScreen`, `OAuthConsentScreen` — they currently return `DomainPlaceholderScaffold`.

- [ ] **Step 5.2: Replace MfaScreen placeholder**

Replace the existing `MfaScreen` class with:

```dart
// ── MfaScreen (SCR-W-AUTH-003) ──

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _remainingSeconds = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _remainingSeconds--);
      return _remainingSeconds > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('2단계 인증')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 48, color: AppColors.primaryAmber),
                const SizedBox(height: AppSpacing.lg),
                Text('인증 코드 입력', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text('인증 앱에 표시된 6자리 코드를 입력하세요.',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.stone500),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                // 6-digit code input
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                      child: SizedBox(
                        width: 44,
                        child: TextField(
                          controller: _codeControllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: textTheme.headlineSmall,
                          onChanged: (value) {
                            if (value.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            }
                            // TODO: 팀원 구현 — platform-svc MFA 검증 API 연동
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                // Timer
                Text(
                  _remainingSeconds > 0
                      ? '$_remainingSeconds초 남음'
                      : '코드가 만료되었습니다',
                  style: textTheme.bodySmall?.copyWith(
                    color: _remainingSeconds > 0
                        ? AppColors.stone500
                        : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _code.length == 6 && !_isLoading ? () {} : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('확인'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _remainingSeconds <= 0
                      ? () => setState(() {
                            _remainingSeconds = 30;
                            _startTimer();
                          })
                      : null,
                  child: const Text('코드 재발송'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — 백업코드 입력 화면
                  },
                  child: Text('백업 코드 사용',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5.3: Replace PasswordResetScreen placeholder**

```dart
// ── PasswordResetScreen (SCR-W-AUTH-004) ──

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  }
                  // TODO: 팀원 구현 — platform-svc 비밀번호 재설정 API 연동
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.of(context).pop();
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: details.onStepContinue,
                        child: Text(_currentStep == 2 ? '변경하기' : '다음'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text(_currentStep == 0 ? '취소' : '이전'),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('이메일 입력'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v != null && v.contains('@') ? null : '유효한 이메일을 입력하세요',
                  ),
                ),
                Step(
                  title: const Text('인증 코드'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_emailController.text}으로 전송된 코드를 입력하세요.',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: '인증 코드',
                          hintText: '6자리 코드',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v != null && v.length == 6 ? null : '6자리 코드를 입력하세요',
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('새 비밀번호'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: '새 비밀번호',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v != null && v.length >= 8
                            ? null
                            : '8자 이상 입력하세요',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmController,
                        decoration: const InputDecoration(
                          labelText: '비밀번호 확인',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v == _passwordController.text
                            ? null
                            : '비밀번호가 일치하지 않습니다',
                      ),
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
```

- [ ] **Step 5.4: Replace OAuthConsentScreen placeholder**

```dart
// ── OAuthConsentScreen (SCR-W-AUTH-005) ──

class OAuthConsentScreen extends ConsumerStatefulWidget {
  const OAuthConsentScreen({super.key});

  @override
  ConsumerState<OAuthConsentScreen> createState() =>
      _OAuthConsentScreenState();
}

class _OAuthConsentScreenState extends ConsumerState<OAuthConsentScreen> {
  final _permissions = {
    '기본 프로필 정보 (이름, 이메일)': true,
    '학습 데이터 읽기': true,
    '노트 및 카드 접근': false,
    '그룹 활동 접근': false,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('권한 동의')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.stone200,
                          child: Icon(Icons.apps,
                              size: 32, color: AppColors.stone600),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Third-Party App',
                            style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '이 앱이 Synapse 계정에 접근하려고 합니다.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.stone500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Permissions
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                        child: Text('요청 권한', style: textTheme.titleSmall),
                      ),
                      ..._permissions.entries.map((entry) {
                        return CheckboxListTile(
                          value: entry.value,
                          onChanged: (v) =>
                              setState(() => _permissions[entry.key] = v!),
                          title: Text(entry.key, style: textTheme.bodyMedium),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('거부'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // TODO: 팀원 구현 — platform-svc OAuth consent API
                        },
                        child: const Text('허용'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5.5: Remove DomainPlaceholderScaffold import if no longer used**

Check if `DomainPlaceholderScaffold` import is still needed in `auth_screens.dart`. If these were the only three uses, remove the import line.

- [ ] **Step 5.6: Verify and commit**

```bash
flutter analyze lib/services/platform/features/auth/presentation/screens/auth_screens.dart
git add lib/services/platform/features/auth/presentation/screens/auth_screens.dart
git commit -m "feat(ui): Auth 플레이스홀더 3개 교체 (MFA, 비밀번호 재설정, OAuth 동의)"
```

---

## Task 6: Dashboard 신규 화면 (히트맵 + 통계 상세) + 보강

**Files:**
- Modify: `lib/shared/features/dashboard/presentation/screens/dashboard_screen.dart`
- Modify: `lib/core/constants/app_routes.dart` (add dashboard sub-routes)
- Modify: `lib/core/router/app_router.dart` (add routes)

- [ ] **Step 6.1: Add route constants**

In `app_routes.dart`, add after `static const dashboard = '/';`:

```dart
  static const dashboardHeatmap = '/dashboard/heatmap';
  static const dashboardStats = '/dashboard/stats';
```

- [ ] **Step 6.2: Rewrite dashboard_screen.dart with full UI**

Replace the entire `dashboard_screen.dart` content. The file should contain `DashboardScreen` (DASH-001 with heatmap widget, onboarding, streak), `DashboardHeatmapScreen` (DASH-002), and `DashboardStatsScreen` (DASH-003).

Key implementation details for `DashboardScreen`:
- "오늘의 복습" section with card count + "복습 시작" button → `context.go(AppRoutes.review)`
- Insert `OnboardingChecklist` widget (imported from Phase 1)
- Weekly/monthly `SegmentedButton<String>` toggle for stats
- `_HeatmapMini` widget using `CustomPaint` (compact 12-week view)
- StreakFlame with `ScaleTransition` pulse animation
- "최근 노트" section with `_mockRecentNotes` list
- Mock stats cards (복습 카드 수, 정확도, 연속 학습)

Key implementation details for `DashboardHeatmapScreen` (DASH-002):
- Full `CustomPaint` grid: 52 columns × 7 rows
- 5-level color scale: stone100 → success(dark) based on study count
- `GestureDetector` + `_hitTest` for cell tap → show Tooltip with date + count
- Bottom legend row showing color levels
- Mock data: `_mockHeatmapData` as `Map<String, int>` (date → count)

Key implementation details for `DashboardStatsScreen` (DASH-003):
- `SegmentedButton` period filter (주간/월간/전체)
- Retention curve: `CustomPaint` line chart with points
- Accuracy: `CustomPaint` bar chart (7 bars for days of week)
- Study time: `CustomPaint` line chart
- All charts use `AppColors.primaryAmber` as primary color
- Mock data arrays for each chart

- [ ] **Step 6.3: Add routes in app_router.dart**

Add inside the ShellRoute routes list, after the dashboard route:

```dart
          GoRoute(
            path: AppRoutes.dashboardHeatmap,
            builder: (context, state) => const DashboardHeatmapScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboardStats,
            builder: (context, state) => const DashboardStatsScreen(),
          ),
```

Add import if `dashboard_screen.dart` exports the new classes (it should, since they're in the same file).

- [ ] **Step 6.4: Verify and commit**

```bash
flutter analyze
git add lib/shared/features/dashboard/presentation/screens/dashboard_screen.dart lib/core/constants/app_routes.dart lib/core/router/app_router.dart
git commit -m "feat(ui): Dashboard 히트맵(DASH-002), 통계 상세(DASH-003) 추가 + 대시보드 보강"
```

---

## Task 7: Graph 전체 교체 (3개 화면)

**Files:**
- Modify: `lib/services/knowledge/features/graph/presentation/screens/graph_screens.dart`

- [ ] **Step 7.1: Read current graph_screens.dart**

Read the file to find the three placeholder classes: `GraphViewScreen`, `GraphNoteScreen`, `GraphClustersScreen`.

- [ ] **Step 7.2: Create shared graph rendering infrastructure**

At the top of the file, add mock data and the `_GraphPainter` CustomPainter that all three screens share:

```dart
// ── Mock graph data ──

class _MockGraphNode {
  const _MockGraphNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.cluster = 0,
    this.linkCount = 0,
    this.pageRank = 0.0,
  });
  final String id;
  final String label;
  final double x;
  final double y;
  final int cluster;
  final int linkCount;
  final double pageRank;
}

class _MockGraphEdge {
  const _MockGraphEdge({required this.from, required this.to});
  final String from;
  final String to;
}

// TODO: 팀원 구현 — knowledge-svc GET /graph/data API 연동
const _mockNodes = [
  _MockGraphNode(id: '1', label: '정규화 기법', x: 200, y: 200, cluster: 0, linkCount: 5, pageRank: 0.82),
  _MockGraphNode(id: '2', label: '드롭아웃', x: 350, y: 150, cluster: 0, linkCount: 3, pageRank: 0.65),
  _MockGraphNode(id: '3', label: '배치 정규화', x: 340, y: 300, cluster: 0, linkCount: 4, pageRank: 0.71),
  _MockGraphNode(id: '4', label: 'CNN 아키텍처', x: 500, y: 200, cluster: 1, linkCount: 6, pageRank: 0.88),
  _MockGraphNode(id: '5', label: 'RNN 기초', x: 500, y: 350, cluster: 1, linkCount: 3, pageRank: 0.55),
  _MockGraphNode(id: '6', label: '트랜스포머', x: 650, y: 250, cluster: 1, linkCount: 7, pageRank: 0.92),
  _MockGraphNode(id: '7', label: '역전파', x: 100, y: 350, cluster: 2, linkCount: 4, pageRank: 0.68),
  _MockGraphNode(id: '8', label: '경사 하강법', x: 150, y: 450, cluster: 2, linkCount: 3, pageRank: 0.60),
];

const _mockEdges = [
  _MockGraphEdge(from: '1', to: '2'),
  _MockGraphEdge(from: '1', to: '3'),
  _MockGraphEdge(from: '2', to: '4'),
  _MockGraphEdge(from: '3', to: '4'),
  _MockGraphEdge(from: '4', to: '5'),
  _MockGraphEdge(from: '4', to: '6'),
  _MockGraphEdge(from: '5', to: '6'),
  _MockGraphEdge(from: '7', to: '1'),
  _MockGraphEdge(from: '7', to: '8'),
];

const _clusterColors = [
  AppColors.primaryAmber,
  AppColors.info,
  AppColors.success,
  Colors.purple,
];
```

- [ ] **Step 7.3: Implement GraphViewScreen (SCR-W-GRAPH-001)**

A `ConsumerStatefulWidget` with:
- `InteractiveViewer` wrapping `CustomPaint` canvas
- `_GraphPainter` that draws edges (lines) and nodes (circles with labels)
- `GestureDetector` on the `CustomPaint` to detect node taps (hit test by distance to node center)
- `_selectedNode` state → shows `DraggableScrollableSheet` bottom panel with node info (label, linkCount, pageRank, action buttons)
- Filter panel as `ExpansionTile` with tag FilterChips, min links Slider
- "Fit" FloatingActionButton to reset transform

- [ ] **Step 7.4: Implement GraphNoteScreen (SCR-W-GRAPH-002)**

A simpler version focused on one note:
- Receives `noteId` parameter
- Shows the center node (highlighted, larger) + its 2-hop neighbors
- `Slider` widget for depth control (1-hop / 2-hop)
- Same `InteractiveViewer` + `CustomPaint` approach
- Back button to return to full graph

- [ ] **Step 7.5: Implement GraphClustersScreen (SCR-W-GRAPH-003)**

- Left panel (280px on desktop): cluster list with color indicators, node count per cluster, tap to select
- Main area: same graph but with selected cluster nodes highlighted, others dimmed (opacity 0.2)
- `_selectedCluster` state variable

- [ ] **Step 7.6: Verify and commit**

```bash
flutter analyze lib/services/knowledge/features/graph/presentation/screens/graph_screens.dart
git add lib/services/knowledge/features/graph/presentation/screens/graph_screens.dart
git commit -m "feat(ui): Graph 3개 화면 구현 (전체 뷰, 노트 이웃, 클러스터)"
```

---

## Task 8: Community 신고 모달 + Gamification 레벨업 모달

**Files:**
- Modify: `lib/services/engagement/features/community/presentation/screens/community_screens.dart`
- Modify: `lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart`

- [ ] **Step 8.1: Add report button to community screens**

In `community_screens.dart`, find `SharedDeckDetailScreen`. Add a "신고" TextButton that calls `ReportDialog.show(context, targetTitle: deckName)`. Add the import:

```dart
import 'package:synapse_frontend/shared/widgets/report_dialog.dart';
```

- [ ] **Step 8.2: Add LevelUpCelebration trigger to gamification**

In `gamification_screens.dart`, find `GamificationProfileScreen`. Add a "레벨업 테스트" button (for mock/demo purposes) that calls `LevelUpCelebration.show(context, previousLevel: 4, newLevel: 5, rewards: ['배지: 연속 학습 7일'])`. Add import:

```dart
import 'package:synapse_frontend/shared/widgets/level_up_celebration.dart';
```

- [ ] **Step 8.3: Verify and commit**

```bash
flutter analyze lib/services/engagement/features/community/presentation/screens/community_screens.dart lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart
git add lib/services/engagement/features/community/presentation/screens/community_screens.dart lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart
git commit -m "feat(ui): 신고 모달(COMM-007) + 레벨업 축하(GAME-004) 연동"
```

---

## Task 9: AdminShell + AdminDataGrid (Admin 공통 레이아웃)

**Files:**
- Create: `lib/shared/widgets/admin_shell.dart`
- Create: `lib/shared/widgets/admin_data_grid.dart`
- Modify: `lib/core/constants/app_routes.dart` (add admin sub-routes)

- [ ] **Step 9.1: Add admin route constants**

In `app_routes.dart`, add after `static const admin = '/admin';`:

```dart
  static const adminTenants = '/admin/tenants';
  static const adminUsers = '/admin/users';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminSettings = '/admin/settings';
  static const adminReports = '/admin/reports';
  static const adminContent = '/admin/content';
  static const adminGroups = '/admin/groups';
  static const adminGamification = '/admin/gamification';
  static const adminDataRequests = '/admin/data-requests';
```

- [ ] **Step 9.2: Create AdminShell**

```dart
// lib/shared/widgets/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, super.key});

  final Widget child;

  static const _menuItems = [
    _AdminMenuItem(icon: Icons.dashboard, label: '대시보드', route: AppRoutes.admin),
    _AdminMenuItem(icon: Icons.business, label: '테넌트', route: AppRoutes.adminTenants),
    _AdminMenuItem(icon: Icons.people, label: '사용자', route: AppRoutes.adminUsers),
    _AdminMenuItem(icon: Icons.receipt_long, label: '감사 로그', route: AppRoutes.adminAuditLogs),
    _AdminMenuItem(icon: Icons.flag, label: '신고', route: AppRoutes.adminReports),
    _AdminMenuItem(icon: Icons.article, label: '콘텐츠', route: AppRoutes.adminContent),
    _AdminMenuItem(icon: Icons.groups, label: '그룹', route: AppRoutes.adminGroups),
    _AdminMenuItem(icon: Icons.emoji_events, label: '게이미피케이션', route: AppRoutes.adminGamification),
    _AdminMenuItem(icon: Icons.storage, label: '데이터 요청', route: AppRoutes.adminDataRequests),
    _AdminMenuItem(icon: Icons.settings, label: '시스템 설정', route: AppRoutes.adminSettings),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 20),
            const SizedBox(width: AppSpacing.sm),
            const Text('Synapse Admin'),
            const Spacer(),
            // Environment selector
            DropdownButton<String>(
              value: 'prod',
              underline: const SizedBox.shrink(),
              items: ['dev', 'staging', 'prod']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
              // TODO: 팀원 구현 — 환경 전환 로직
            ),
            const SizedBox(width: AppSpacing.md),
            PopupMenuButton<String>(
              icon: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'profile', child: Text('프로필')),
                const PopupMenuItem(value: 'logout', child: Text('로그아웃')),
              ],
              onSelected: (v) {
                if (v == 'profile') context.go(AppRoutes.settingsProfile);
                // TODO: 팀원 구현 — 로그아웃 처리
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Side nav
          Container(
            width: 240,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.stone200)),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _menuItems.map((item) {
                final isActive = currentRoute == item.route ||
                    (item.route != AppRoutes.admin &&
                        currentRoute.startsWith(item.route));
                return ListTile(
                  leading: Icon(item.icon,
                      size: 20,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.stone500),
                  title: Text(item.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : null,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.stone700,
                      )),
                  selected: isActive,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  dense: true,
                  onTap: () => context.go(item.route),
                );
              }).toList(),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
```

- [ ] **Step 9.3: Create AdminDataGrid**

```dart
// lib/shared/widgets/admin_data_grid.dart
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AdminDataGrid extends StatefulWidget {
  const AdminDataGrid({
    required this.columns,
    required this.rows,
    this.searchHint = '검색...',
    this.filters = const [],
    this.onRowTap,
    this.actions,
    super.key,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String searchHint;
  final List<String> filters;
  final ValueChanged<int>? onRowTap;
  final List<Widget>? actions;

  @override
  State<AdminDataGrid> createState() => _AdminDataGridState();
}

class _AdminDataGridState extends State<AdminDataGrid> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search + filters + actions bar
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (widget.filters.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['전체', ...widget.filters].map((f) {
                      final selected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(f),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            if (widget.actions != null) ...[
              const SizedBox(width: AppSpacing.md),
              ...widget.actions!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Data table
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.stone100),
                columns: widget.columns,
                rows: widget.rows,
                showCheckboxColumn: false,
              ),
            ),
          ),
        ),
        // Pagination
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('1-10 / ${widget.rows.length}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.stone500)),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {},
              // TODO: 팀원 구현 — 커서 페이지네이션
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 9.4: Verify and commit**

```bash
flutter analyze lib/shared/widgets/admin_shell.dart lib/shared/widgets/admin_data_grid.dart lib/core/constants/app_routes.dart
git add lib/shared/widgets/admin_shell.dart lib/shared/widgets/admin_data_grid.dart lib/core/constants/app_routes.dart
git commit -m "feat(ui): AdminShell + AdminDataGrid 공통 레이아웃 추가"
```

---

## Task 10: Admin 화면 10개 구현 + 라우팅 연결

**Files:**
- Modify: `lib/services/platform/features/admin/presentation/screens/admin_screens.dart`
- Modify: `lib/core/router/app_router.dart`

This is the largest single task. The admin_screens.dart file will grow to contain all 10 admin screens using the AdminDataGrid and AdminShell patterns.

- [ ] **Step 10.1: Implement all 10 admin screens**

Rewrite `admin_screens.dart` to contain the following classes, each following the same pattern of AdminDataGrid with mock data:

1. **AdminDashboardScreen** (ADMIN-001 보강): KPI cards (DAU/MAU/MRR/신규), usage gauges (`LinearProgressIndicator` for AI tokens 62%, Storage 41%, Kafka normal), pending items card (신고 8건/GDPR 3건/할당량 초과 5건), recent activity list.

2. **AdminTenantScreen** (ADMIN-002): `AdminDataGrid` with columns [테넌트명, 플랜, 멤버수, 상태, 생성일]. Filters: [Free, Pro, Enterprise, 정지됨]. Row tap → side sheet with usage chart mock + `ConfirmDialog` for status change.

3. **AdminUserScreen** (ADMIN-003): `AdminDataGrid` with columns [이메일, 이름, 역할, 상태, 가입일]. Filters: [활성, 정지, 삭제]. Row tap → side sheet with activity timeline. Action buttons: 정지/삭제/MFA해제, each via `ConfirmDialog`.

4. **AdminAuditLogScreen** (ADMIN-004): `AdminDataGrid` with columns [시각, 액터, 액션, 대상, IP]. Filters: [LOGIN, CREATE, UPDATE, DELETE]. `ExpansionTile` for JSON detail. CSV export `OutlinedButton.icon`.

5. **AdminSystemSettingsScreen** (ADMIN-005): `DefaultTabController` with 3 tabs. Tab 1: plan quota `DataTable` with editable `TextFormField` cells. Tab 2: feature flags `SwitchListTile` list. Tab 3: rate limit `TextFormField`s. Save `FilledButton`.

6. **AdminReportScreen** (ADMIN-006): Status tabs (`TabBar`: 대기/처리중/완료/기각). `AdminDataGrid` with columns [ID, 신고자, 대상, 사유, 접수일]. Detail panel showing reporter/target/reason/evidence. 4 action buttons (warn/suspend/remove/dismiss).

7. **AdminContentScreen** (ADMIN-007): `TabBar` (공유 덱/공유 노트). `AdminDataGrid` with columns [제목, 작성자, 상태, 신고수, 등록일]. Status `DropdownButton`. Checkbox column + bulk action bar.

8. **AdminGroupScreen** (ADMIN-008): `AdminDataGrid` with columns [그룹명, 멤버수, 상태, 생성일]. Row tap → side sheet with member list and activity. Action modals: 정지/활성화/강제해체.

9. **AdminGamificationScreen** (ADMIN-009): `DefaultTabController` with 4 tabs. Tab 1: stats overview cards (총 XP/활성 배지/평균 레벨). Tab 2: badge `GridView` with add/edit dialog. Tab 3: level `DataTable` with editable rows. Tab 4: XP config `TextFormField`s.

10. **AdminDataRequestScreen** (ADMIN-010): Status tabs (대기/처리중/완료/거부). `AdminDataGrid` with columns [접수일, 사용자, 유형, 상태]. Detail panel: user info, data summary (노트 N건/카드 N건/첨부 NMB), execution log timeline, 30-day countdown `Text`. 3 action buttons: 내보내기 실행/삭제 승인/거부.

Each screen:
- Is a `ConsumerWidget` (or `ConsumerStatefulWidget` if it has tabs/state)
- Imports `AdminDataGrid`, `ConfirmDialog`, `AppColors`, `AppSpacing`
- Uses `_mock*` const data at file bottom
- Has `// TODO: 팀원 구현 —` markers

- [ ] **Step 10.2: Update app_router.dart with admin routes**

Replace the single admin route with a `ShellRoute` using `AdminShell`:

```dart
      // ── Admin routes (with AdminShell) ── Web only
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.admin,
            redirect: (context, state) => kIsWeb ? null : AppRoutes.dashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminTenants,
            builder: (context, state) => const AdminTenantScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            builder: (context, state) => const AdminUserScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminAuditLogs,
            builder: (context, state) => const AdminAuditLogScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminSettings,
            builder: (context, state) => const AdminSystemSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminReports,
            builder: (context, state) => const AdminReportScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminContent,
            builder: (context, state) => const AdminContentScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminGroups,
            builder: (context, state) => const AdminGroupScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminGamification,
            builder: (context, state) => const AdminGamificationScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminDataRequests,
            builder: (context, state) => const AdminDataRequestScreen(),
          ),
        ],
      ),
```

Remove the old admin route from the user ShellRoute. Add import for `AdminShell`:

```dart
import 'package:synapse_frontend/shared/widgets/admin_shell.dart';
```

- [ ] **Step 10.3: Verify and commit**

```bash
flutter analyze
git add lib/services/platform/features/admin/presentation/screens/admin_screens.dart lib/core/router/app_router.dart
git commit -m "feat(ui): Admin 10개 화면 전체 구현 (AdminShell 라우팅 포함)"
```

---

## Task 11: Note 영역 보강 (4개 화면)

**Files:**
- Modify: `lib/services/knowledge/features/notes/presentation/screens/note_screens.dart`

- [ ] **Step 11.1: Read current note_screens.dart**

Read the file to understand current implementation of NOTE-001, NOTE-003, NOTE-004, NOTE-005.

- [ ] **Step 11.2: Enhance NoteListScreen (NOTE-001)**

Add to the existing `NoteListScreen`:
- A `_FolderTreePanel` widget as left panel (desktop only, 200px width): `TreeView`-like structure using nested `ExpansionTile` widgets with mock folders
- `DropdownButton<String>` for sort (최근 수정/제목순/생성일)
- Wrap content in `Row` for desktop: `[_FolderTreePanel, Expanded(existing content)]`

- [ ] **Step 11.3: Enhance NoteDetailScreen (NOTE-003)**

Add to the existing backlinks section:
- Link count text: `Text('이 노트를 참조하는 노트 (N)')` (already partially there)
- Add "참조 노트" section below backlinks: notes this note references
- Each reference item shows 2-line preview snippet

- [ ] **Step 11.4: Enhance NoteVersionsScreen (NOTE-004)**

Replace/enhance the versions list with:
- A `_DiffView` widget: two `Expanded` columns side by side
- Left column: old version text with deleted lines highlighted in `Color(0x40DC2626)` (red)
- Right column: new version text with added lines highlighted in `Color(0x4016A34A)` (green)
- Mock data: `_mockVersions` list with `{version, date, author, changes}`

- [ ] **Step 11.5: Enhance TagManagementScreen (NOTE-005)**

Add:
- Color picker: `Wrap` of `GestureDetector` circles with preset colors, sets tag color
- Tag merge dialog: `AlertDialog` with two `DropdownButton`s to select source and target tags

- [ ] **Step 11.6: Verify and commit**

```bash
flutter analyze lib/services/knowledge/features/notes/presentation/screens/note_screens.dart
git add lib/services/knowledge/features/notes/presentation/screens/note_screens.dart
git commit -m "feat(ui): Note 4개 화면 보강 (폴더 트리, Diff 뷰, 태그 색상)"
```

---

## Task 12: Card 영역 보강 (5개 화면)

**Files:**
- Modify: `lib/services/learning/features/cards/presentation/screens/card_screens.dart`

- [ ] **Step 12.1: Read current card_screens.dart**

- [ ] **Step 12.2: Enhance DeckListScreen (CARD-001)**

Add:
- `ExpansionTile` for sub-decks under each deck card
- `CircularProgressIndicator` showing mastery percentage on each deck card
- `ReorderableListView` wrapper for drag-to-reorder decks

- [ ] **Step 12.3: Enhance CardListScreen (CARD-002)**

Add:
- `FilterChip` row: Basic / Cloze type filter
- `Checkbox` per card row + "선택 삭제" `FilledButton.tonal` when any selected

- [ ] **Step 12.4: Enhance CardEditorScreen (CARD-003)**

Add:
- Cloze type: when card type is Cloze, show `RichText` with `{{c1::text}}` highlighted in amber
- Image attachment area: `Container` with dashed border + camera icon + "이미지 추가" text

- [ ] **Step 12.5: Enhance AiCardGenerationScreen (CARD-004)**

Add:
- Import and use `AIGenerateLoading` widget during generation state
- After generation: `GridView` of result cards with `Checkbox` on each
- "선택한 카드 저장" `FilledButton` at bottom

- [ ] **Step 12.6: Enhance ReviewResultScreen (CARD-006)**

Add:
- Accuracy donut: `CustomPaint` circle arc showing 78% correct
- Difficulty distribution: `CustomPaint` horizontal bar chart (Again/Hard/Good/Easy percentages)
- "다음 복습 예정" list: 3 items showing card title + next review date

- [ ] **Step 12.7: Verify and commit**

```bash
flutter analyze lib/services/learning/features/cards/presentation/screens/card_screens.dart
git add lib/services/learning/features/cards/presentation/screens/card_screens.dart
git commit -m "feat(ui): Card 5개 화면 보강 (서브덱, Cloze, AI 결과 그리드, 통계 차트)"
```

---

## Task 13: Search 영역 보강 (2개 화면)

**Files:**
- Modify: `lib/services/knowledge/features/search/presentation/screens/search_screens.dart`

- [ ] **Step 13.1: Enhance SearchScreen (SEARCH-001)**

Add:
- `TabBar` with 4 tabs: 전체 / 노트 / 카드 / 커뮤니티
- Result count `Badge` on each tab
- Search keyword highlighting in result text: wrap matched substring in `TextSpan(style: TextStyle(backgroundColor: Color(0x40D97706)))`

- [ ] **Step 13.2: Enhance AiQaScreen (SEARCH-002)**

Add:
- Typing animation effect: use `_AnimatedText` widget that reveals characters with a timer (50ms per char)
- Citation chips: `ActionChip` with `Icons.description_outlined` linking to source note
- Feedback buttons: Row of `IconButton`(thumbs_up) and `IconButton`(thumbs_down) below each AI response
- Import `AIGenerateLoading` for loading state

- [ ] **Step 13.3: Verify and commit**

```bash
flutter analyze lib/services/knowledge/features/search/presentation/screens/search_screens.dart
git add lib/services/knowledge/features/search/presentation/screens/search_screens.dart
git commit -m "feat(ui): Search 2개 화면 보강 (카테고리 탭, 키워드 하이라이팅, AI 타이핑)"
```

---

## Task 14: Settings 영역 보강 (5개 화면)

**Files:**
- Modify: `lib/services/platform/features/settings/presentation/screens/settings_screens.dart`

- [ ] **Step 14.1: Enhance all 5 settings screens**

**SETTINGS-001 (Profile):**
- Avatar: `Stack` with `CircleAvatar(radius: 48)` and positioned camera `IconButton`
- Language: `DropdownButtonFormField<String>` with options [한국어, English, 日本語]

**SETTINGS-002 (Security):**
- MFA section: `SwitchListTile` toggle + when enabled, `Container` with QR placeholder (grey box with "QR 코드" text) + `Wrap` of backup code `Chip`s
- Password change: 3 `TextFormField`s (current/new/confirm)
- Connected accounts: `ListTile` for each OAuth provider with icon + disconnect button

**SETTINGS-003 (Notifications):**
- Category grid: `Table` with rows [복습 리마인더, 커뮤니티 활동, 성취/배지, 시스템 알림] × columns [Push, Email, InApp] using `Switch` widgets
- 방해금지: `RangeSlider` for quiet hours (0-24h) with time labels

**SETTINGS-004 (Data):**
- Export section: 3 `OutlinedButton.icon`s (Markdown/PDF/전체 데이터)
- Progress: `LinearProgressIndicator` (hidden by default, shown during mock export)
- Delete account section: red-bordered `Card` with warning text + `FilledButton`(destructive) → `ConfirmDialog`

**SETTINGS-005 (Tenant):**
- Member invite: `FilledButton.icon`("멤버 초대") → `AlertDialog` with email `TextField` + role `DropdownButton<String>` [관리자, 멤버, 뷰어]
- Member list: `ListTile` per member with `PopupMenuButton` for role change / remove

- [ ] **Step 14.2: Verify and commit**

```bash
flutter analyze lib/services/platform/features/settings/presentation/screens/settings_screens.dart
git add lib/services/platform/features/settings/presentation/screens/settings_screens.dart
git commit -m "feat(ui): Settings 5개 화면 보강 (아바타, MFA, 알림 토글, 데이터 관리, 테넌트)"
```

---

## Task 15: Billing + Community + Gamification + Notification 보강

**Files:**
- Modify: `lib/services/platform/features/billing/presentation/screens/billing_screens.dart`
- Modify: `lib/services/engagement/features/community/presentation/screens/community_screens.dart`
- Modify: `lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart`
- Modify: `lib/services/platform/features/notifications/presentation/screens/notification_screens.dart`

- [ ] **Step 15.1: Enhance BillingHistoryScreen (BILLING-003)**

Add `DataTable` with columns [날짜, 설명, 금액, 상태, PDF] and mock invoice rows. PDF column has `IconButton(Icons.picture_as_pdf)`. Show `EmptyState` when on Free plan.

- [ ] **Step 15.2: Enhance Community 6 screens**

For each community screen, add the specific enhancements listed in the spec §7.7:
- **COMM-001**: timeago text on group cards, member avatar `Stack` (3 overlapping `CircleAvatar` + "+N" text)
- **COMM-002**: member `ListTile` with role `Chip`, activity log `Timeline`-like column (icon + text + time), invite/kick buttons
- **COMM-003**: `RadioListTile<String>` for join type (공개/승인/초대), `InputChip` for tags
- **COMM-004**: star rating `Row` (5 `Icon(Icons.star)` with color), download count, `FilterChip` for category/difficulty
- **COMM-005**: card preview `PageView` carousel, copy + `AppToast.show`, star rating `GestureDetector`, report `TextButton`
- **COMM-006**: shared note `Card` with author/tags/preview, `DropdownButton` filter

- [ ] **Step 15.3: Enhance Gamification 2 screens**

- **GAME-001**: Badge tap → `showModalBottomSheet` with condition + acquisition date. Weekly stats `Row`.
- **GAME-002**: `ChoiceChip` filter (전체/획득/미획득). Badge tap → `BottomSheet` with condition + `LinearProgressIndicator`.

- [ ] **Step 15.4: Enhance Notification 2 screens**

- **NOTI-001**: `TabBar` with 4 categories. Date group headers. "모두 읽음" `TextButton`.
- **NOTI-002**: Category × channel `Table` with `Switch`es. Quiet hours `showTimePicker`.

- [ ] **Step 15.5: Verify and commit**

```bash
flutter analyze
git add lib/services/platform/features/billing/presentation/screens/billing_screens.dart lib/services/engagement/features/community/presentation/screens/community_screens.dart lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart lib/services/platform/features/notifications/presentation/screens/notification_screens.dart
git commit -m "feat(ui): Billing, Community, Gamification, Notification 보강 (27개 부분구현 완성)"
```

---

## Task 16: Component enhancements (기존 5개 보강)

**Files:**
- Modify: `lib/services/knowledge/features/notes/presentation/screens/note_screens.dart` (AutoSaveIndicator, WikilinkChip)
- Modify: `lib/services/learning/features/cards/presentation/screens/card_screens.dart` (ReviewDifficultyBar)
- Modify: `lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart` (StreakFlame)

- [ ] **Step 16.1: Enhance AutoSaveIndicator in note editor**

In `NoteEditorScreen`, find the save status indicator and wrap it with `AnimatedOpacity`:

```dart
AnimatedOpacity(
  opacity: _showSaveIndicator ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 500),
  child: Text('저장됨', style: textTheme.bodySmall?.copyWith(color: AppColors.success)),
)
```

Add `_showSaveIndicator` state and a timer that sets it to false after 2 seconds.

- [ ] **Step 16.2: Enhance WikilinkChip in note editor**

Wrap existing `ActionChip` for wiki links with `Tooltip`:

```dart
Tooltip(
  message: '드롭아웃 기법의 핵심은 학습 시 뉴런을...',
  child: ActionChip(
    label: const Text('드롭아웃'),
    onPressed: () => context.go(AppRoutes.noteDetailPath('2')),
    visualDensity: VisualDensity.compact,
  ),
)
```

- [ ] **Step 16.3: Enhance ReviewDifficultyBar in review screen**

In `ReviewScreen`, find the difficulty buttons and restyle them as a colored bar:

```dart
Row(
  children: [
    _DifficultyButton(label: 'Again', subtitle: '< 1분', color: AppColors.error, onTap: () {}),
    _DifficultyButton(label: 'Hard', subtitle: '3일', color: AppColors.warning, onTap: () {}),
    _DifficultyButton(label: 'Good', subtitle: '7일', color: AppColors.info, onTap: () {}),
    _DifficultyButton(label: 'Easy', subtitle: '14일', color: AppColors.success, onTap: () {}),
  ].map((btn) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: btn))).toList(),
)
```

Where `_DifficultyButton` is a `Container` with the appropriate background color at 10% opacity and a colored bottom border.

- [ ] **Step 16.4: Enhance StreakFlame in gamification**

Add `ScaleTransition` or `AnimatedScale` pulse to the streak flame icon:

```dart
class _AnimatedStreakFlame extends StatefulWidget { ... }

// In state: AnimationController with vsync, 1s duration, repeat reverse
// Widget: AnimatedBuilder → Transform.scale(scale: 1.0 + 0.2 * animation.value)
//   child: Icon(Icons.local_fire_department, color: AppColors.primaryAmber, size: 28)
```

- [ ] **Step 16.5: Verify and commit**

```bash
flutter analyze
git add lib/services/knowledge/features/notes/presentation/screens/note_screens.dart lib/services/learning/features/cards/presentation/screens/card_screens.dart lib/services/engagement/features/gamification/presentation/screens/gamification_screens.dart
git commit -m "feat(ui): 기존 컴포넌트 5개 보강 (AutoSave, WikilinkChip, DifficultyBar, StreakFlame)"
```

---

## Task 17: Final verification + admin quick link wiring

**Files:**
- Modify: `lib/services/platform/features/admin/presentation/screens/admin_screens.dart` (wire quick link buttons)

- [ ] **Step 17.1: Wire admin dashboard quick links**

In `AdminDashboardScreen`, update the quick link buttons to actually navigate:

```dart
OutlinedButton.icon(
  onPressed: () => context.go(AppRoutes.adminTenants),
  icon: const Icon(Icons.business_outlined),
  label: const Text('테넌트 관리'),
),
OutlinedButton.icon(
  onPressed: () => context.go(AppRoutes.adminUsers),
  icon: const Icon(Icons.people_outline),
  label: const Text('사용자 관리'),
),
OutlinedButton.icon(
  onPressed: () => context.go(AppRoutes.adminReports),
  // ...
),
```

Add `import 'package:go_router/go_router.dart';` and `import 'package:synapse_frontend/core/constants/app_routes.dart';` if not already present.

- [ ] **Step 17.2: Full project analysis**

```bash
flutter analyze
```

Expected: No issues found (or only pre-existing warnings unrelated to this work).

- [ ] **Step 17.3: Commit and verify git log**

```bash
git add -A
git commit -m "feat(ui): Admin 빠른 링크 연결 + 전체 정적 분석 통과"
git log --oneline -15
```

Expected: ~17 commits on `feat/ui-completion` branch covering all 4 phases.

---

## Post-Implementation Checklist

- [ ] All 52 screens render without crashes (manual spot-check)
- [ ] Admin routes are web-only (`kIsWeb` redirect)
- [ ] `flutter analyze` reports 0 warnings on changed files
- [ ] Mock data is clearly marked with `// TODO: 팀원 구현 —` for every API integration point
- [ ] All new shared widgets in `lib/shared/widgets/` follow existing naming conventions
- [ ] CommandPalette responds to Cmd+K (Mac) and Ctrl+K (Windows)
- [ ] Graph screens render nodes and edges via CustomPaint (not placeholder)
- [ ] AdminShell has working side navigation between all 10 admin routes
