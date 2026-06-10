import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/app.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';
import 'package:synapse_frontend/services/platform/features/notifications/providers/unread_notification_count_provider.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryPortProvider.overrideWith(
          (ref) => ref.watch(authRepositoryProvider),
        ),
        // 미읽음 알림 뱃지 폴링은 실제 앱에서만 켠다(테스트 기본값은 꺼짐).
        unreadNotificationPollIntervalProvider.overrideWithValue(
          const Duration(seconds: 30),
        ),
      ],
      child: const SynapseApp(),
    ),
  );
}
