import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '알림 센터',
      domain: 'NOTIFICATION',
      screenId: 'SCR-W-NOTI-001',
      routeHint: '/notifications',
    );
  }
}

class NotificationPreferenceScreen extends ConsumerWidget {
  const NotificationPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '알림 설정',
      domain: 'NOTIFICATION',
      screenId: 'SCR-W-NOTI-002',
      routeHint: '/notifications/settings',
    );
  }
}
