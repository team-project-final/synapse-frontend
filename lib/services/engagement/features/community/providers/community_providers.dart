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
