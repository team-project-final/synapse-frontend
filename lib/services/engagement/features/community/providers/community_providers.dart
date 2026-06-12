import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/engagement/features/community/data/community_api.dart';

// 화면은 직접 Dio를 알지 않고 provider만 구독한다.
// Riverpod이 요청 상태를 AsyncValue로 감싸서 loading/error/data 분기를 화면에 전달한다.
final communityGroupsProvider = FutureProvider<List<CommunityGroup>>((ref) {
  return ref.watch(communityApiProvider).getGroups();
});

// family provider는 groupId 같은 입력값별로 캐시가 나뉜다.
// 같은 그룹 상세 화면으로 다시 들어오면 동일한 요청 결과를 재사용할 수 있다.
final communityGroupProvider =
    FutureProvider.family<CommunityGroup, String>((ref, groupId) {
  return ref.watch(communityApiProvider).getGroup(groupId);
});

final communityGroupMembersProvider =
    FutureProvider.family<List<GroupMember>, String>((ref, groupId) {
  return ref.watch(communityApiProvider).getMembers(groupId);
});

final communityGroupMemberCountProvider =
    FutureProvider.family<int, String>((ref, groupId) async {
  final members = await ref.watch(communityGroupMembersProvider(groupId).future);
  // GroupResponse에는 memberCount가 없으므로 멤버 목록에서 ACTIVE 상태만 세어 표시한다.
  return members.where((member) => member.status == 'ACTIVE').length;
});

final sharedContentsProvider =
    FutureProvider.family<List<SharedContent>, SharedContentQuery>((
  ref,
  query,
) {
  return ref.watch(communityApiProvider).searchSharedContent(
        query: query.query,
        contentType: query.contentType,
      );
});

final sharedContentProvider =
    FutureProvider.family<SharedContent, String>((ref, token) {
  return ref.watch(communityApiProvider).getSharedContent(token);
});

// 공유 덱 상세는 engagement의 공유글 정보만으로는 부족하다.
// contentId/shareToken/sharedContentId를 묶어 learning-svc에서 실제 카드 내용을 가져온다.
final sharedDeckDetailProvider =
    FutureProvider.family<SharedDeckDetail, SharedDeckDetailQuery>((
  ref,
  query,
) {
  return ref.watch(communityLearningDeckApiProvider).getSharedDeckDetail(
        deckId: query.deckId,
        sharedContentId: query.sharedContentId,
        shareToken: query.shareToken,
      );
});

final communityReportsProvider =
    FutureProvider.family<List<CommunityReport>, ReportStatus>((ref, status) {
  return ref.watch(communityApiProvider).getReports(status: status);
});

// 검색어와 콘텐츠 타입을 하나의 key로 묶어서 Riverpod family 캐시의 기준으로 사용한다.
// 값 객체가 같으면 같은 검색 조건으로 보고 같은 provider 상태를 공유한다.
class SharedContentQuery {
  const SharedContentQuery({this.query, this.contentType});

  final String? query;
  final SharedContentType? contentType;

  @override
  bool operator ==(Object other) {
    return other is SharedContentQuery &&
        other.query == query &&
        other.contentType == contentType;
  }

  @override
  int get hashCode => Object.hash(query, contentType);
}

// Riverpod family 캐시는 입력 객체의 ==/hashCode를 기준으로 나뉜다.
// 세 값을 하나로 묶어야 같은 공유 덱 상세 요청을 같은 캐시로 재사용할 수 있다.
class SharedDeckDetailQuery {
  const SharedDeckDetailQuery({
    required this.deckId,
    required this.sharedContentId,
    required this.shareToken,
  });

  final String deckId;
  final String sharedContentId;
  final String shareToken;

  @override
  bool operator ==(Object other) {
    return other is SharedDeckDetailQuery &&
        other.deckId == deckId &&
        other.sharedContentId == sharedContentId &&
        other.shareToken == shareToken;
  }

  @override
  int get hashCode => Object.hash(deckId, sharedContentId, shareToken);
}
