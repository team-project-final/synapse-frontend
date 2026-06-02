import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Mock 데이터 — Study Board (칸반)
//   백엔드 없음. 모든 값은 디자인 시안용 로컬 mock 이다.
//   TODO: 팀원 구현 — learning-svc / knowledge-svc 보드 데이터 연동
// ═══════════════════════════════════════════════════════════════════════════

/// 칸반 카드 한 장의 mock 모델.
class _KanbanCard {
  const _KanbanCard({
    required this.title,
    required this.tag,
    required this.meta,
    this.metaStatus = _MetaStatus.normal,
    required this.route,
  });

  final String title;
  final String tag;
  final String meta;
  final _MetaStatus metaStatus;
  final String route;
}

enum _MetaStatus { normal, warn, ok }

/// 칸반 컬럼 한 개의 mock 모델.
class _KanbanColumn {
  const _KanbanColumn({
    required this.title,
    required this.stripColor,
    required this.cards,
    this.addLabel,
    this.addRoute,
  });

  final String title;
  final Color stripColor;
  final List<_KanbanCard> cards;
  final String? addLabel;
  final String? addRoute;

  int get wip => cards.length;
}

// 새 노트 작성 라우트 (AppRoutes.noteEditorPath('new') 와 동일하나
// const 보드 정의를 위해 리터럴로 둔다).
const String _kComposeRoute = '/notes/new/edit';

// TODO: 팀원 구현 — learning-svc / knowledge-svc 보드 데이터 연동
const List<_KanbanColumn> _kBoardColumns = [
  // 수집함
  _KanbanColumn(
    title: '수집함',
    stripColor: AppColors.columnCollect,
    addLabel: '+ 캡처 추가',
    addRoute: _kComposeRoute,
    cards: [
      _KanbanCard(
        title: 'CAP 정리',
        tag: '#아키텍처',
        meta: '방금 캡처',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: 'Kubernetes',
        tag: '#DevOps',
        meta: '새 노트',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '동적 계획법',
        tag: '#알고리즘',
        meta: '웹 클리핑',
        route: AppRoutes.notes,
      ),
    ],
  ),
  // 학습 중
  _KanbanColumn(
    title: '학습 중',
    stripColor: AppColors.columnLearn,
    addLabel: '✨ AI 카드 생성',
    addRoute: AppRoutes.aiCards,
    cards: [
      _KanbanCard(
        title: '트랜스포머',
        tag: '#딥러닝',
        meta: '카드 4장 생성됨',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '어텐션 메커니즘',
        tag: '#딥러닝',
        meta: '읽는 중',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: 'REST API',
        tag: '#백엔드',
        meta: '초안',
        route: AppRoutes.notes,
      ),
    ],
  ),
  // 복습 대기
  _KanbanColumn(
    title: '복습 대기',
    stripColor: AppColors.columnReview,
    cards: [
      _KanbanCard(
        title: 'ML 기초',
        tag: '#머신러닝',
        meta: '⏰ 오늘 8장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
      _KanbanCard(
        title: '프로그래밍',
        tag: '#알고리즘',
        meta: '⏰ 오늘 5장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
      _KanbanCard(
        title: 'AWS SAA',
        tag: '#DevOps',
        meta: '⏰ 오늘 5장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
    ],
  ),
  // 완료
  _KanbanColumn(
    title: '완료',
    stripColor: AppColors.columnDone,
    cards: [
      _KanbanCard(
        title: '과적합',
        tag: '#머신러닝',
        meta: '✓ 9일 뒤 재복습',
        metaStatus: _MetaStatus.ok,
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '드롭아웃',
        tag: '#머신러닝',
        meta: '✓ 21일 뒤',
        metaStatus: _MetaStatus.ok,
        route: AppRoutes.notes,
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// KanbanSection — 대시보드 탭 본문(칸반 보드)
//   AppShell 내부 탭에 들어가는 BODY 전용 위젯. Scaffold/AppBar 없음.
//   데스크탑(width >= 600): 4컬럼 _DesktopBoard / 모바일: 가로 스크롤 _MobileBoard.
// ═══════════════════════════════════════════════════════════════════════════

class KanbanSection extends StatelessWidget {
  const KanbanSection({this.scrollable = true, this.date, super.key});

  // false면 외부(세로) ListView가 자체 스크롤하지 않고 외부 스크롤 뷰가
  // 담당한다(임베드 모드). 내부 _MobileBoard 가로 스크롤은 영향받지 않는다.
  final bool scrollable;

  // 플래너에서 선택된 날짜. 지정되면 보드 헤더에 해당 날짜를 표시한다.
  // TODO: 팀원 구현 — learning-svc 연동 시 이 날짜의 카드만 로드한다.
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        // 모바일에서 보드는 화면 끝까지 가로 스크롤되므로
        // 가로 패딩을 보드가 직접 관리한다.
        isMobile ? 0 : AppSpacing.lg,
        AppSpacing.md,
      ),
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      children: <Widget>[
        // ── 헤더 ──
        // 날짜 지정(플래너) 시 날짜 헤더, 아니면 모바일 전용 기본 헤더.
        if (date != null) ...<Widget>[
          Padding(
            padding: EdgeInsets.only(right: isMobile ? AppSpacing.lg : 0),
            child: _DateBoardHeader(date: date!),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (isMobile) ...<Widget>[
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: _BoardHeader(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── 오늘 진행 요약 바 ──
        Padding(
          padding: EdgeInsets.only(right: isMobile ? AppSpacing.lg : 0),
          child: const _ProgressLine(),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── 칸반 보드 ──
        if (isMobile)
          const _MobileBoard(columns: _kBoardColumns)
        else
          const _DesktopBoard(columns: _kBoardColumns),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── 모바일 헤더 ──────────────────────────────────────────────────────────────

class _BoardHeader extends StatelessWidget {
  const _BoardHeader();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('내 학습 보드', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '화요일 · 오늘 복습 18장 대기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.add,
          onTap: () => context.go(_kComposeRoute),
        ),
      ],
    );
  }
}

/// 플래너에서 선택한 날짜의 보드 헤더(날짜 + 추가 버튼).
class _DateBoardHeader extends StatelessWidget {
  const _DateBoardHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${date.month}월 ${date.day}일 보드',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '선택한 날짜의 학습 보드 · 복습 18장 대기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.add,
          onTap: () => context.go(_kComposeRoute),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 19, color: AppColors.text),
        ),
      ),
    );
  }
}

// ── 진행 요약 바 (progline) ──────────────────────────────────────────────────

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '오늘 진행',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('38장 중 12 완료', style: textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 세그먼트 진행 바: 학습/복습/완료
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: const SizedBox(
                height: 10,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 18,
                      child: ColoredBox(color: AppColors.primary),
                    ),
                    Expanded(
                      flex: 30,
                      child: ColoredBox(color: AppColors.streak),
                    ),
                    Expanded(
                      flex: 32,
                      child: ColoredBox(color: AppColors.success),
                    ),
                    Expanded(
                      flex: 20,
                      child: ColoredBox(color: AppColors.surface2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Wrap(
              spacing: AppSpacing.md,
              children: <Widget>[
                _Legend(color: AppColors.primary, label: '학습'),
                _Legend(color: AppColors.streak, label: '복습'),
                _Legend(color: AppColors.success, label: '완료'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

// ── 데스크탑 보드: 4컬럼 그리드 ──────────────────────────────────────────────

class _DesktopBoard extends StatelessWidget {
  const _DesktopBoard({required this.columns});

  final List<_KanbanColumn> columns;

  // 컬럼 최소 폭. 가용 폭이 이보다 좁아지면 컬럼을 찌그러뜨리지 않고
  // 가로 스크롤로 전환한다(웹↔모바일 사이 애매한 폭에서 찌그러짐 방지).
  static const double _minColWidth = 250;
  static const double _gap = AppSpacing.sm + AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int n = columns.length;
        final double needed = n * _minColWidth + (n - 1) * _gap;
        final bool fits = constraints.maxWidth >= needed;

        final Widget row = IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < n; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: _gap),
                // 충분하면 Expanded로 꽉 채우고, 부족하면 최소 폭 고정.
                if (fits)
                  Expanded(child: _BoardColumn(column: columns[i]))
                else
                  SizedBox(
                    width: _minColWidth,
                    child: _BoardColumn(column: columns[i]),
                  ),
              ],
            ],
          ),
        );

        if (fits) return row;
        // 폭 부족 → 가로 스크롤(마우스 드래그 포함, 앱 전역 scrollBehavior).
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        );
      },
    );
  }
}

// ── 모바일 보드: 가로 스크롤 ──────────────────────────────────────────────────

class _MobileBoard extends StatelessWidget {
  const _MobileBoard({required this.columns});

  final List<_KanbanColumn> columns;

  @override
  Widget build(BuildContext context) {
    final double colWidth = MediaQuery.sizeOf(context).width * 0.84;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      physics: const ClampingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < columns.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            SizedBox(
              width: colWidth,
              child: _BoardColumn(column: columns[i]),
            ),
            if (i == columns.length - 1) const SizedBox(width: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

// ── 칸반 컬럼 ────────────────────────────────────────────────────────────────

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({required this.column});

  final _KanbanColumn column;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 컬럼 상단 색 스트립
          Container(height: 4, color: column.stripColor),
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(column.title, style: textTheme.titleSmall),
                ),
                _WipBadge(count: column.wip),
              ],
            ),
          ),
          // 카드들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < column.cards.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _KanbanCardTile(card: column.cards[i]),
                ],
              ],
            ),
          ),
          // 추가 버튼 (있을 때만)
          if (column.addLabel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: _MiniAddButton(
                label: column.addLabel!,
                onTap: () => context.go(column.addRoute!),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _WipBadge extends StatelessWidget {
  const _WipBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

// ── 칸반 카드 ────────────────────────────────────────────────────────────────

class _KanbanCardTile extends StatelessWidget {
  const _KanbanCardTile({required this.card});

  final _KanbanCard card;

  Color get _metaColor => switch (card.metaStatus) {
    _MetaStatus.warn => AppColors.error,
    _MetaStatus.ok => AppColors.success,
    _MetaStatus.normal => AppColors.muted,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm - 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        onTap: () => context.go(card.route),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm - 2),
            border: Border.all(color: AppColors.border),
          ),
          // 컴팩트 칸반 카드 — 토큰(md/sm)으로 올리면 카드가 눈에 띄게
          // 헐거워져 12/11 유지.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      card.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: AppColors.stone300,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Tag(label: card.tag),
              const SizedBox(height: AppSpacing.sm),
              Text(
                card.meta,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _metaColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        // primary 14% 틴트
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MiniAddButton extends StatelessWidget {
  const _MiniAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm - 2),
      onTap: onTap,
      child: _DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리 컨테이너 (miniadd 버튼용).
class _DottedBorderBox extends StatelessWidget {
  const _DottedBorderBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.border,
        radius: AppRadius.sm - 2,
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    const double dash = 4.0;
    const double gap = 3.0;
    for (final PathMetric metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final double next = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
