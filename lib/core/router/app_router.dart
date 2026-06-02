import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/engagement/features/community/presentation/screens/community_screens.dart';
import 'package:synapse_frontend/services/engagement/features/gamification/presentation/screens/gamification_screens.dart';
import 'package:synapse_frontend/services/knowledge/features/graph/presentation/screens/graph_screens.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/presentation/screens/note_screens.dart';
import 'package:synapse_frontend/services/knowledge/features/search/presentation/screens/search_screens.dart';
import 'package:synapse_frontend/services/learning/features/cards/presentation/screens/card_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/oauth_callback_screen.dart';
import 'package:synapse_frontend/services/platform/features/billing/presentation/screens/billing_screens.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:synapse_frontend/shared/widgets/admin_shell.dart';
import 'package:synapse_frontend/shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      const authEntryRoutes = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.mfa,
        AppRoutes.passwordReset,
        AppRoutes.oauthConsent,
        AppRoutes.authCallback,
      ];
      const publicRoutes = [
        ...authEntryRoutes,
        AppRoutes.billingSuccess,
        AppRoutes.billingCancel,
      ];
      final isAuthEntryRoute = authEntryRoutes.contains(state.matchedLocation);
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (authState.status == AuthStatus.initializing ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }
      if (authState.status == AuthStatus.authenticated && isAuthEntryRoute) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      // ── Auth routes (outside shell) ──
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.mfa,
        builder: (context, state) => const MfaScreen(),
      ),
      GoRoute(
        path: AppRoutes.passwordReset,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: AppRoutes.oauthConsent,
        builder: (context, state) => const OAuthConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        builder: (context, state) => OAuthCallbackScreen(
          accessToken: state.uri.queryParameters['access_token'],
          error: state.uri.queryParameters['error'],
        ),
      ),
      GoRoute(
        path: AppRoutes.billingSuccess,
        builder: (context, state) => const BillingReturnScreen(success: true),
      ),
      GoRoute(
        path: AppRoutes.billingCancel,
        builder: (context, state) => const BillingReturnScreen(success: false),
      ),

      // ── Shell routes (with SideNav + AppBar) ──
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboardHeatmap,
            builder: (context, state) => const DashboardHeatmapScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboardStats,
            builder: (context, state) => const DashboardStatsScreen(),
          ),
          GoRoute(
            path: AppRoutes.planner,
            builder: (context, state) => const PlannerScreen(),
          ),
          GoRoute(
            path: AppRoutes.notes,
            builder: (context, state) => const NoteListScreen(),
          ),
          GoRoute(
            path: AppRoutes.noteDetail,
            builder: (context, state) =>
                NoteDetailScreen(noteId: state.pathParameters['noteId'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.noteEditor,
            builder: (context, state) =>
                NoteEditorScreen(noteId: state.pathParameters['noteId'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.noteVersions,
            builder: (context, state) => NoteVersionsScreen(
              noteId: state.pathParameters['noteId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.tags,
            builder: (context, state) => const TagManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.decks,
            builder: (context, state) => const DeckListScreen(),
          ),
          GoRoute(
            path: AppRoutes.deckNew,
            builder: (context, state) => const DeckCreateScreen(),
          ),
          GoRoute(
            path: AppRoutes.deckCards,
            builder: (context, state) =>
                CardListScreen(deckId: state.pathParameters['deckId'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.cardNew,
            builder: (context, state) => const CardEditorScreen(),
          ),
          GoRoute(
            path: AppRoutes.aiCards,
            builder: (context, state) => const AiCardGenerationScreen(),
          ),
          GoRoute(
            path: AppRoutes.review,
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.reviewResult,
            builder: (context, state) => const ReviewResultScreen(),
          ),
          GoRoute(
            path: AppRoutes.graph,
            builder: (context, state) => const GraphViewScreen(),
          ),
          GoRoute(
            path: AppRoutes.graphNote,
            builder: (context, state) =>
                GraphNoteScreen(noteId: state.pathParameters['noteId'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.graphClusters,
            builder: (context, state) => const GraphClustersScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.qa,
            builder: (context, state) => const AiQaScreen(),
          ),
          GoRoute(
            path: AppRoutes.billingPlans,
            builder: (context, state) => const BillingPlansScreen(),
          ),
          GoRoute(
            path: AppRoutes.billingUsage,
            builder: (context, state) => const BillingUsageScreen(),
          ),
          GoRoute(
            path: AppRoutes.billingHistory,
            builder: (context, state) => const BillingHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsProfile,
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsSecurity,
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsNotifications,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsData,
            builder: (context, state) => const DataSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsTenant,
            builder: (context, state) => const TenantSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.communityGroups,
            builder: (context, state) => const CommunityGroupsScreen(),
          ),
          GoRoute(
            path: AppRoutes.communityGroupNew,
            builder: (context, state) => const CommunityGroupEditorScreen(),
          ),
          GoRoute(
            path: AppRoutes.communityGroupDetail,
            builder: (context, state) => CommunityGroupDetailScreen(
              groupId: state.pathParameters['groupId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.communitySharedDecks,
            builder: (context, state) => const SharedDecksScreen(),
          ),
          GoRoute(
            path: AppRoutes.communitySharedDeckDetail,
            builder: (context, state) => SharedDeckDetailScreen(
              deckId: state.pathParameters['deckId'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.communitySharedNotes,
            builder: (context, state) => const SharedNotesScreen(),
          ),
          GoRoute(
            path: AppRoutes.gamificationProfile,
            builder: (context, state) => const GamificationProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.gamificationBadges,
            builder: (context, state) => const BadgeGalleryScreen(),
          ),
          GoRoute(
            path: AppRoutes.gamificationLeaderboard,
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: AppRoutes.notificationSettings,
            builder: (context, state) => const NotificationPreferenceScreen(),
          ),
        ],
      ),

      // ── Admin routes (with AdminShell) ── Web only
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.admin,
            redirect: (context, state) => kIsWeb ? null : AppRoutes.dashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminTenants,
            builder: (context, state) => const AdminTenantScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            builder: (context, state) => const AdminUserScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminAuditLogs,
            builder: (context, state) => const AdminAuditLogScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminSettings,
            builder: (context, state) => const AdminSystemSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminReports,
            builder: (context, state) => const AdminReportScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminContent,
            builder: (context, state) => const AdminContentScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminGroups,
            builder: (context, state) => const AdminGroupScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminGamification,
            builder: (context, state) => const AdminGamificationScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminDataRequests,
            builder: (context, state) => const AdminDataRequestScreen(),
          ),
        ],
      ),
    ],
  );
});
