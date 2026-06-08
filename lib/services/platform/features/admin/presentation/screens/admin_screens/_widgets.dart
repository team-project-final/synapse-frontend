part of '../admin_screens.dart';

/// 관리자 목록 화면 공통 — 로드 실패 시 메시지 + 다시 시도 버튼.
class _AdminErrorRetry extends StatelessWidget {
  const _AdminErrorRetry({
    required this.onRetry,
    this.message = '데이터를 불러오지 못했습니다.',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == '활성' || status == '완료';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(status),
      ],
    );
  }
}
