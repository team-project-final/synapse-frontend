import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
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

// ── BillingHistoryScreen (SCR-W-BILLING-003) ──

class BillingHistoryScreen extends ConsumerStatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  ConsumerState<BillingHistoryScreen> createState() =>
      _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends ConsumerState<BillingHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<PaymentHistoryItem> _payments = const [];
  String? _openingReceiptId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(billingApiProvider).getPayments(size: 50);
      if (!mounted) return;
      setState(() {
        _payments = page.items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '결제 이력을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _openReceipt(PaymentHistoryItem item) async {
    setState(() => _openingReceiptId = item.id);
    try {
      final receipt = await ref.read(billingApiProvider).getReceipt(item.id);
      if (!mounted) return;
      setState(() => _openingReceiptId = null);
      final url = receipt.bestUrl;
      if (receipt.available && url != null && url.isNotEmpty) {
        ref.read(billingCheckoutRedirectProvider)(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영수증을 사용할 수 없습니다.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _openingReceiptId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영수증을 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('결제 이력', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
              ],
            ),
          )
        else if (_payments.isEmpty)
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
                  '결제 이력이 없습니다',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.billingPlans),
                  child: const Text('요금제 보기'),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('날짜')),
                DataColumn(label: Text('금액')),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('영수증')),
              ],
              rows: _payments.map((payment) {
                final completed = _isPaid(payment.status);
                return DataRow(
                  cells: [
                    DataCell(Text(_formatDate(payment.date))),
                    DataCell(
                      Text(_formatAmount(payment.amount, payment.currency)),
                    ),
                    DataCell(
                      Chip(
                        label: Text(
                          _statusLabel(payment.status),
                          style: textTheme.labelSmall?.copyWith(
                            color: completed ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: completed
                            ? AppColors.success
                            : AppColors.warning,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    DataCell(_receiptCell(payment)),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _receiptCell(PaymentHistoryItem payment) {
    if (!payment.receiptAvailable) {
      return const Text('—', style: TextStyle(color: AppColors.muted));
    }
    if (_openingReceiptId == payment.id) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      icon: const Icon(Icons.picture_as_pdf, color: AppColors.error),
      onPressed: _openingReceiptId == null ? () => _openReceipt(payment) : null,
      tooltip: '영수증 보기',
    );
  }

  bool _isPaid(String status) {
    return const {
      'paid',
      'succeeded',
      'completed',
    }.contains(status.toLowerCase());
  }

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'paid' || 'succeeded' || 'completed' => '완료',
      'pending' || 'processing' => '대기',
      'failed' || 'canceled' || 'cancelled' => '실패',
      _ => status,
    };
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String _formatAmount(int amount, String currency) {
    final code = currency.toUpperCase();
    if (code == 'KRW') return '₩${_grouped(amount)}';
    if (code == 'JPY') return '¥${_grouped(amount)}';
    // USD/EUR 등은 최소단위(센트) → 통화 코드와 함께 소수 표기.
    return '$code ${(amount / 100).toStringAsFixed(2)}';
  }

  String _grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${value < 0 ? '-' : ''}$buffer';
  }
}
