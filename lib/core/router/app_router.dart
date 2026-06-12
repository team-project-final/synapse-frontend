import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
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
import 'package:synapse_frontend/services/platform/features/auth/presentation/widgets/login_intro_overlay.dart';
import 'package:synapse_frontend/services/platform/features/billing/presentation/screens/billing_screens.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:synapse_frontend/shared/widgets/admin_shell.dart';
import 'package:synapse_frontend/shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // 규칙 7.3.2: Provider<GoRouter>에서 auth를 watch해 라우터를 재생성한다.
  // 깜빡임(재생성 시 initialLocation=대시보드에서 시작)은 아래 loading 가드로 막는다.
  final authState = ref.watch(authNotifierProvider);
  // 로그인 인트로가 화면을 덮는(covering) 동안엔 인증이 끝나도 전환을 보류한다.
  // 재생이 끝나 revealing 으로 바뀌는 순간 라우터가 재생성되며 대시보드로
  // 전환되고, 인트로 축소 연출이 그 위에서 화면을 공개한다.
  final introCovering =
      ref.watch(loginIntroProvider)?.phase == LoginIntroPhase.covering;

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      // mfa는 로그인 후 추가 검증 화면이라 entry route가 아니다
      // (백엔드 /auth/mfa/*가 인증을 요구).
      const authEntryRoutes = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.passwordReset,
        AppRoutes.authCallback,
      ];
      const publicRoutes = [
        ...authEntryRoutes,
        AppRoutes.billingSuccess,
        AppRoutes.billingCancel,
      ];
      final isAuthEntryRoute = authEntryRoutes.contains(state.matchedLocation);
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // 인증 진행 중(loading/초기화)에는 보호 화면을 띄우지 않는다.
      // 라우터 재생성이 대시보드(initialLocation)에서 시작해도 여기서 로그인으로
      // 보내, 로그인 처리 중 보호 화면이 잠깐 비치는 깜빡임을 막는다.
      if (authState.status == AuthStatus.initializing ||
          authState.status == AuthStatus.loading) {
        return isPublicRoute ? null : AppRoutes.login;
      }

      if (authState.status == AuthStatus.unauthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }
      // 인트로가 덮는(covering) 동안엔 인증이 끝나도 로그인에 머문다 —
      // 라우터 재생성이 initialLocation(대시보드)에서 시작해도 강제로 로그인
      // 유지해 "재생 완료 후 전환" 순서를 보장한다.
      if (authState.status == AuthStatus.authenticated && introCovering) {
        return state.matchedLocation == AppRoutes.login
            ? null
            : AppRoutes.login;
      }
      // 인증 상태로 auth 진입 화면에 있으면 대시보드로.
      if (authState.status == AuthStatus.authenticated && isAuthEntryRoute) {
        return AppRoutes.dashboard;
      }
      // admin 영역은 ROLE_ADMIN만 접근 — 비관리자는 대시보드로.
      // ('/admin' 정확히 또는 '/admin/...' 하위만. startsWith('/admin')은
      //  '/administrators' 같은 경로까지 잡으므로 정밀하게 매칭한다.)
      final location = state.matchedLocation;
      final isAdminArea = location == AppRoutes.admin ||
          location.startsWith('${AppRoutes.admin}/');
      if (authState.status == AuthStatus.authenticated &&
          isAdminArea &&
          !authState.isAdmin) {
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
            path: AppRoutes.deckCardNew,
            builder: (context, state) =>
                CardEditorScreen(deckId: state.pathParameters['deckId']),
          ),
          GoRoute(
            path: AppRoutes.deckCardEdit,
            builder: (context, state) => CardEditorScreen(
              deckId: state.pathParameters['deckId'],
              cardId: state.pathParameters['cardId'],
            ),
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
            path: AppRoutes.reviewStart,
            builder: (context, state) => const ReviewStartScreen(),
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
            path: AppRoutes.billingHistory,
            builder: (context, state) => const BillingHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsHubScreen(),
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
            // 설정 허브의 알림 메뉴도 실연동된 알림 설정 화면을 재사용한다.
            builder: (context, state) => const NotificationPreferenceScreen(),
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
            builder: (context, state) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: CommunityGroupDetailScreen(
                  groupId: state.pathParameters['groupId'] ?? '',
                ),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.communitySharedDecks,
            builder: (context, state) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: const SharedDecksScreen(),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.communitySharedDeckDetail,
            builder: (context, state) => SharedDeckDetailScreen(
              deckId: state.pathParameters['deckId'] ?? '',
              sharedContentId: state.uri.queryParameters['sharedContentId'],
              shareToken: state.uri.queryParameters['shareToken'],
            ),
          ),
          GoRoute(
            path: AppRoutes.communitySharedNotes,
            builder: (context, state) => const SharedNotesScreen(),
          ),
          GoRoute(
            path: AppRoutes.communitySharedNoteDetail,
            builder: (context, state) => SharedNoteDetailScreen(
              noteId: state.pathParameters['noteId'] ?? '',
            ),
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
            path: AppRoutes.gamificationXpHistory,
            builder: (context, state) => const XpHistoryScreen(),
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
