import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── BillingPlansScreen (SCR-W-BILLING-001) ──

class BillingPlansScreen extends ConsumerWidget {
  const BillingPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    // TODO: 팀원 구현 — platform-svc 플랜 정보 및 현재 플랜 API 연동
    final plans = [
      _PlanData(
        name: 'Free',
        price: '₩0 / 월',
        features: [
          _PlanFeature(label: '노트 100개', available: true),
          _PlanFeature(label: '카드 500장', available: true),
          _PlanFeature(label: 'AI 카드 생성', available: false),
          _PlanFeature(label: '그래프 뷰', available: false),
        ],
        actionLabel: '현재 플랜',
        isCurrent: true,
        isHighlighted: false,
      ),
      _PlanData(
        name: 'Pro',
        price: '₩9,900 / 월',
        features: [
          _PlanFeature(label: '노트 무제한', available: true),
          _PlanFeature(label: '카드 무제한', available: true),
          _PlanFeature(label: 'AI 카드 생성', available: true),
          _PlanFeature(label: '그래프 뷰', available: true),
        ],
        actionLabel: '업그레이드',
        isCurrent: false,
        isHighlighted: true,
      ),
      _PlanData(
        name: 'Team',
        price: '₩29,900 / 월 / 인',
        features: [
          _PlanFeature(label: 'Pro 모든 기능', available: true),
          _PlanFeature(label: '팀 공유 덱', available: true),
          _PlanFeature(label: '관리자 대시보드', available: true),
          _PlanFeature(label: '우선 지원', available: true),
        ],
        actionLabel: '팀 문의',
        isCurrent: false,
        isHighlighted: false,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('플랜 선택', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text('학습 목표에 맞는 플랜을 선택하세요',
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.stone500)),
        const SizedBox(height: AppSpacing.xl),
        if (isMobile)
          Column(
            children: plans
                .map((plan) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _PlanCard(plan: plan),
                    ))
                .toList(),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plans
                .map((plan) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        child: _PlanCard(plan: plan),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _PlanFeature {
  const _PlanFeature({required this.label, required this.available});
  final String label;
  final bool available;
}

class _PlanData {
  const _PlanData({
    required this.name,
    required this.price,
    required this.features,
    required this.actionLabel,
    required this.isCurrent,
    required this.isHighlighted,
  });
  final String name;
  final String price;
  final List<_PlanFeature> features;
  final String actionLabel;
  final bool isCurrent;
  final bool isHighlighted;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final _PlanData plan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: plan.isHighlighted
            ? BorderSide(color: AppColors.primaryAmber, width: 2)
            : BorderSide(color: AppColors.stone200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.isHighlighted)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text('추천',
                    style: textTheme.labelSmall
                        ?.copyWith(color: Colors.white)),
              ),
            if (plan.isHighlighted) const SizedBox(height: AppSpacing.sm),
            Text(plan.name, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(plan.price,
                style: textTheme.headlineSmall
                    ?.copyWith(color: AppColors.primaryAmber)),
            const SizedBox(height: AppSpacing.md),
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        f.available ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: f.available
                            ? AppColors.success
                            : AppColors.stone300,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(f.label,
                          style: textTheme.bodySmall?.copyWith(
                              color: f.available
                                  ? null
                                  : AppColors.stone400)),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
            if (plan.isCurrent)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.stone100,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: AppColors.stone200),
                ),
                child: Center(
                  child: Text(plan.actionLabel,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.stone500)),
                ),
              )
            else if (plan.isHighlighted)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — 플랜 업그레이드 결제 연동
                  },
                  child: Text(plan.actionLabel),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — 팀 플랜 문의 연동
                  },
                  child: Text(plan.actionLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── BillingUsageScreen (SCR-W-BILLING-002) ──

class BillingUsageScreen extends ConsumerWidget {
  const BillingUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 사용량 API 연동
    final usageItems = [
      _UsageItem(
          label: '노트',
          current: 45,
          max: 100,
          unit: '개',
          progress: 0.45,
          isLocked: false),
      _UsageItem(
          label: '카드',
          current: 360,
          max: 500,
          unit: '장',
          progress: 0.72,
          isLocked: false),
      _UsageItem(
          label: 'AI 생성',
          current: 0,
          max: 0,
          unit: '',
          progress: 0.0,
          isLocked: true),
      _UsageItem(
          label: 'API 호출',
          current: 300,
          max: 1000,
          unit: '회',
          progress: 0.3,
          isLocked: false),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('사용량 현황', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        ...usageItems
            .map((item) => _UsageCard(item: item)),
      ],
    );
  }
}

class _UsageItem {
  const _UsageItem({
    required this.label,
    required this.current,
    required this.max,
    required this.unit,
    required this.progress,
    required this.isLocked,
  });
  final String label;
  final int current;
  final int max;
  final String unit;
  final double progress;
  final bool isLocked;
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.item});
  final _UsageItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final progressColor = item.isLocked
        ? AppColors.stone300
        : item.progress >= 0.7
            ? AppColors.warning
            : AppColors.success;

    final labelText = item.isLocked
        ? 'Pro 플랜 필요'
        : '${item.current} / ${item.max}${item.unit}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: textTheme.titleSmall),
                Text(labelText,
                    style: textTheme.bodySmall?.copyWith(
                        color: item.isLocked
                            ? AppColors.stone400
                            : item.progress >= 0.7
                                ? AppColors.warning
                                : AppColors.stone500)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: AppColors.stone200,
              color: progressColor,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              minHeight: 8,
            ),
            if (item.isLocked) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '현재 플랜에서 사용할 수 없습니다',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── BillingHistoryScreen (SCR-W-BILLING-003) ──

class BillingHistoryScreen extends ConsumerWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 결제 이력 API 연동
    // 현재는 Free 플랜이므로 빈 상태 표시
    const mockInvoices = <Map<String, String>>[];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('결제 이력', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        if (mockInvoices.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                const Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.stone300),
                const SizedBox(height: AppSpacing.md),
                Text('결제 이력이 없습니다',
                    style: textTheme.bodyLarge
                        ?.copyWith(color: AppColors.stone400)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Free 플랜을 사용 중입니다',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone300),
                ),
              ],
            ),
          )
        else
          // Invoice list (shown when there are paid invoices)
          Column(
            children: mockInvoices.map((invoice) {
              return ListTile(
                leading: const Icon(Icons.receipt_outlined),
                title: Text(invoice['plan'] ?? ''),
                subtitle: Text(invoice['date'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(invoice['amount'] ?? ''),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {
                        // TODO: 팀원 구현 — 영수증 다운로드
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
