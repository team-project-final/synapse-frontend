import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';

class FakeEngagementApi extends EngagementApi {
  FakeEngagementApi() : super(Dio());

  final forkedTokens = <String>[];
  final createdReports = <String>[];
  final moderatedReports = <String>[];

  @override
  Future<GamificationProfile> getGamificationProfile() async {
    return GamificationProfile(
      xp: 1240,
      level: 5,
      currentStreak: 4,
      longestStreak: 9,
      badges: [
        GamificationBadge(
          code: 'FIRST_XP',
          name: 'First XP',
          description: 'Earn XP for the first time',
          conditionType: 'TOTAL_XP',
          conditionValue: 1,
          earnedAt: DateTime.utc(2026, 6, 22, 1),
        ),
        GamificationBadge(
          code: 'LEVEL_2',
          name: 'Level 2',
          description: 'Reach level 2',
          conditionType: 'LEVEL',
          conditionValue: 2,
          earnedAt: DateTime.utc(2026, 6, 22, 2),
        ),
      ],
    );
  }

  @override
  Future<List<XpEvent>> getXpHistory() async {
    return [
      XpEvent(
        eventType: 'REVIEW_COMPLETED',
        xpAmount: 30,
        sourceId: 'review-1',
        sourceType: 'review',
        eventId: 'evt-review-1',
        createdAt: DateTime.now().toUtc(),
      ),
      XpEvent(
        eventType: 'NOTE_CREATED',
        xpAmount: 10,
        sourceId: 'note-1',
        sourceType: 'note',
        eventId: 'evt-note-1',
        createdAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<GamificationBadge>> getBadges() async {
    return [
      const GamificationBadge(
        code: 'FIRST_XP',
        name: 'First XP',
        description: 'Earn XP for the first time',
        conditionType: 'TOTAL_XP',
        conditionValue: 1,
      ),
      const GamificationBadge(
        code: 'LEVEL_2',
        name: 'Level 2',
        description: 'Reach level 2',
        conditionType: 'LEVEL',
        conditionValue: 2,
      ),
      const GamificationBadge(
        code: 'STREAK_3',
        name: '3 Day Streak',
        description: 'Keep a 3 day activity streak',
        conditionType: 'STREAK',
        conditionValue: 3,
      ),
    ];
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'all',
    int limit = 20,
  }) async {
    return const [
      LeaderboardEntry(
        rank: 1,
        userId: '100',
        nickname: '김시냅스',
        xp: 1240,
        level: 5,
      ),
      LeaderboardEntry(
        rank: 2,
        userId: '101',
        nickname: '이러닝',
        xp: 980,
        level: 4,
      ),
    ];
  }

  @override
  Future<List<SharedContent>> searchSharedContent({
    String? query,
    String? contentType,
  }) async {
    final items = [
      SharedContent(
        id: '11',
        shareToken: 'deck-token-1',
        contentType: 'DECK',
        contentId: '101',
        ownerId: '7',
        title: '알고리즘 기초 100제',
        description: '시간복잡도와 자료구조 복습용 공유 덱입니다.',
        tags: const ['알고리즘', '자료구조'],
        downloadCount: 234,
        createdAt: DateTime.utc(2026, 6, 21, 5),
      ),
      SharedContent(
        id: '12',
        shareToken: 'note-token-1',
        contentType: 'NOTE',
        contentId: '201',
        ownerId: '8',
        title: '정규화 기법 완전 정리',
        description: 'L1/L2 정규화와 dropout을 비교합니다.',
        tags: const ['머신러닝', '딥러닝'],
        downloadCount: 89,
        createdAt: DateTime.utc(2026, 6, 20, 8),
      ),
    ].where((item) => contentType == null || item.contentType == contentType);
    final keyword = query?.trim();
    if (keyword == null || keyword.isEmpty) {
      return items.toList(growable: false);
    }
    return items
        .where((item) => item.title.contains(keyword))
        .toList(growable: false);
  }

  @override
  Future<List<CommunityGroup>> getGroups({int page = 0, int size = 20}) async {
    return [
      CommunityGroup(
        id: '1',
        name: 'AWS 자격증 스터디',
        description: '클라우드 자격증 준비를 위한 그룹입니다.',
        isPublic: false,
        ownerId: '100',
        createdAt: DateTime.utc(2026, 6, 21, 5),
      ),
      CommunityGroup(
        id: '2',
        name: '알고리즘 마스터즈',
        description: '자료구조와 알고리즘 문제 풀이 그룹입니다.',
        isPublic: true,
        ownerId: '101',
        createdAt: DateTime.utc(2026, 6, 20, 5),
      ),
    ];
  }

  @override
  Future<CommunityGroup> getGroup(String groupId) async {
    return (await getGroups()).firstWhere(
      (group) => group.id == groupId,
      orElse: () => CommunityGroup(
        id: groupId,
        name: '테스트 그룹',
        description: '테스트 그룹 설명',
        isPublic: true,
        ownerId: '100',
        createdAt: DateTime.utc(2026, 6, 21, 5),
      ),
    );
  }

  @override
  Future<List<CommunityGroupMember>> getGroupMembers(String groupId) async {
    return [
      CommunityGroupMember(
        id: '500',
        groupId: groupId,
        userId: '100',
        role: 'OWNER',
        status: 'ACTIVE',
        joinedAt: DateTime.utc(2026, 6, 21, 5),
      ),
      CommunityGroupMember(
        id: '501',
        groupId: groupId,
        userId: '102',
        role: 'MEMBER',
        status: 'ACTIVE',
        joinedAt: DateTime.utc(2026, 6, 22, 2),
      ),
    ];
  }

  @override
  Future<CommunityGroupMember> joinGroup(String groupId) async {
    return CommunityGroupMember(
      id: '502',
      groupId: groupId,
      userId: '103',
      role: 'MEMBER',
      status: groupId == '1' ? 'PENDING' : 'ACTIVE',
      joinedAt: DateTime.utc(2026, 6, 22, 4),
    );
  }

  @override
  Future<SharedContent> getSharedContent(String token) async {
    if (token.contains('note')) {
      return SharedContent(
        id: '12',
        shareToken: token,
        contentType: 'NOTE',
        contentId: '201',
        ownerId: '8',
        title: '정규화 기법 완전 정리',
        description: 'L1/L2 정규화와 dropout을 비교합니다.',
        tags: const ['머신러닝', '딥러닝'],
        downloadCount: 89,
        createdAt: DateTime.utc(2026, 6, 20, 8),
      );
    }
    return SharedContent(
      id: '11',
      shareToken: token,
      contentType: 'DECK',
      contentId: '101',
      ownerId: '7',
      title: '알고리즘 기초 100제',
      description: '시간복잡도와 자료구조 복습용 공유 덱입니다.',
      tags: const ['알고리즘', '자료구조'],
      downloadCount: 234,
      createdAt: DateTime.utc(2026, 6, 21, 5),
    );
  }

  @override
  Future<SharedContent> forkSharedContent(String token) async {
    forkedTokens.add(token);
    return getSharedContent(token);
  }

  @override
  Future<EngagementReport> createReport({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    createdReports.add('$targetType:$targetId');
    return EngagementReport(
      id: '900',
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      status: 'PENDING',
      createdAt: DateTime.utc(2026, 6, 22, 3),
    );
  }

  @override
  Future<List<EngagementReport>> getReports({String status = 'PENDING'}) async {
    return [
      EngagementReport(
        id: '501',
        targetType: 'SHARED_DECK',
        targetId: '11',
        reason: '스팸',
        status: status,
        createdAt: DateTime.utc(2026, 6, 22, 3),
      ),
    ];
  }

  @override
  Future<EngagementReport> moderateReport({
    required String reportId,
    required String status,
    String? adminNote,
  }) async {
    moderatedReports.add('$reportId:$status');
    return EngagementReport(
      id: reportId,
      targetType: 'SHARED_DECK',
      targetId: '11',
      reason: '스팸',
      status: status,
      adminNote: adminNote,
      createdAt: DateTime.utc(2026, 6, 22, 3),
      resolvedAt: DateTime.utc(2026, 6, 22, 4),
    );
  }
}
