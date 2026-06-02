part of '../home_board_section.dart';

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
