import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/confirm_dialog.dart';

part 'settings_screens/_widgets.dart';
part 'settings_screens/settings_hub_screen.dart';
part 'settings_screens/profile_settings_screen.dart';
part 'settings_screens/security_settings_screen.dart';
part 'settings_screens/notification_settings_screen.dart';
part 'settings_screens/tenant_settings_screen.dart';
