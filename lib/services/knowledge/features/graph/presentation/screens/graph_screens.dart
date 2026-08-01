import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/knowledge/data/knowledge_api.dart';
import 'package:synapse_frontend/services/knowledge/providers/knowledge_providers.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';

part 'graph_screens/_painters.dart';
part 'graph_screens/graph_view_screen.dart';
part 'graph_screens/graph_note_screen.dart';
part 'graph_screens/graph_clusters_screen.dart';
