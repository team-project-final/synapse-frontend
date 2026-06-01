import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/widget_tile.dart';

// ═══════════════════════════════════════════════════════════════════════════
// WidgetBoardSection — 커스터마이즈 가능한 위젯 보드 (tutor 리스킨)
// ═══════════════════════════════════════════════════════════════════════════

/// 대시보드 탭에 들어가는 위젯 보드 섹션 (BODY only).
///
/// 편집 모드(편집/완료 토글)에서 각 타일에 제거(×) 핸들이 나타나며,
/// 보드에 없는 위젯은 하단 추가 바에서 골라 추가할 수 있습니다.
/// 추가/제거는 [State] 의 [_BoardItem] 리스트를 직접 변경하여 동작합니다.
/// 데스크탑(≥600) 4열, 모바일(<600) 2열로 리플로우됩니다.
class WidgetBoardSection extends StatefulWidget {
  const WidgetBoardSection({super.key});

  @override
  State<WidgetBoardSection> createState() => _WidgetBoardSectionState();
}

class _WidgetBoardSectionState extends State<WidgetBoardSection> {
  bool _editing = false;

  // TODO: 팀원 구현 — 위젯 보드 구성 영속화(서버/로컬 저장)
  late final List<_BoardItem> _items = <_BoardItem>[
    _catalog[_BoardKind.review]!,
    _catalog[_BoardKind.streak]!,
    _catalog[_BoardKind.level]!,
    _catalog[_BoardKind.weekly]!,
    _catalog[_BoardKind.graph]!,
    _catalog[_BoardKind.notes]!,
    _catalog[_BoardKind.ranking]!,
  ];

  void _toggleEdit() => setState(() => _editing = !_editing);

  void _remove(_BoardKind kind) => setState(
    () => _items.removeWhere((_BoardItem item) => item.kind == kind),
  );

  void _add(_BoardKind kind) {
    final _BoardItem? item = _catalog[kind];
    if (item == null) return;
    setState(() => _items.add(item));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final int cols = isMobile ? 2 : 4;

        // 추가 바 카탈로그: 전체 - 현재 보드에 올라간 항목.
        final Set<_BoardKind> present = _items
            .map((_BoardItem item) => item.kind)
            .toSet();
        final List<_BoardItem> addable = _catalog.values
            .where((_BoardItem item) => !present.contains(item.kind))
            .toList(growable: false);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BoardHeader(editing: _editing, onToggleEdit: _toggleEdit),
                  const SizedBox(height: AppSpacing.md),
                  _WidgetGrid(
                    items: _items,
                    columns: cols,
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
enum _BoardKind { review, streak, level, weekly, graph, notes, ranking }

/// 타일이 차지하는 셀 크기.
enum _TileSpan { small, wide, big, tall }

/// 보드 타일 1개를 기술하는 모델.
///
/// [builder] 는 종류에 맞는 [WidgetTile] 변형을 반환합니다.
class _BoardItem {
  const _BoardItem({
    required this.kind,
    required this.label,
    required this.emoji,
    required this.span,
    required this.color,
    required this.builder,
  });

  final _BoardKind kind;
  final String label;
  final String emoji;
  final _TileSpan span;

  /// 추가 바 썸네일 강조색.
  final Color color;

  /// 타일 본체를 만드는 빌더.
  final WidgetTile Function() builder;
}

/// 사용 가능한 전체 위젯 카탈로그(추가 바의 모집단).
final Map<_BoardKind, _BoardItem> _catalog = <_BoardKind, _BoardItem>{
  _BoardKind.review: _BoardItem(
    kind: _BoardKind.review,
    label: '오늘 복습',
    emoji: '📚',
    span: _TileSpan.big,
    color: AppColors.primary,
    builder: () => const WidgetTile.fill(
      label: '오늘 복습',
      emoji: '📚',
      value: '18',
      unit: '장',
      sub: '복습 대기 12 · 학습 중 4 · 새 카드 2',
      actionLabel: '시작하기',
    ),
  ),
  _BoardKind.streak: _BoardItem(
    kind: _BoardKind.streak,
    label: '스트릭',
    emoji: '🔥',
    span: _TileSpan.small,
    color: AppColors.streak,
    builder: () => const WidgetTile.tint(
      label: '스트릭',
      emoji: '🔥',
      value: '14',
      unit: '일',
      sub: '최고 21일',
      tint: AppColors.streak,
    ),
  ),
  _BoardKind.level: _BoardItem(
    kind: _BoardKind.level,
    label: 'Lv 7',
    emoji: '⭐',
    span: _TileSpan.small,
    color: AppColors.primary,
    builder: () => const WidgetTile.progress(
      label: 'Lv 7',
      emoji: '⭐',
      caption: '지식 탐험가',
      progress: 0.9,
      footnote: 'Lv8까지 360 XP',
      tint: AppColors.primary,
    ),
  ),
  _BoardKind.weekly: _BoardItem(
    kind: _BoardKind.weekly,
    label: '이번 주',
    emoji: '📈',
    span: _TileSpan.wide,
    color: AppColors.success,
    builder: () => const WidgetTile.tint(
      label: '이번 주',
      emoji: '📈',
      value: '152',
      sub: '복습 · XP +420 · 정답률 94%',
      tint: AppColors.success,
    ),
  ),
  _BoardKind.graph: _BoardItem(
    kind: _BoardKind.graph,
    label: '지식 그래프',
    emoji: '🕸',
    span: _TileSpan.big,
    color: AppColors.primary,
    builder: () => const WidgetTile.custom(
      label: '지식 그래프',
      emoji: '🕸',
      child: SizedBox.expand(child: CustomPaint(painter: _MiniGraphPainter())),
    ),
  ),
  _BoardKind.notes: _BoardItem(
    kind: _BoardKind.notes,
    label: '최근 노트',
    emoji: '📝',
    span: _TileSpan.tall,
    color: AppColors.accent,
    builder: () => const WidgetTile.custom(
      label: '최근 노트',
      emoji: '📝',
      muted: true,
      child: _RecentNotesList(),
    ),
  ),
  _BoardKind.ranking: _BoardItem(
    kind: _BoardKind.ranking,
    label: '그룹 랭킹',
    emoji: '🏆',
    span: _TileSpan.wide,
    color: AppColors.accent,
    builder: () => const WidgetTile.custom(
      label: '그룹 랭킹 · 알고리즘 마스터즈',
      emoji: '🏆',
      tint: AppColors.accent,
      child: _GroupRankingBody(),
    ),
  ),
};

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
                editing ? '위젯을 제거하거나 추가하세요' : '화요일, 5월 29일',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                editing ? '보드 편집' : '내 보드',
                style: const TextStyle(
                  fontSize: 26,
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

// ── Widget grid ──────────────────────────────────────────────────────────────

class _WidgetGrid extends StatelessWidget {
  const _WidgetGrid({
    required this.items,
    required this.columns,
    required this.editing,
    required this.onRemove,
  });

  final List<_BoardItem> items;
  final int columns;
  final bool editing;
  final ValueChanged<_BoardKind> onRemove;

  /// span 종류를 (colSpan, rowSpan) 으로 변환 — 모바일(2열)에서는 클램프.
  (int, int) _spanFor(_TileSpan span) {
    final int span2 = columns >= 2 ? 2 : 1;
    switch (span) {
      case _TileSpan.small:
        return (1, 1);
      case _TileSpan.wide:
        return (span2, 1);
      case _TileSpan.big:
        return (span2, 2);
      case _TileSpan.tall:
        // 좁은 화면에서는 세로 2칸이 과하므로 1칸으로 축소.
        return (1, columns >= 4 ? 2 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double gap = AppSpacing.md - 3; // 13
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cellW =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        const double cellH = 96.0;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final _BoardItem item in items)
              _buildCell(item, cellW, cellH, gap),
          ],
        );
      },
    );
  }

  Widget _buildCell(_BoardItem item, double cellW, double cellH, double gap) {
    final (int colSpan, int rowSpan) = _spanFor(item.span);
    final double w = cellW * colSpan + gap * (colSpan - 1);
    final double h = cellH * rowSpan + gap * (rowSpan - 1);

    // 편집 모드: 제거(×) 핸들 오버레이.
    final Widget content = editing
        ? Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(child: item.builder()),
              Positioned(
                top: -6,
                left: -6,
                child: _RemoveHandle(onTap: () => onRemove(item.kind)),
              ),
            ],
          )
        : item.builder();

    return SizedBox(width: w, height: h, child: content);
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

  final List<_BoardItem> items;
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
          const SizedBox(height: 4),
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
                  for (final _BoardItem item in items)
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

  final _BoardItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                    item.color.withValues(alpha: 0.16),
                    AppColors.surface,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                ),
                alignment: Alignment.center,
                child: Text(item.emoji, style: const TextStyle(fontSize: 21)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '＋ 추가',
                style: TextStyle(
                  fontSize: 11,
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

// ── 타일 본문 위젯 (custom 변형용) ───────────────────────────────────────────

/// 최근 노트 mock 데이터.
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

const List<Color> _kDotColors = <Color>[
  AppColors.primary,
  AppColors.accent,
  AppColors.streak,
];

class _RecentNotesList extends StatelessWidget {
  const _RecentNotesList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (int i = 0; i < _kMockNotes.length; i++)
          _MiniNoteRow(
            note: _kMockNotes[i],
            dotColor: _kDotColors[i % _kDotColors.length],
            showDivider: i < _kMockNotes.length - 1,
          ),
      ],
    );
  }
}

class _MiniNoteRow extends StatelessWidget {
  const _MiniNoteRow({
    required this.note,
    required this.dotColor,
    required this.showDivider,
  });

  final _MockNote note;
  final Color dotColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            note.timeAgo,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupRankingBody extends StatelessWidget {
  const _GroupRankingBody();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '3위',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.accent,
          ),
        ),
        SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '민지 +980 · 준호 +760 · '),
                TextSpan(
                  text: '나 +420',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini knowledge-graph painter (위젯 타일용 장식) ─────────────────────────

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
