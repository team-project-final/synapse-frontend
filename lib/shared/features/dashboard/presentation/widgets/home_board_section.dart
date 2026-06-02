import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/onboarding_checklist.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ═══════════════════════════════════════════════════════════════════════════
// HomeBoardSection — tutor 디자인 스타일의 편집 가능한 홈 위젯 보드
// ═══════════════════════════════════════════════════════════════════════════

/// 홈 대시보드를 "위젯 보드"로 재구성한 섹션 (BODY only · Scaffold/AppShell 없음).
///
/// 각 타일은 tutor 컨셉(흰 카드 · [AppColors.border] · [AppRadius.lg] · 보라
/// 액센트)을 그대로 유지합니다. 편집 모드(편집/완료 토글)에서 각 타일에
/// 제거(×) 핸들이 나타나며, 보드에 없는 위젯은 하단 추가 바에서 골라
/// 추가할 수 있습니다. 추가/제거는 [_items] 리스트를 직접 변경해 동작합니다.
///
/// 레이아웃은 [Wrap] 기반으로 타일이 자연 높이(content varies)를 가지도록 하여
/// 고정 높이 클리핑을 피합니다. 데스크탑(≥700)은 full/half 2열, 모바일(<700)은
/// 모든 타일이 단일 컬럼으로 리플로우됩니다.
class HomeBoardSection extends StatefulWidget {
  const HomeBoardSection({super.key});

  @override
  State<HomeBoardSection> createState() => _HomeBoardSectionState();
}

class _HomeBoardSectionState extends State<HomeBoardSection> {
  bool _editing = false;

  // TODO: 팀원 구현 — 보드 구성 영속화 / 각 svc 데이터 연동
  // 카탈로그 전체를 표시 순서대로 시드. 카탈로그가 source of truth이며
  // 추가 바는 (카탈로그 - 현재 보드) 를 노출합니다.
  late final List<_BoardKind> _items = <_BoardKind>[
    _BoardKind.ask,
    _BoardKind.todayReview,
    _BoardKind.suggest,
    _BoardKind.insight,
    _BoardKind.streak,
    _BoardKind.level,
    _BoardKind.graph,
    _BoardKind.recentChat,
    _BoardKind.recentNotes,
    _BoardKind.onboarding,
    _BoardKind.ranking,
  ];

  void _toggleEdit() => setState(() => _editing = !_editing);

  void _remove(_BoardKind kind) =>
      setState(() => _items.removeWhere((_BoardKind k) => k == kind));

  void _add(_BoardKind kind) {
    if (_items.contains(kind)) return;
    setState(() => _items.add(kind));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= 700;

        // 추가 바 카탈로그: 전체 - 현재 보드에 올라간 항목.
        final Set<_BoardKind> present = _items.toSet();
        final List<_BoardSpec> addable = _kCatalog
            .where((_BoardSpec spec) => !present.contains(spec.kind))
            .toList(growable: false);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BoardHeader(editing: _editing, onToggleEdit: _toggleEdit),
                  const SizedBox(height: AppSpacing.md),
                  _BoardWrap(
                    items: _items,
                    isDesktop: isDesktop,
                    editing: _editing,
                    onRemove: _remove,
                  ),
                  if (_editing) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _AddWidgetBar(items: addable, onAdd: _add),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── 보드 모델 ────────────────────────────────────────────────────────────────

/// 보드 타일 종류(안정적 id 역할).
enum _BoardKind {
  ask,
  todayReview,
  suggest,
  insight,
  streak,
  level,
  graph,
  recentChat,
  recentNotes,
  onboarding,
  ranking,
}

/// 타일이 차지하는 가로 폭.
enum _TileWidth { full, half }

/// 보드 타일 1개를 기술하는 모델(카탈로그 엔트리).
class _BoardSpec {
  const _BoardSpec({
    required this.kind,
    required this.label,
    required this.emoji,
    required this.width,
  });

  final _BoardKind kind;
  final String label;

  /// 타일 헤더 · 추가 바 썸네일에 쓰는 이모지(ask 타일은 SynapseOrb로 대체).
  final String emoji;
  final _TileWidth width;
}

/// 사용 가능한 전체 위젯 카탈로그(추가 바의 모집단 · 시드 순서의 원본).
const List<_BoardSpec> _kCatalog = <_BoardSpec>[
  _BoardSpec(
    kind: _BoardKind.ask,
    label: 'AI 질문',
    emoji: '✦',
    width: _TileWidth.full,
  ),
  _BoardSpec(
    kind: _BoardKind.todayReview,
    label: '오늘 복습',
    emoji: '📚',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.suggest,
    label: 'AI 추천',
    emoji: '🩺',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.insight,
    label: '이번 주 인사이트',
    emoji: '📈',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.streak,
    label: '스트릭',
    emoji: '🔥',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.level,
    label: 'Lv 7',
    emoji: '⭐',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.graph,
    label: '지식 그래프',
    emoji: '🕸',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.recentChat,
    label: '최근 AI 대화',
    emoji: '💬',
    width: _TileWidth.full,
  ),
  _BoardSpec(
    kind: _BoardKind.recentNotes,
    label: '최근 노트',
    emoji: '📝',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.onboarding,
    label: '시작하기',
    emoji: '🚀',
    width: _TileWidth.full,
  ),
  _BoardSpec(
    kind: _BoardKind.ranking,
    label: '그룹 랭킹',
    emoji: '🏆',
    width: _TileWidth.half,
  ),
];

_BoardSpec _specFor(_BoardKind kind) =>
    _kCatalog.firstWhere((_BoardSpec spec) => spec.kind == kind);

// ── Mock data (tutor 화면에서 가져온 값) ─────────────────────────────────────
// TODO: 팀원 구현 — 보드 구성 영속화 / 각 svc 데이터 연동
const int _kReviewCardCount = 18;
const int _kStreakDays = 14;
const int _kStreakBest = 21;
const int _kWeeklyReviews = 152;
const int _kWeeklyAccuracy = 94;
const int _kWeeklyXp = 420;

class _MockNote {
  const _MockNote({required this.title, required this.timeAgo});
  final String title;
  final String timeAgo;
}

const List<_MockNote> _kMockNotes = <_MockNote>[
  _MockNote(title: '운영체제 가상 메모리 정리', timeAgo: '30분 전'),
  _MockNote(title: 'Flutter 상태 관리 패턴', timeAgo: '2시간 전'),
  _MockNote(title: '이산수학 그래프 이론', timeAgo: '어제'),
];

class _RankRow {
  const _RankRow({
    required this.rank,
    required this.name,
    required this.xp,
    this.highlight = false,
  });
  final int rank;
  final String name;
  final int xp;
  final bool highlight;
}

const List<_RankRow> _kRanking = <_RankRow>[
  _RankRow(rank: 1, name: '민지', xp: 980),
  _RankRow(rank: 2, name: '준호', xp: 760),
  _RankRow(rank: 3, name: '나(김시냅스)', xp: 420, highlight: true),
];

// ── Board header ─────────────────────────────────────────────────────────────

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({required this.editing, required this.onToggleEdit});

  final bool editing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                editing ? '위젯을 제거하거나 추가하세요' : '오늘도 함께 학습해요',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                editing ? '보드 편집' : '내 보드',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        // 편집/완료 토글
        editing
            ? FilledButton(onPressed: onToggleEdit, child: const Text('완료'))
            : OutlinedButton.icon(
                onPressed: onToggleEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('편집'),
              ),
      ],
    );
  }
}

// ── Board wrap (자연 높이 타일 · full/half 폭) ───────────────────────────────

class _BoardWrap extends StatelessWidget {
  const _BoardWrap({
    required this.items,
    required this.isDesktop,
    required this.editing,
    required this.onRemove,
  });

  final List<_BoardKind> items;
  final bool isDesktop;
  final bool editing;
  final ValueChanged<_BoardKind> onRemove;

  @override
  Widget build(BuildContext context) {
    const double gap = AppSpacing.md;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double rowWidth = constraints.maxWidth;
        // half 폭: 데스크탑은 (행 폭 - 간격) / 2, 모바일은 전체 폭(단일 컬럼).
        final double halfWidth = isDesktop ? (rowWidth - gap) / 2 : rowWidth;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final _BoardKind kind in items)
              _buildTile(context, kind, rowWidth, halfWidth),
          ],
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    _BoardKind kind,
    double rowWidth,
    double halfWidth,
  ) {
    final _BoardSpec spec = _specFor(kind);
    final bool full = spec.width == _TileWidth.full || !isDesktop;
    final double width = full ? rowWidth : halfWidth;

    final Widget tile = _BoardTile(spec: spec);

    // 편집 모드: 제거(×) 핸들 오버레이.
    final Widget content = editing
        ? Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              tile,
              Positioned(
                top: -6,
                left: -6,
                child: _RemoveHandle(onTap: () => onRemove(kind)),
              ),
            ],
          )
        : tile;

    return SizedBox(width: width, child: content);
  }
}

// ── 타일 chrome (흰 카드 · border · 헤더 + content) ───────────────────────────

/// 모든 타일을 감싸는 tutor 카드 chrome. 헤더(이모지/orb + 라벨) + content.
class _BoardTile extends StatelessWidget {
  const _BoardTile({required this.spec});

  final _BoardSpec spec;

  void _go(BuildContext context, String route) => context.go(route);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Widget header = Row(
      children: <Widget>[
        if (spec.kind == _BoardKind.ask)
          const SynapseOrb(size: 22, glyphScale: 0.5)
        else
          Text(spec.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          spec.label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    final Widget body = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          const SizedBox(height: AppSpacing.sm + 4),
          _content(context),
        ],
      ),
    );

    return body;
  }

  Widget _content(BuildContext context) {
    switch (spec.kind) {
      case _BoardKind.ask:
        return _AskContent(onTap: () => _go(context, AppRoutes.qa));
      case _BoardKind.todayReview:
        return _TodayReviewContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.suggest:
        return _SuggestContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.insight:
        return _InsightContent(
          onTap: () => _go(context, AppRoutes.dashboardStats),
        );
      case _BoardKind.streak:
        return _StreakContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.level:
        return const _LevelContent();
      case _BoardKind.graph:
        return _GraphContent(onTap: () => _go(context, AppRoutes.graph));
      case _BoardKind.recentChat:
        return _RecentChatContent(onTap: () => _go(context, AppRoutes.qa));
      case _BoardKind.recentNotes:
        return _RecentNotesContent(onTap: () => _go(context, AppRoutes.notes));
      case _BoardKind.onboarding:
        return const OnboardingChecklist();
      case _BoardKind.ranking:
        return _RankingContent(
          onTap: () => _go(context, AppRoutes.communityGroups),
        );
    }
  }
}

// ── 타일 content: AI 질문 (greeting + _AskBox 변형) ──────────────────────────

class _AskContent extends StatelessWidget {
  const _AskContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '무엇을 학습해 볼까요?',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        // _AskBox 질문 바.
        Material(
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
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      '질문하거나, 노트를 붙여넣거나, 주제를 입력하세요…',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.mic_none,
                        color: AppColors.muted,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      const Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.primaryFg,
                          size: 19,
                        ),
                      ),
                    ],
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

// ── 타일 content: 오늘 복습 (그라데이션 강조 + 시작 버튼) ──────────────────────

class _TodayReviewContent extends StatelessWidget {
  const _TodayReviewContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$_kReviewCardCount장',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '복습 대기 12 · 학습 중 4 · 새 카드 2',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('시작하기', style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: AI 추천 (_SuggestCard 변형) ────────────────────────────────

class _SuggestContent extends StatelessWidget {
  const _SuggestContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm - 1),
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: const Text('🩺', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '\'과적합\' 개념이 약해 보여요',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '최근 3번 중 2번 틀렸어요. 관련 노트 3개로 미니 퀴즈를 만들어 드릴까요?',
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
                  child: const Text(
                    '퀴즈 시작 →',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: 이번 주 인사이트 (_InsightStat 3개) ────────────────────────

class _InsightContent extends StatelessWidget {
  const _InsightContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Row(
          children: <Widget>[
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
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('통계 더보기', style: TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}

/// tutor 대시보드의 _InsightStat 변형 (값/라벨/색).
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
    final TextTheme textTheme = Theme.of(context).textTheme;
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
        children: <Widget>[
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
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

// ── 타일 content: 스트릭 ──────────────────────────────────────────────────────

class _StreakContent extends StatelessWidget {
  const _StreakContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$_kStreakDays일',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.streak,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '최고 $_kStreakBest일',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: 레벨 (진행 바) ─────────────────────────────────────────────

class _LevelContent extends StatelessWidget {
  const _LevelContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '지식 탐험가',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: const LinearProgressIndicator(
            value: 0.9,
            minHeight: 8,
            backgroundColor: AppColors.surface2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Lv8까지 360 XP',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

// ── 타일 content: 지식 그래프 (mini graph painter) ──────────────────────────

class _GraphContent extends StatelessWidget {
  const _GraphContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: const SizedBox(
        height: 150,
        width: double.infinity,
        child: CustomPaint(painter: _MiniGraphPainter()),
      ),
    );
  }
}

// ── 타일 content: 최근 AI 대화 (_RecentChatCard 변형) ────────────────────────

class _RecentChatContent extends StatelessWidget {
  const _RecentChatContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SynapseOrb(size: 32, glyphScale: 0.47),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AI 튜터',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '● 답변 완료',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const _ChatBubble(text: '트랜스포머 노트로 복습 카드 만들어줘', isMe: true),
        const SizedBox(height: AppSpacing.sm),
        const _ChatBubble(
          text: '「트랜스포머」 노트에서 핵심 4장을 만들었어요. 추가할 카드를 골라주세요 👇',
          isMe: false,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('대화 이어가기', style: TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
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
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(isMe ? AppRadius.lg : 5),
              bottomRight: Radius.circular(isMe ? 5 : AppRadius.lg),
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

// ── 타일 content: 최근 노트 (compact rows) ───────────────────────────────────

class _RecentNotesContent extends StatelessWidget {
  const _RecentNotesContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        for (int i = 0; i < _kMockNotes.length; i++)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm - 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: i < _kMockNotes.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.description_outlined,
                    size: 17,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _kMockNotes[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _kMockNotes[i].timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── 타일 content: 그룹 랭킹 (순위 rows) ──────────────────────────────────────

class _RankingContent extends StatelessWidget {
  const _RankingContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        for (final _RankRow row in _kRanking)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm - 4),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                color: row.highlight
                    ? AppColors.accent.withValues(alpha: 0.10)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm - 4),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${row.rank}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: row.highlight
                            ? AppColors.accent
                            : AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      row.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: row.highlight
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '+${row.xp}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: row.highlight ? AppColors.accent : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── 편집 모드: 제거 핸들 / 위젯 추가 바 ───────────────────────────────────────

class _RemoveHandle extends StatelessWidget {
  const _RemoveHandle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 2),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

/// 위젯 추가 시트(가로 스크롤 add-item). 보드에 없는 위젯만 노출됩니다.
class _AddWidgetBar extends StatelessWidget {
  const _AddWidgetBar({required this.items, required this.onAdd});

  final List<_BoardSpec> items;
  final ValueChanged<_BoardKind> onAdd;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const Text(
            '＋ 위젯 추가',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '보드에 올릴 위젯을 골라보세요',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                '모든 위젯이 추가되었습니다',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final _BoardSpec item in items)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm + 2),
                      child: _AddItem(
                        item: item,
                        onTap: () => onAdd(item.kind),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddItem extends StatelessWidget {
  const _AddItem({required this.item, required this.onTap});

  final _BoardSpec item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius radius = BorderRadius.circular(AppRadius.sm);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.surface,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                ),
                alignment: Alignment.center,
                child: item.kind == _BoardKind.ask
                    ? const SynapseOrb(size: 26, glyphScale: 0.5)
                    : Text(item.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '＋ 추가',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini knowledge-graph painter (지식 그래프 타일 장식) ─────────────────────
// widget_board_section.dart 의 _MiniGraphPainter 복사본.

class _MiniGraphPainter extends CustomPainter {
  const _MiniGraphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 0..220 x 0..150 좌표계를 타일 크기에 맞춰 스케일.
    final double sx = size.width / 220;
    final double sy = size.height / 150;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final Paint edge = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.6;
    const Offset center = Offset(110, 78);
    const List<Offset> nodes = <Offset>[
      Offset(52, 34),
      Offset(172, 38),
      Offset(58, 122),
      Offset(170, 112),
      Offset(190, 78),
    ];
    for (final Offset n in nodes) {
      canvas.drawLine(p(center.dx, center.dy), p(n.dx, n.dy), edge);
    }
    canvas.drawLine(p(52, 34), p(20, 60), edge);
    canvas.drawLine(p(172, 38), p(200, 30), edge);

    void dot(double x, double y, double r, Color c, [double opacity = 1]) {
      canvas.drawCircle(
        p(x, y),
        r * ((sx + sy) / 2),
        Paint()..color = c.withValues(alpha: opacity),
      );
    }

    dot(110, 78, 22, AppColors.primary);
    dot(52, 34, 11, AppColors.primary, 0.7);
    dot(172, 38, 13, AppColors.accent);
    dot(58, 122, 9, AppColors.primary, 0.7);
    dot(170, 112, 11, AppColors.streak);
    dot(190, 78, 8, AppColors.success);
    dot(20, 60, 7, AppColors.accent, 0.8);
    dot(200, 30, 6, AppColors.accent, 0.7);
  }

  @override
  bool shouldRepaint(covariant _MiniGraphPainter oldDelegate) => false;
}
