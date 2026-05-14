import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '관리자',
      domain: 'ADMIN',
      screenId: 'SCR-W-ADMIN-001',
      routeHint: '/admin',
    );
  }
}
