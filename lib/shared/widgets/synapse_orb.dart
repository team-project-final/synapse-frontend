import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

/// "AI Tutor" 컨셉의 시그니처 오브(orb).
///
/// 핑크→보라 라디얼 그라데이션 원 안에 ✦ 글리프를 그린다. 브랜드 로고,
/// AI 튜터 아바타, FAB 등에 재사용한다. (mock 데이터만 사용 — 기능 없음)
class SynapseOrb extends StatelessWidget {
  const SynapseOrb({
    this.size = 32,
    this.glyph = '✦',
    this.glyphScale = 0.5,
    this.shadow = false,
    super.key,
  });

  final double size;
  final String glyph;

  /// 글리프 폰트 크기 = size * glyphScale.
  final double glyphScale;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.36, -0.44),
          radius: 0.95,
          colors: [AppColors.accent, AppColors.primary],
        ),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: size * 0.45,
                  offset: Offset(0, size * 0.18),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size * glyphScale,
          color: AppColors.primaryFg,
          height: 1,
        ),
      ),
    );
  }
}
