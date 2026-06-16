import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/providers/notes_providers.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

part 'note_screens/note_list_screen.dart';
part 'note_screens/note_detail_screen.dart';
part 'note_screens/note_editor_screen.dart';
part 'note_screens/note_versions_screen.dart';
part 'note_screens/tag_management_screen.dart';
