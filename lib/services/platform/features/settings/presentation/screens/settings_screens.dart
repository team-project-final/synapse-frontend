import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '프로필 설정',
      domain: 'SETTINGS',
      screenId: 'SCR-W-SETTINGS-001',
      routeHint: '/settings/profile',
    );
  }
}

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '보안 설정',
      domain: 'SETTINGS',
      screenId: 'SCR-W-SETTINGS-002',
      routeHint: '/settings/security',
    );
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '알림 설정',
      domain: 'SETTINGS',
      screenId: 'SCR-W-SETTINGS-003',
      routeHint: '/settings/notifications',
    );
  }
}

class DataSettingsScreen extends ConsumerWidget {
  const DataSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '데이터 관리',
      domain: 'SETTINGS',
      screenId: 'SCR-W-SETTINGS-004',
      routeHint: '/settings/data',
    );
  }
}

class TenantSettingsScreen extends ConsumerWidget {
  const TenantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '테넌트 관리',
      domain: 'SETTINGS',
      screenId: 'SCR-W-SETTINGS-005',
      routeHint: '/settings/tenant',
    );
  }
}
