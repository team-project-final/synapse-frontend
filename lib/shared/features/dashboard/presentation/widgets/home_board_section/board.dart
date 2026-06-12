part of '../home_board_section.dart';

/// 홈 대시보드를 "위젯 보드"로 재구성한 섹션 (BODY only · Scaffold/AppShell 없음).
///
/// 각 타일은 tutor 컨셉(흰 카드 · [AppColors.border] · [AppRadius.lg] · 보라
/// 액센트)을 그대로 유지합니다. 편집 모드(편집/완료 토글)에서 각 타일에
/// 제거(×) 핸들이 나타나며, 보드에 없는 위젯은 하단 추가 바에서 골라
/// 추가할 수 있습니다.
///
/// 보드 구성은 [boardConfigProvider] 가 소유합니다 — 추가/제거는 화면에 즉시
/// 반영되고, '완료'를 누르는 시점에 디바이스(Hive)에 저장돼 재방문 시
/// 복원됩니다. 저장값이 없으면 [BoardConfig.defaults] 로 표출합니다.
///
/// 레이아웃은 [Wrap] 기반으로 타일이 자연 높이(content varies)를 가지도록 하여
/// 고정 높이 클리핑을 피합니다. 데스크탑(≥700)은 full/half 2열, 모바일(<700)은
/// 모든 타일이 단일 컬럼으로 리플로우됩니다.
class HomeBoardSection extends ConsumerStatefulWidget {
  const HomeBoardSection({super.key});

  @override
  ConsumerState<HomeBoardSection> createState() => _HomeBoardSectionState();
}

class _HomeBoardSectionState extends ConsumerState<HomeBoardSection> {
  // 편집 모드 토글은 이 화면 한정 임시 UI 상태라 로컬로 둔다.
  bool _editing = false;

  void _toggleEdit() {
    if (_editing) {
      // '완료' = 적용: 현재 구성을 디바이스에 저장.
      unawaited(ref.read(boardConfigProvider.notifier).apply());
    }
    setState(() => _editing = !_editing);
  }

  void _remove(_BoardKind kind) =>
      ref.read(boardConfigProvider.notifier).remove(kind.name);

  void _add(_BoardKind kind) =>
      ref.read(boardConfigProvider.notifier).add(kind.name);

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BoardConfig> configAsync = ref.watch(boardConfigProvider);
    // 로드 완료 전에는 보드를 그리지 않는다 — 디폴트 구성이 먼저 보였다가
    // 저장 구성으로 점프하는 깜빡임 방지. 위젯들이 실데이터를 갖게 되면
    // 이 로딩 구간이 데이터 선로딩 시간도 겸한다.
    if (configAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // 미저장이면 repository 가 null 을 반환해 notifier 가 defaults 를 채우므로,
    // 여기 폴백은 스토리지 장애(AsyncError) 방어용이다.
    final BoardConfig config = configAsync.asData?.value ?? BoardConfig.defaults;
    // 저장된 id 중 더 이상 존재하지 않는 위젯(미래 버전 잔재)은 조용히 버린다.
    final Map<String, _BoardKind> byName = _BoardKind.values.asNameMap();
    final List<_BoardKind> items = config.widgetIds
        .map((String id) => byName[id])
        .whereType<_BoardKind>()
        .toList(growable: false);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= 700;

        // 추가 바 카탈로그: 전체 - 현재 보드에 올라간 항목.
        final Set<_BoardKind> present = items.toSet();
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
                    items: items,
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
