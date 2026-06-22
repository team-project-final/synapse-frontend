import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/admin_api.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';
import 'package:synapse_frontend/shared/widgets/admin_data_grid.dart';
import 'package:synapse_frontend/shared/widgets/confirm_dialog.dart';

part 'admin_screens/_widgets.dart';
part 'admin_screens/admin_dashboard_screen.dart';
part 'admin_screens/admin_tenant_screen.dart';
part 'admin_screens/admin_user_screen.dart';
part 'admin_screens/admin_audit_log_screen.dart';
part 'admin_screens/admin_system_settings_screen.dart';
part 'admin_screens/admin_report_screen.dart';
part 'admin_screens/admin_content_screen.dart';
part 'admin_screens/admin_group_screen.dart';
part 'admin_screens/admin_gamification_screen.dart';
part 'admin_screens/admin_data_request_screen.dart';
