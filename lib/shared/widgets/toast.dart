import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

enum ToastType { success, error, info }

abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (icon, color) = switch (type) {
      ToastType.success => (Icons.check_circle, AppColors.success),
      ToastType.error => (Icons.error, AppColors.error),
      ToastType.info => (Icons.info, AppColors.info),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: duration,
        ),
      );
  }
}
