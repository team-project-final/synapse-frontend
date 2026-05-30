import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/onboarding_checklist.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

const _kReviewCardCount = 18;
const _kStreakDays = 14;
const _kWeeklyReviews = 152;
const _kWeeklyAccuracy = 94;
const _kWeeklyXp = 420;

const _kMockNotes = [
  _MockNote(
    title: '운영체제 가상 메모리 정리',
    snippet: '페이지 교체 알고리즘 비교: FIFO, LRU, Optimal...',
    timeAgo: '30분 전',
  ),
  _MockNote(
    title: 'Flutter 상태 관리 패턴',
    snippet: 'Riverpod의 Provider 종류와 사용 시점 정리...',
    timeAgo: '2시간 전',
  ),
  _MockNote(
    title: '이산수학 그래프 이론',
    snippet: 'BFS와 DFS 시간복잡도 및 활용 사례...',
    timeAgo: '어제',
  ),
];

List<int> _generateHeatmapData(int days) {
  final rng = math.Random(42);
  return List.generate(days, (_) {
    final roll = rng.nextDouble();
    if (roll < 0.3) return 0;
    if (roll < 0.55) return rng.nextInt(2) + 1;
    if (roll < 0.8) return rng.nextInt(3) + 3;
    if (roll < 0.95) return rng.nextInt(4) + 6;
    return rng.nextInt(6) + 10;
  });
}

// ── Helper model ───────────────────────────────────────────────────────────

class _MockNote {
  const _MockNote({
    required this.title,
    required this.snippet,
    required this.timeAgo,
  });
  final String title;
  final String snippet;
  final String timeAgo;
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-001  DashboardScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── AI 히어로 ──
                _AiHero(isWide: isWide),
                const SizedBox(height: AppSpacing.lg),

                // ── 질문 입력 박스 (디자인 데모 — 탭하면 AI Q&A로) ──
                _AskBox(onTap: () => context.go(AppRoutes.qa)),
                const SizedBox(height: AppSpacing.md),

                // ── 빠른 진입 칩 ──
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _QuickChip(
                      emoji: '📝',
                      label: '노트에서 카드 만들기',
                      onTap: () => context.go(AppRoutes.qa),
                    ),
                    _QuickChip(
                      emoji: '🎯',
                      label: '오늘 복습 $_kReviewCardCount장',
                      onTap: () => context.go(AppRoutes.review),
                    ),
                    _QuickChip(
                      emoji: '🩺',
                      label: '약점 진단',
                      onTap: () => context.go(AppRoutes.qa),
                    ),
                    _QuickChip(
                      emoji: '🔍',
                      label: '의미 검색',
                      onTap: () => context.go(AppRoutes.search),
                    ),
                  ],
                ),

                // ── 시작하기 온보딩 ──
                const SizedBox(height: AppSpacing.xl),
                const OnboardingChecklist(),

                // ── AI 추천 ──
                const _SectionLabel('AI 추천'),
                _ResponsiveTwoCol(
                  isWide: isWide,
                  children: [
                    _SuggestCard(
                      emoji: '🩺',
                      title: '\'과적합\' 개념이 약해 보여요',
                      body: '최근 3번 중 2번 틀렸어요. 관련 노트 3개로 미니 퀴즈를 만들어 드릴까요?',
                      cta: '퀴즈 시작 →',
                      onTap: () => context.go(AppRoutes.review),
                    ),
                    _SuggestCard(
                      emoji: '✨',
                      title: '새 노트 「트랜스포머」에서 4장',
                      body: '어제 쓴 노트로 복습 카드를 만들 수 있어요.',
                      cta: '카드 생성 →',
                      onTap: () => context.go(AppRoutes.qa),
                    ),
                  ],
                ),

                // ── 이번 주 인사이트 ──
                const _SectionLabel('이번 주 인사이트'),
                const Row(
                  children: [
                    Expanded(
                      child: _InsightStat(
                        value: '$_kWeeklyReviews',
                        label: '복습',
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: _InsightStat(
                        value: '$_kWeeklyAccuracy%',
                        label: '정답률',
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: _InsightStat(
                        value: '+$_kWeeklyXp',
                        label: 'XP',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.dashboardStats),
                    child: const Text('통계 더보기'),
                  ),
                ),

                // ── 최근 AI 대화 ──
                const _SectionLabel('최근 AI 대화'),
                _RecentChatCard(onTap: () => context.go(AppRoutes.qa)),

                // ── 최근 노트 ──
                const _SectionLabel('최근 노트'),
                Card(
                  child: Column(
                    children: [
                      // TODO: 팀원 구현 — knowledge-svc 최근 노트 목록 연동
                      for (int i = 0; i < _kMockNotes.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description_outlined,
                              color: AppColors.muted),
                          title: Text(_kMockNotes[i].title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            _kMockNotes[i].snippet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          trailing: Text(
                            _kMockNotes[i].timeAgo,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          onTap: () => context.go(AppRoutes.notes),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.notes),
                    child: const Text('노트 더보기'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Concept components ───────────────────────────────────────────────────────

class _AiHero extends StatelessWidget {
  const _AiHero({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = Text(
      '무엇을 학습해 볼까요?',
      textAlign: isWide ? TextAlign.start : TextAlign.center,
      style: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.text,
      ),
    );
    final sub = Text(
      '김시냅스님, 오늘도 함께 해요 · 🔥 $_kStreakDays일 연속',
      textAlign: isWide ? TextAlign.start : TextAlign.center,
      style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
    );

    if (isWide) {
      return Row(
        children: [
          const SynapseOrb(size: 64, glyphScale: 0.46, shadow: true),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 4), sub],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SynapseOrb(size: 74, glyphScale: 0.44, shadow: true),
        const SizedBox(height: AppSpacing.md),
        heading,
        const SizedBox(height: 5),
        sub,
      ],
    );
  }
}

class _AskBox extends StatelessWidget {
  const _AskBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  '질문하거나, 노트를 붙여넣거나, 주제를 입력하세요…',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.mic_none, color: AppColors.muted, size: 22),
                  const SizedBox(width: AppSpacing.sm + 2),
                  const Icon(Icons.chat_bubble_outline,
                      color: AppColors.muted, size: 20),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: AppColors.primaryFg, size: 19),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 5,
            vertical: AppSpacing.sm + 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, AppSpacing.xl, 2, AppSpacing.sm + 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// 넓으면 2열, 좁으면 1열로 자식 카드를 배치.
class _ResponsiveTwoCol extends StatelessWidget {
  const _ResponsiveTwoCol({required this.isWide, required this.children});

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm + 2),
            children[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm + 2),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class _SuggestCard extends StatelessWidget {
  const _SuggestCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm - 1),
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.sm + 1),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm - 3),
                    ),
                  ),
                  child: Text(cta, style: const TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md - 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentChatCard extends StatelessWidget {
  const _RecentChatCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const SynapseOrb(size: 32, glyphScale: 0.47),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 튜터',
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text('● 답변 완료',
                          style: textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _ChatBubble(
              text: '트랜스포머 노트로 복습 카드 만들어줘',
              isMe: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ChatBubble(
              text: '「트랜스포머」 노트에서 핵심 4장을 만들었어요. 추가할 카드를 골라주세요 👇',
              isMe: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md - 2,
                vertical: AppSpacing.sm + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('3장 선택됨',
                            style: textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text('덱: ML 기초 · +15 XP',
                            style: textTheme.labelSmall
                                ?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('대화 이어가기',
                        style: TextStyle(fontSize: 12.5)),
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2,
            vertical: AppSpacing.sm + 3,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.bg,
            border: isMe ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 5),
              bottomRight: Radius.circular(isMe ? 5 : 16),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMe ? AppColors.primaryFg : AppColors.text,
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-002  DashboardHeatmapScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardHeatmapScreen extends ConsumerStatefulWidget {
  const DashboardHeatmapScreen({super.key});

  @override
  ConsumerState<DashboardHeatmapScreen> createState() =>
      _DashboardHeatmapScreenState();
}

class _DashboardHeatmapScreenState
    extends ConsumerState<DashboardHeatmapScreen> {
  static const int _cols = 52;
  static const int _rows = 7;
  static const double _cellSize = 14;
  static const double _gap = 3;

  late final List<int> _data;
  String? _selectedInfo;

  @override
  void initState() {
    super.initState();
    // TODO: 팀원 구현 — learning-svc 학습 히트맵 데이터 연동
    _data = _generateHeatmapData(_cols * _rows);
  }

  Color _colorForCount(int count) {
    // 컨셉 보라 스케일 (적음→많음)
    if (count == 0) return AppColors.surface2;
    if (count <= 2) return const Color(0xFFD8C6F5);
    if (count <= 5) return const Color(0xFFB388F0);
    if (count <= 9) return const Color(0xFF8B5CF6);
    return AppColors.primary;
  }

  int? _hitTest(Offset local) {
    final col = local.dx ~/ (_cellSize + _gap);
    final row = local.dy ~/ (_cellSize + _gap);
    if (col < 0 || col >= _cols || row < 0 || row >= _rows) return null;
    final index = col * _rows + row;
    if (index >= _data.length) return null;
    return index;
  }

  String _dateForIndex(int index) {
    final today = DateTime.now();
    const totalDays = _cols * _rows;
    final daysAgo = totalDays - 1 - index;
    final date = today.subtract(Duration(days: daysAgo));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gridWidth = _cols * (_cellSize + _gap) - _gap;
    const gridHeight = _rows * (_cellSize + _gap) - _gap;

    return Scaffold(
      appBar: AppBar(title: const Text('학습 히트맵')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (_selectedInfo != null) ...[
            Card(
              color: AppColors.stone50,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  _selectedInfo!,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: GestureDetector(
              onTapDown: (details) {
                final index = _hitTest(details.localPosition);
                if (index != null) {
                  setState(() {
                    final date = _dateForIndex(index);
                    final count = _data[index];
                    _selectedInfo = '$date — $count회 학습';
                  });
                }
              },
              child: CustomPaint(
                size: const Size(gridWidth, gridHeight),
                painter: _HeatmapFullPainter(data: _data),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Legend ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('적음', style: textTheme.bodySmall),
              const SizedBox(width: AppSpacing.xs),
              for (final count in [0, 1, 4, 7, 12])
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _colorForCount(count),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Text('많음', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Full heatmap painter ───────────────────────────────────────────────────

class _HeatmapFullPainter extends CustomPainter {
  _HeatmapFullPainter({required this.data});

  final List<int> data;

  static const int _cols = 52;
  static const int _rows = 7;
  static const double _cellSize = 14;
  static const double _gap = 3;

  Color _colorForCount(int count) {
    // 컨셉 보라 스케일 (적음→많음)
    if (count == 0) return AppColors.surface2;
    if (count <= 2) return const Color(0xFFD8C6F5);
    if (count <= 5) return const Color(0xFFB388F0);
    if (count <= 9) return const Color(0xFF8B5CF6);
    return AppColors.primary;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int col = 0; col < _cols; col++) {
      for (int row = 0; row < _rows; row++) {
        final index = col * _rows + row;
        final count = index < data.length ? data[index] : 0;
        final paint = Paint()..color = _colorForCount(count);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * (_cellSize + _gap),
            row * (_cellSize + _gap),
            _cellSize,
            _cellSize,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapFullPainter oldDelegate) =>
      oldDelegate.data != data;
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-003  DashboardStatsScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardStatsScreen extends ConsumerStatefulWidget {
  const DashboardStatsScreen({super.key});

  @override
  ConsumerState<DashboardStatsScreen> createState() =>
      _DashboardStatsScreenState();
}

class _DashboardStatsScreenState
    extends ConsumerState<DashboardStatsScreen> {
  String _period = '주간';

  // TODO: 팀원 구현 — learning-svc 학습 통계 데이터 연동
  static const _kRetentionData = [0.95, 0.88, 0.82, 0.78, 0.75, 0.73, 0.71];
  static const _kAccuracyByDay = [0.80, 0.75, 0.90, 0.85, 0.70, 0.88, 0.82];
  static const _kStudyTimeHours = [1.5, 2.0, 1.0, 2.5, 1.8, 3.0, 2.2];
  static const _kDayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('학습 통계 상세')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Period filter ──
          Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '주간', label: Text('주간')),
                ButtonSegment(value: '월간', label: Text('월간')),
                ButtonSegment(value: '전체', label: Text('전체')),
              ],
              selected: {_period},
              onSelectionChanged: (selected) {
                setState(() => _period = selected.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Retention curve ──
          Text('기억 유지율', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    values: _kRetentionData,
                    labels: _kDayLabels,
                    color: AppColors.primaryAmber,
                    maxY: 1.0,
                    formatY: (v) => '${(v * 100).toInt()}%',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Accuracy by day ──
          Text('요일별 정확도', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BarChartPainter(
                    values: _kAccuracyByDay,
                    labels: _kDayLabels,
                    color: AppColors.success,
                    maxY: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Study time ──
          Text('일별 학습 시간', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    values: _kStudyTimeHours,
                    labels: _kDayLabels,
                    color: AppColors.info,
                    maxY: 4.0,
                    formatY: (v) => '${v.toStringAsFixed(1)}h',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Line chart painter ─────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.maxY,
    required this.formatY,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxY;
  final String Function(double) formatY;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPad = 40.0;
    const bottomPad = 24.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.stone200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: formatY(maxY * i / 4),
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Line + dots
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = color;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (chartW / (values.length - 1)) * i;
      final y = chartH * (1 - values[i] / maxY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // X label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

// ── Bar chart painter ──────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.maxY,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPad = 40.0;
    const bottomPad = 24.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.stone200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: '${(maxY * i / 4 * 100).toInt()}%',
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Bars
    final barWidth = chartW / values.length * 0.6;
    final spacing = chartW / values.length;

    for (int i = 0; i < values.length; i++) {
      final barH = chartH * (values[i] / maxY);
      final x = leftPad + spacing * i + (spacing - barWidth) / 2;
      final y = chartH - barH;
      final barPaint = Paint()..color = color.withAlpha(200);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(3),
        ),
        barPaint,
      );

      // X label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(leftPad + spacing * i + (spacing - tp.width) / 2, chartH + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
