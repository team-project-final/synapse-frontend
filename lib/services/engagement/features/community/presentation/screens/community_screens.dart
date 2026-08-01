import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/report_dialog.dart';
import 'package:synapse_frontend/shared/widgets/study_board_kit.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

part 'community_screens/group_list_screen.dart';
part 'community_screens/group_detail_screen.dart';
part 'community_screens/group_editor_screen.dart';
part 'community_screens/shared_decks_screen.dart';
part 'community_screens/shared_deck_detail_screen.dart';
part 'community_screens/shared_notes_screen.dart';
part 'community_screens/shared_note_detail_screen.dart';

String _formatCount(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}
