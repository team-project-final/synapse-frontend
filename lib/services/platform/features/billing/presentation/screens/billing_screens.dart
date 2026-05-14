import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class BillingPlansScreen extends ConsumerWidget {
  const BillingPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '플랜 비교',
      domain: 'BILLING',
      screenId: 'SCR-W-BILLING-001',
      routeHint: '/billing/plans',
    );
  }
}

class BillingUsageScreen extends ConsumerWidget {
  const BillingUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '사용량 현황',
      domain: 'BILLING',
      screenId: 'SCR-W-BILLING-002',
      routeHint: '/billing/usage',
    );
  }
}

class BillingHistoryScreen extends ConsumerWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '결제 이력',
      domain: 'BILLING',
      screenId: 'SCR-W-BILLING-003',
      routeHint: '/billing/history',
    );
  }
}
