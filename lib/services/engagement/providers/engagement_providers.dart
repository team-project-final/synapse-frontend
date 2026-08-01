import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';

final engagementApiProvider = Provider<EngagementApi>((ref) {
  return EngagementApi(ref.watch(dioProvider));
});

final gamificationProfileProvider =
    FutureProvider.autoDispose<GamificationProfile>((ref) {
      return ref.watch(engagementApiProvider).getGamificationProfile();
    });

final gamificationBadgeGalleryProvider =
    FutureProvider.autoDispose<List<GamificationBadge>>((ref) async {
      final api = ref.watch(engagementApiProvider);
      final allBadges = await api.getBadges();
      final profile = await api.getGamificationProfile();
      final earnedByCode = {
        for (final badge in profile.badges) badge.code: badge.earnedAt,
      };
      return allBadges
          .map((badge) => badge.copyWithEarnedAt(earnedByCode[badge.code]))
          .toList(growable: false);
    });

final xpHistoryProvider = FutureProvider.autoDispose<List<XpEvent>>((ref) {
  return ref.watch(engagementApiProvider).getXpHistory();
});

final leaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, LeaderboardQuery>((ref, query) {
      return ref
          .watch(engagementApiProvider)
          .getLeaderboard(period: query.period, limit: query.limit);
    });

final sharedContentSearchProvider = FutureProvider.autoDispose
    .family<List<SharedContent>, SharedContentQuery>((ref, query) async {
      final items = await ref
          .watch(engagementApiProvider)
          .searchSharedContent(
            query: query.searchText,
            contentType: query.contentType,
          );
      final sorted = [...items];
      switch (query.sortOrder) {
        case SharedContentSort.popular:
          sorted.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
        case SharedContentSort.recent:
        case SharedContentSort.all:
          sorted.sort((a, b) {
            final left = a.createdAt;
            final right = b.createdAt;
            if (left == null && right == null) return 0;
            if (left == null) return 1;
            if (right == null) return -1;
            return right.compareTo(left);
          });
      }
      return sorted;
    });

final sharedContentDetailProvider = FutureProvider.autoDispose
    .family<SharedContent, String>((ref, token) {
      return ref.watch(engagementApiProvider).getSharedContent(token);
    });

final adminReportsProvider = FutureProvider.autoDispose
    .family<List<EngagementReport>, String>((ref, status) {
      return ref.watch(engagementApiProvider).getReports(status: status);
    });

final communityGroupsProvider =
    FutureProvider.autoDispose<List<CommunityGroup>>((ref) {
      return ref.watch(engagementApiProvider).getGroups();
    });

final communityGroupDetailProvider = FutureProvider.autoDispose
    .family<CommunityGroupDetail, String>((ref, groupId) async {
      final api = ref.watch(engagementApiProvider);
      final group = await api.getGroup(groupId);
      final members = await api.getGroupMembers(groupId);
      return CommunityGroupDetail(group: group, members: members);
    });

class CommunityGroupDetail {
  const CommunityGroupDetail({required this.group, required this.members});

  final CommunityGroup group;
  final List<CommunityGroupMember> members;

  int get activeMemberCount => members.where((member) => member.active).length;
}

class LeaderboardQuery {
  const LeaderboardQuery({this.period = 'all', this.limit = 20});

  final String period;
  final int limit;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LeaderboardQuery &&
            other.period == period &&
            other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(period, limit);
}

class SharedContentQuery {
  const SharedContentQuery({
    required this.contentType,
    this.searchText = '',
    this.sortOrder = SharedContentSort.recent,
  });

  final String contentType;
  final String searchText;
  final SharedContentSort sortOrder;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SharedContentQuery &&
            other.contentType == contentType &&
            other.searchText == searchText &&
            other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(contentType, searchText, sortOrder);
}

enum SharedContentSort {
  all(label: '전체'),
  recent(label: '최근'),
  popular(label: '인기');

  const SharedContentSort({required this.label});

  final String label;
}
