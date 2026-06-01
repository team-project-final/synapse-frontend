import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

/// 컨셉 L · Widgets 대시보드의 재사용 위젯 타일.
///
/// 목업의 `.w` 카드 변형(plain / tint / fill / progress / custom)을 표현합니다.
/// 데이터는 호출부에서 mock으로 주입합니다.
enum _TileVariant { plain, tint, fill, progress, custom }

class WidgetTile extends StatelessWidget {
  /// 일반 표면 타일 (큰 숫자 값).
  const WidgetTile.plain({
    required this.label,
    required this.emoji,
    this.value,
    this.unit,
    this.sub,
    this.onTap,
    super.key,
  })  : _variant = _TileVariant.plain,
        tint = null,
        caption = null,
        progress = null,
        footnote = null,
        actionLabel = null,
        onAction = null,
        muted = false,
        child = null;

  /// tint 변형 — 색조 배경 + 컬러 텍스트.
  const WidgetTile.tint({
    required this.label,
    required this.emoji,
    required Color this.tint,
    this.value,
    this.unit,
    this.sub,
    this.onTap,
    super.key,
  })  : _variant = _TileVariant.tint,
        caption = null,
        progress = null,
        footnote = null,
        actionLabel = null,
        onAction = null,
        muted = false,
        child = null;

  /// fill 변형 — 그라데이션 히어로 위젯 (CTA 버튼 포함).
  const WidgetTile.fill({
    required this.label,
    required this.emoji,
    required this.value,
    this.unit,
    this.sub,
    this.actionLabel,
    this.onAction,
    this.onTap,
    super.key,
  })  : _variant = _TileVariant.fill,
        tint = null,
        caption = null,
        progress = null,
        footnote = null,
        muted = false,
        child = null;

  /// progress 변형 — 캡션 + 진행바 + 각주.
  const WidgetTile.progress({
    required this.label,
    required this.emoji,
    required this.caption,
    required this.progress,
    required Color this.tint,
    this.footnote,
    this.onTap,
    super.key,
  })  : _variant = _TileVariant.progress,
        value = null,
        unit = null,
        sub = null,
        actionLabel = null,
        onAction = null,
        muted = false,
        child = null;

  /// custom 변형 — 임의 child(리스트/그래프 등).
  const WidgetTile.custom({
    required this.label,
    required this.emoji,
    required Widget this.child,
    this.tint,
    this.muted = false,
    this.onTap,
    super.key,
  })  : _variant = _TileVariant.custom,
        value = null,
        unit = null,
        sub = null,
        caption = null,
        progress = null,
        footnote = null,
        actionLabel = null,
        onAction = null;

  final _TileVariant _variant;
  final String label;
  final String emoji;
  final String? value;
  final String? unit;
  final String? sub;
  final String? caption;
  final double? progress;
  final String? footnote;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? tint;

  /// custom 타일에서 라벨을 muted 색으로 표시할지 여부.
  final bool muted;
  final Widget? child;
  final VoidCallback? onTap;

  bool get _isFill => _variant == _TileVariant.fill;

  Color get _accentColor => tint ?? AppColors.primary;

  Color get _labelColor {
    if (_isFill) return AppColors.primaryFg;
    if (_variant == _TileVariant.tint ||
        _variant == _TileVariant.progress) {
      return _accentColor;
    }
    return muted ? AppColors.muted : AppColors.text;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    final decoration = _isFill
        ? BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
          )
        : BoxDecoration(
            borderRadius: radius,
            color: tint != null
                ? Color.alphaBlend(
                    _accentColor.withValues(alpha: 0.12), AppColors.surface)
                : AppColors.surface,
            border: Border.all(
              color: tint != null
                  ? Color.alphaBlend(
                      _accentColor.withValues(alpha: 0.30), AppColors.border)
                  : AppColors.border,
            ),
          );

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md - 1),
            // 고정 높이 타일(Wrap) 안에서 콘텐츠가 약간 넘쳐도 RenderFlex
            // overflow 단언으로 크래시하지 않도록 클립한다.
            child: ClipRect(child: _buildContent(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: _labelColor,
            ),
          ),
        ),
      ],
    );

    switch (_variant) {
      case _TileVariant.custom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelRow,
            const SizedBox(height: 6),
            Expanded(child: child!),
          ],
        );
      case _TileVariant.progress:
        // 고정 높이 타일에서 콘텐츠가 넘칠 경우 본문 영역이 줄어들도록
        // 가변 부분을 Flexible로 감싼다(라벨 행은 고정).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelRow,
            const SizedBox(height: 6),
            Flexible(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (caption != null)
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surface2,
                      valueColor: AlwaysStoppedAnimation(_accentColor),
                    ),
                  ),
                  if (footnote != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      footnote!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
              ),
            ),
          ],
        );
      case _TileVariant.fill:
      case _TileVariant.tint:
      case _TileVariant.plain:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            labelRow,
            // 라벨 아래 콘텐츠(값/서브/CTA)는 가변. 고정 높이 타일에서
            // 넘치면 클립되도록 스크롤 불가 영역으로 감싼다.
            Flexible(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value != null) ...[
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _bigValue(),
                      ),
                    ],
                    if (sub != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        sub!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _isFill
                              ? AppColors.primaryFg.withValues(alpha: 0.9)
                              : AppColors.muted,
                        ),
                      ),
                    ],
                    if (_isFill && actionLabel != null) ...[
                      const SizedBox(height: AppSpacing.md - 4),
                      _fillAction(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _bigValue() {
    final valueColor = _isFill
        ? AppColors.primaryFg
        : (tint != null ? _accentColor : AppColors.text);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: value),
          if (unit != null)
            TextSpan(
              text: unit,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
      style: TextStyle(
        fontSize: 34,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: valueColor,
      ),
    );
  }

  Widget _fillAction() {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 1,
            vertical: AppSpacing.sm + 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow,
                  size: 16, color: AppColors.primaryFg),
              const SizedBox(width: 6),
              Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
