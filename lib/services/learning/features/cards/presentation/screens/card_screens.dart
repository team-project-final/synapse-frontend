import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/learning/features/ai/domain/entities/generated_card.dart';
import 'package:synapse_frontend/services/learning/features/ai/providers/ai_providers.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/providers/cards_providers.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/flip_card.dart';
import 'package:synapse_frontend/shared/widgets/share_dialog.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

part 'card_screens/_mock.dart';
part 'card_screens/deck_list_screen.dart';
part 'card_screens/deck_create_screen.dart';
part 'card_screens/card_list_screen.dart';
part 'card_screens/card_editor_screen.dart';
part 'card_screens/ai_card_generation_screen.dart';
part 'card_screens/review_start_screen.dart';
part 'card_screens/review_screen.dart';
part 'card_screens/review_result_screen.dart';
