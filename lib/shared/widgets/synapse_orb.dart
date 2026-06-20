import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

/// Compact Synapse brand mark.
///
/// The name is kept for compatibility with older screens, but the visual is a
/// restrained Warm Intellectual mark instead of the previous decorative orb.
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
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primary, width: 1.4),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.10),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size * glyphScale,
          color: AppColors.primary,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
