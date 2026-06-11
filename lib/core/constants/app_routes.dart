abstract final class AppRoutes {
  static const dashboard = '/';

  static const login = '/login';
  static const signup = '/signup';
  static const mfa = '/mfa';
  static const passwordReset = '/password-reset';
  static const authCallback = '/auth/callback';

  static const notes = '/notes';
  static const noteDetail = '/notes/:noteId';
  static const noteEditor = '/notes/:noteId/edit';
  static const noteVersions = '/notes/:noteId/versions';
  static const tags = '/tags';

  static const decks = '/decks';
  static const deckNew = '/decks/new';
  static const deckCards = '/decks/:deckId/cards';
  static const deckCardNew = '/decks/:deckId/cards/new';
  static const deckCardEdit = '/decks/:deckId/cards/:cardId/edit';
  static const cardNew = '/cards/new';
  static const aiCards = '/ai/cards';
  static const review = '/review';
  static const reviewStart = '/review/start';
  static const reviewResult = '/review/result';

  static const graph = '/graph';
  static const graphNote = '/graph/notes/:noteId';
  static const graphClusters = '/graph/clusters';

  static const search = '/search';
  static const qa = '/qa';

  static const billingPlans = '/billing/plans';
  static const billingHistory = '/billing/history';
  static const billingSuccess = '/billing/success';
  static const billingCancel = '/billing/cancel';

  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';
  static const settingsSecurity = '/settings/security';
  static const settingsNotifications = '/settings/notifications';
  static const settingsTenant = '/settings/tenant';

  static const admin = '/admin';
  static const adminTenants = '/admin/tenants';
  static const adminUsers = '/admin/users';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminSettings = '/admin/settings';
  static const adminReports = '/admin/reports';
  static const adminContent = '/admin/content';
  static const adminGroups = '/admin/groups';
  static const adminGamification = '/admin/gamification';
  static const adminDataRequests = '/admin/data-requests';

  static const dashboardHeatmap = '/dashboard/heatmap';
  static const dashboardStats = '/dashboard/stats';

  static const planner = '/planner';

  static const communityGroups = '/community/groups';
  static const communityGroupDetail = '/community/groups/:groupId';
  static const communityGroupNew = '/community/groups/new';
  static const communitySharedDecks = '/community/shared-decks';
  static const communitySharedDeckDetail = '/community/shared-decks/:deckId';
  static const communitySharedNotes = '/community/shared-notes';
  static const communitySharedNoteDetail = '/community/shared-notes/:noteId';

  static const gamificationProfile = '/gamification/profile';
  static const gamificationBadges = '/gamification/badges';
  static const gamificationLeaderboard = '/gamification/leaderboard';
  static const gamificationXpHistory = '/gamification/xp-history';

  static const notifications = '/notifications';
  static const notificationSettings = '/notifications/settings';

  static String noteDetailPath(String noteId) => '/notes/$noteId';
  static String noteEditorPath(String noteId) => '/notes/$noteId/edit';
  static String noteVersionsPath(String noteId) => '/notes/$noteId/versions';
  static String deckCardsPath(String deckId) => '/decks/$deckId/cards';
  static String deckCardNewPath(String deckId) => '/decks/$deckId/cards/new';
  static String deckCardEditPath(String deckId, String cardId) => '/decks/$deckId/cards/$cardId/edit';
  static String graphNotePath(String noteId) => '/graph/notes/$noteId';
  static String communityGroupDetailPath(String groupId) =>
      '/community/groups/$groupId';
  static String communitySharedDeckDetailPath(String deckId) =>
      '/community/shared-decks/$deckId';
  static String communitySharedNoteDetailPath(String noteId) =>
      '/community/shared-notes/$noteId';
}
