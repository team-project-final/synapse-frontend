import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/billing/data/billing_api.dart';

// ── BillingPlansScreen (SCR-W-BILLING-001) ──

class BillingPlansScreen extends ConsumerStatefulWidget {
  const BillingPlansScreen({super.key});

  @override
  ConsumerState<BillingPlansScreen> createState() => _BillingPlansScreenState();
}

class _BillingPlansScreenState extends ConsumerState<BillingPlansScreen> {
  String _currentPlan = 'FREE';
  String? _checkoutPlan;
  String? _error;
  bool _loadingSubscription = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSubscription());
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await ref.read(billingApiProvider).getSubscription();
      if (!mounted) return;
      setState(() {
        _currentPlan = subscription?.plan.toUpperCase() ?? 'FREE';
        _loadingSubscription = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingSubscription = false;
        _error = '구독 상태를 불러오지 못했습니다.';
      });
    }
  }

  String get _frontendOrigin {
    final base = Uri.base;
    if (base.hasScheme && (base.scheme == 'http' || base.scheme == 'https')) {
      return base.origin;
    }
    return 'http://127.0.0.1:8088';
  }

  String get _billingSuccessUrl => '$_frontendOrigin/billing/success';

  String get _billingCancelUrl => '$_frontendOrigin/billing/cancel';

  Future<void> _startCheckout(_PlanData plan) async {
    if (plan.code == 'FREE') return;

    setState(() {
      _checkoutPlan = plan.code;
      _error = null;
    });

    try {
      final session = await ref
          .read(billingApiProvider)
          .createCheckout(
            planCode: plan.code,
            successUrl: _billingSuccessUrl,
            cancelUrl: _billingCancelUrl,
          );
      if (!mounted) return;
      setState(() {
        _checkoutPlan = null;
      });
      ref.read(billingCheckoutRedirectProvider)(session.checkoutUrl);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkoutPlan = null;
        _error = '결제 페이지를 열지 못했습니다.';
      });
    }
  }

  List<_PlanData> _plans() {
    return [
      _PlanData(
        code: 'FREE',
        name: 'Free',
        price: '₩0 / 월',
        features: const [
          _PlanFeature(label: '노트 100개', available: true),
          _PlanFeature(label: '카드 500장', available: true),
          _PlanFeature(label: 'AI 카드 생성', available: false),
          _PlanFeature(label: '그래프 뷰', available: false),
        ],
        actionLabel: '현재 플랜',
        isCurrent: _currentPlan == 'FREE',
        isHighlighted: false,
        isCheckoutLoading: _checkoutPlan == 'FREE',
        isDisabled: false,
      ),
      _PlanData(
        code: 'PRO',
        name: 'Pro',
        price: '₩9,900 / 월',
        features: const [
          _PlanFeature(label: '노트 무제한', available: true),
          _PlanFeature(label: '카드 무제한', available: true),
          _PlanFeature(label: 'AI 카드 생성', available: true),
          _PlanFeature(label: '그래프 뷰', available: true),
        ],
        actionLabel: _currentPlan == 'PRO' ? '현재 플랜' : '업그레이드',
        isCurrent: _currentPlan == 'PRO',
        isHighlighted: true,
        isCheckoutLoading: _checkoutPlan == 'PRO',
        isDisabled: _loadingSubscription,
      ),
      _PlanData(
        code: 'TEAM',
        name: 'Team',
        price: '₩29,900 / 월 / 인',
        features: const [
          _PlanFeature(label: 'Pro 모든 기능', available: true),
          _PlanFeature(label: '팀 공유 덱', available: true),
          _PlanFeature(label: '관리자 대시보드', available: true),
          _PlanFeature(label: '우선 지원', available: true),
        ],
        actionLabel: _currentPlan == 'TEAM' ? '현재 플랜' : '선택',
        isCurrent: _currentPlan == 'TEAM',
        isHighlighted: false,
        isCheckoutLoading: _checkoutPlan == 'TEAM',
        isDisabled: _loadingSubscription,
      ),
      _PlanData(
        code: 'ENTERPRISE',
        name: 'Enterprise',
        price: '문의',
        features: const [
          _PlanFeature(label: 'Team 모든 기능', available: true),
          _PlanFeature(label: '전용 지원', available: true),
          _PlanFeature(label: '보안 정책 관리', available: true),
          _PlanFeature(label: 'SLA 지원', available: true),
        ],
        actionLabel: _currentPlan == 'ENTERPRISE' ? '현재 플랜' : '선택',
        isCurrent: _currentPlan == 'ENTERPRISE',
        isHighlighted: false,
        isCheckoutLoading: _checkoutPlan == 'ENTERPRISE',
        isDisabled: _loadingSubscription,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final plans = _plans();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('플랜 선택', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '학습 목표에 맞는 플랜을 선택하세요',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        if (_loadingSubscription) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (isMobile)
          Column(
            children: plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PlanCard(plan: plan, onCheckout: _startCheckout),
                  ),
                )
                .toList(),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: plans
                .map(
                  (plan) => SizedBox(
                    width: 260,
                    child: _PlanCard(plan: plan, onCheckout: _startCheckout),
                  ),
                )
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
    required this.code,
    required this.name,
    required this.price,
    required this.features,
    required this.actionLabel,
    required this.isCurrent,
    required this.isHighlighted,
    required this.isCheckoutLoading,
    required this.isDisabled,
  });
  final String code;
  final String name;
  final String price;
  final List<_PlanFeature> features;
  final String actionLabel;
  final bool isCurrent;
  final bool isHighlighted;
  final bool isCheckoutLoading;
  final bool isDisabled;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onCheckout});

  final _PlanData plan;
  final Future<void> Function(_PlanData plan) onCheckout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: plan.isHighlighted
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.isHighlighted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(
                  '추천',
                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            if (plan.isHighlighted) const SizedBox(height: AppSpacing.sm),
            Text(plan.name, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              plan.price,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      f.available ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: f.available ? AppColors.success : AppColors.muted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        f.label,
                        style: textTheme.bodySmall?.copyWith(
                          color: f.available ? null : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (plan.isCurrent)
              Container(
                key: Key('billing-plan-${plan.code.toLowerCase()}-current'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    plan.actionLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              )
            else if (plan.isHighlighted)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: Key('billing-plan-${plan.code.toLowerCase()}-button'),
                  onPressed: plan.isCheckoutLoading || plan.isDisabled
                      ? null
                      : () => onCheckout(plan),
                  child: plan.isCheckoutLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(plan.actionLabel),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: Key('billing-plan-${plan.code.toLowerCase()}-button'),
                  onPressed: plan.isCheckoutLoading || plan.isDisabled
                      ? null
                      : () => onCheckout(plan),
                  child: plan.isCheckoutLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(plan.actionLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BillingReturnScreen extends StatelessWidget {
  const BillingReturnScreen({required this.success, super.key});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = success ? '결제가 완료되었습니다' : '결제가 취소되었습니다';
    final message = success
        ? '구독 상태가 반영되면 플랜 화면에서 확인할 수 있습니다.'
        : '결제가 진행되지 않았습니다. 필요하면 다시 플랜을 선택하세요.';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 64,
                color: success ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
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
    const usageItems = [
      _UsageItem(
        label: '노트',
        current: 45,
        max: 100,
        unit: '개',
        progress: 0.45,
        isLocked: false,
      ),
      _UsageItem(
        label: '카드',
        current: 360,
        max: 500,
        unit: '장',
        progress: 0.72,
        isLocked: false,
      ),
      _UsageItem(
        label: 'AI 생성',
        current: 0,
        max: 0,
        unit: '',
        progress: 0.0,
        isLocked: true,
      ),
      _UsageItem(
        label: 'API 호출',
        current: 300,
        max: 1000,
        unit: '회',
        progress: 0.3,
        isLocked: false,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('사용량 현황', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        ...usageItems.map((item) => _UsageCard(item: item)),
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
        ? AppColors.muted
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
                Text(
                  labelText,
                  style: textTheme.bodySmall?.copyWith(
                    color: item.isLocked
                        ? AppColors.muted
                        : item.progress >= 0.7
                        ? AppColors.warning
                        : AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: AppColors.border,
              color: progressColor,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              minHeight: 8,
            ),
            if (item.isLocked) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '현재 플랜에서 사용할 수 없습니다',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── BillingHistoryScreen (SCR-W-BILLING-003) ──

class BillingHistoryScreen extends ConsumerStatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  ConsumerState<BillingHistoryScreen> createState() =>
      _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends ConsumerState<BillingHistoryScreen> {
  // Toggle to show paid plan data vs free plan empty state
  bool _isFreePlan = true;

  // TODO: 팀원 구현 — platform-svc 결제 이력 API 연동
  static const _mockInvoices = [
    {
      'date': '2026-05-01',
      'description': 'Pro 플랜 — 5월',
      'amount': '₩9,900',
      'status': '완료',
    },
    {
      'date': '2026-04-01',
      'description': 'Pro 플랜 — 4월',
      'amount': '₩9,900',
      'status': '완료',
    },
    {
      'date': '2026-03-01',
      'description': 'Pro 플랜 — 3월',
      'amount': '₩9,900',
      'status': '완료',
    },
    {
      'date': '2026-02-01',
      'description': 'Pro 플랜 — 2월',
      'amount': '₩9,900',
      'status': '완료',
    },
    {
      'date': '2026-01-15',
      'description': 'Pro 플랜 업그레이드 (일할 계산)',
      'amount': '₩4,950',
      'status': '대기',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('결제 이력', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        if (_isFreePlan)
          // Free plan empty state
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppColors.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Free 플랜은 결제 이력이 없습니다',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Free 플랜을 사용 중입니다',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — 업그레이드 페이지로 이동
                    setState(() => _isFreePlan = false);
                  },
                  child: const Text('업그레이드'),
                ),
              ],
            ),
          )
        else
          // Invoice DataTable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('날짜')),
                DataColumn(label: Text('설명')),
                DataColumn(label: Text('금액')),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('PDF')),
              ],
              rows: _mockInvoices.map((invoice) {
                final isCompleted = invoice['status'] == '완료';
                return DataRow(
                  cells: [
                    DataCell(Text(invoice['date']!)),
                    DataCell(Text(invoice['description']!)),
                    DataCell(Text(invoice['amount']!)),
                    DataCell(
                      Chip(
                        label: Text(
                          invoice['status']!,
                          style: textTheme.labelSmall?.copyWith(
                            color: isCompleted ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.error,
                        ),
                        onPressed: () {
                          // TODO: 팀원 구현 — PDF 영수증 다운로드
                        },
                        tooltip: 'PDF 다운로드',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
