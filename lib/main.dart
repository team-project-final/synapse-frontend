import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/app.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryPortProvider.overrideWith(
          (ref) => ref.watch(authRepositoryProvider),
        ),
      ],
      child: const SynapseApp(),
    ),
  );
}
