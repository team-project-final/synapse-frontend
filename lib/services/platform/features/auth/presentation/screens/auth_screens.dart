import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/widgets/login_intro_overlay.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

part 'auth_screens/login_screen.dart';
part 'auth_screens/signup_screen.dart';
part 'auth_screens/mfa_screen.dart';
part 'auth_screens/password_reset_screen.dart';
