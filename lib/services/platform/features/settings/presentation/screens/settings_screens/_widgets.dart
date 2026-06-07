part of '../settings_screens.dart';

/// 컨셉 입력 필드 보더 (큰 radius + 토큰 색).
OutlineInputBorder _conceptBorder() => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadius.md),
  borderSide: const BorderSide(color: AppColors.border),
);
