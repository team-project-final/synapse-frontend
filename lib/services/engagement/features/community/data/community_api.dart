import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final communityApiProvider = Provider<CommunityApi>((ref) {
  final environment = ref.watch(environmentProvider);
  return CommunityApi(
    ref.watch(dioProvider),
    ref.watch(tokenStoreProvider),
    environment.communityApiPrefix,
    enableLocalFallback: environment == AppEnvironment.dev,
  );
});

// community 화면이 공유 덱을 보여줄 때 engagement에는 공유 메타데이터만 있고,
// 실제 카드 내용/복사 로직은 learning-svc에 있으므로 learning 전용 Dio를 따로 사용한다.
final communityLearningDeckApiProvider = Provider<CommunityLearningDeckApi>((ref) {
  return CommunityLearningDeckApi(ref.watch(learningDioProvider));
});

// 로컬 k8s 가이드 기준으로 일반 환경은 Gateway의 engagement 라우트를 타고,
// platform-dev만 engagement 서비스에 직접 붙도록 API prefix를 분리한다.
extension CommunityApiPrefix on AppEnvironment {
  String get communityApiPrefix {
    return switch (this) {
      AppEnvironment.dev ||
      AppEnvironment.staging ||
      AppEnvironment.prod => '/api/engagement/api/v1',
      AppEnvironment.platformDev => '/api/v1',
    };
  }
}

class CommunityLearningDeckApi {
  const CommunityLearningDeckApi(this._dio);

  final Dio _dio;

  Future<SharedDeckDetail> getSharedDeckDetail({
    required String deckId,
    required String sharedContentId,
    required String shareToken,
  }) async {
    // contentId(deckId)는 learning의 원본 덱을 찾는 값이고,
    // sharedContentId/shareToken은 engagement에 등록된 공유글이 맞는지 검증하는 값이다.
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/shared-detail',
      queryParameters: {
        'sharedContentId': sharedContentId,
        'shareToken': shareToken,
      },
    );
    return SharedDeckDetail.fromJson(_unwrapData(response.data));
  }

  Future<SharedDeckCopyResult> copyFromShare({
    required String deckId,
    required String sharedContentId,
    required String shareToken,
  }) async {
    // 실제 덱/카드 복제는 learning-svc가 소유한다.
    // sharedContentId/shareToken을 함께 보내 임의 deckId 복사를 막고 공유글 검증을 맞춘다.
    // engagement의 fork는 복제 이후 다운로드 수와 공유 메타데이터를 갱신하는 단계다.
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks/$deckId/copy-from-share',
      data: {
        'sharedContentId': sharedContentId,
        'shareToken': shareToken,
      },
    );
    return SharedDeckCopyResult.fromJson(_unwrapData(response.data));
  }

  Future<DeckShareableStatus> getShareableStatus(String deckId) async {
    // 공유 생성 전에 learning이 덱 소유권/공유 가능 상태를 확인할 수 있도록 준비한 API다.
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/shareable',
    );
    return DeckShareableStatus.fromJson(_unwrapData(response.data));
  }
}

class CommunityApi {
  CommunityApi(
    this._dio,
    this._tokenStore,
    this._prefix, {
    this.enableLocalFallback = false,
  }) : _localGroups = _initialLocalGroups();

  final Dio _dio;
  final TokenStore _tokenStore;
  final String _prefix;
  final bool enableLocalFallback;
  final List<CommunityGroup> _localGroups;
  final Set<String> _joinedGroupIds = <String>{};
  final List<CommunityReport> _localReports = <CommunityReport>[];

  // Dio 인스턴스는 공통 네트워크 설정, 인증 헤더, 에러 처리를 공유하고,
  // 이 클래스는 community 도메인의 endpoint와 응답 모델 변환만 담당한다.
  Future<List<CommunityGroup>> getGroups({int page = 0, int size = 50}) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localGroupsWithJoinState();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/community/groups',
        queryParameters: {'page': page, 'size': size},
      );
      return _decodeList(response.data, CommunityGroup.fromJson)
          .map(
            (group) => group.copyWith(
              joined: _joinedGroupIds.contains(group.id),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localGroupsWithJoinState();
      }
      rethrow;
    }
  }

  Future<CommunityGroup> getGroup(String groupId) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      final localGroup = _findLocalGroup(groupId);
      if (localGroup != null) {
        return localGroup.copyWith(joined: _joinedGroupIds.contains(groupId));
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/community/groups/$groupId',
      );
      return CommunityGroup.fromJson(
        response.data ?? const <String, dynamic>{},
      ).copyWith(joined: _joinedGroupIds.contains(groupId));
    } on DioException catch (error) {
      final localGroup = _findLocalGroup(groupId);
      if (_canUseLocalFallback(error) && localGroup != null) {
        return localGroup.copyWith(joined: _joinedGroupIds.contains(groupId));
      }
      rethrow;
    }
  }

  Future<CommunityGroup> createGroup({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _createLocalGroup(
        name: name,
        description: description,
        isPublic: isPublic,
      );
    }

    final data = {
      'name': name,
      'description': description,
      'isPublic': isPublic,
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/groups',
        data: data,
      );
      final group = CommunityGroup.fromJson(
        response.data ?? const <String, dynamic>{},
      );
      _joinedGroupIds.add(group.id);
      return group.copyWith(joined: true);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _createLocalGroup(
          name: name,
          description: description,
          isPublic: isPublic,
        );
      }
      rethrow;
    }
  }

  Future<CommunityGroup> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      final localGroup = _findLocalGroup(groupId);
      if (localGroup != null) {
        return _updateLocalGroup(
          groupId: groupId,
          name: name,
          description: description,
          isPublic: isPublic,
        );
      }
    }

    final data = {
      'name': name,
      'description': description,
      'isPublic': isPublic,
    };

    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_prefix/community/groups/$groupId',
        data: data,
      );
      return CommunityGroup.fromJson(
        response.data ?? const <String, dynamic>{},
      ).copyWith(joined: _joinedGroupIds.contains(groupId));
    } on DioException catch (error) {
      if (_canUseLocalFallback(error) && _findLocalGroup(groupId) != null) {
        return _updateLocalGroup(
          groupId: groupId,
          name: name,
          description: description,
          isPublic: isPublic,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      _deleteLocalGroup(groupId);
      return;
    }

    try {
      await _dio.delete<void>('$_prefix/community/groups/$groupId');
      _joinedGroupIds.remove(groupId);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        _deleteLocalGroup(groupId);
        return;
      }
      rethrow;
    }
  }

  Future<ShareToken> shareContent({
    required SharedContentType contentType,
    required String contentId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _shareLocalContent(
        contentType: contentType,
        contentId: contentId,
        title: title,
        description: description,
        tags: tags,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/share',
        data: {
          'contentType': contentType.apiValue,
          // contentId는 learning 덱 UUID처럼 문자열 원본 ID가 들어올 수 있다.
          // engagement는 값을 해석하지 않고 공유 메타데이터로만 저장한다.
          'contentId': contentId,
          'title': title,
          'description': description,
          'tags': tags,
        },
      );
      return ShareToken.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _shareLocalContent(
          contentType: contentType,
          contentId: contentId,
          title: title,
          description: description,
          tags: tags,
        );
      }
      rethrow;
    }
  }

  Future<List<GroupMember>> getMembers(String groupId) async {
    if (await _shouldUseLocalFallbackWithoutRequest() &&
        _findLocalGroup(groupId) != null) {
      return [_localOwnerMember(groupId)];
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/community/groups/$groupId/members',
      );
      return _decodeList(response.data, GroupMember.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error) && _findLocalGroup(groupId) != null) {
        return [_localOwnerMember(groupId)];
      }
      rethrow;
    }
  }

  Future<GroupMember> joinGroup(String groupId) async {
    if (await _shouldUseLocalFallbackWithoutRequest() &&
        _findLocalGroup(groupId) != null) {
      _joinedGroupIds.add(groupId);
      return _localJoinedMember(groupId);
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/groups/$groupId/members/join',
      );
      _joinedGroupIds.add(groupId);
      return GroupMember.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      if (_canUseLocalFallback(error) && _findLocalGroup(groupId) != null) {
        _joinedGroupIds.add(groupId);
        return _localJoinedMember(groupId);
      }
      rethrow;
    }
  }

  Future<void> inviteGroupMember({
    required String groupId,
    required String userId,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest() &&
        _findLocalGroup(groupId) != null) {
      return;
    }

    try {
      await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/groups/$groupId/members/invite',
        data: {'userId': int.parse(userId)},
      );
    } on DioException catch (error) {
      if (_canUseLocalFallback(error) && _findLocalGroup(groupId) != null) {
        return;
      }
      rethrow;
    }
  }

  Future<List<SharedContent>> searchSharedContent({
    String? query,
    SharedContentType? contentType,
  }) async {
    final normalizedQuery = query?.trim();
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _filterLocalSharedContent(
        query: normalizedQuery,
        contentType: contentType,
      );
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/community/search',
        queryParameters: {
          if (normalizedQuery != null && normalizedQuery.isNotEmpty)
            'q': normalizedQuery,
          if (contentType != null) 'contentType': contentType.apiValue,
        },
      );
      return _decodeList(response.data, SharedContent.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _filterLocalSharedContent(
          query: normalizedQuery,
          contentType: contentType,
        );
      }
      rethrow;
    }
  }

  Future<SharedContent> getSharedContent(String token) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      final content = _findLocalSharedContent(token);
      if (content != null) {
        return content;
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/community/share/$token',
      );
      return SharedContent.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      final content = _findLocalSharedContent(token);
      if (_canUseLocalFallback(error) && content != null) {
        return content;
      }
      rethrow;
    }
  }

  Future<SharedContent> forkSharedContent(String token) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      final content = _incrementLocalSharedContentDownloadCount(token);
      if (content != null) {
        return content;
      }
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/share/$token/fork',
      );
      return SharedContent.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      final content = _incrementLocalSharedContentDownloadCount(token);
      if (_canUseLocalFallback(error) && content != null) {
        return content;
      }
      rethrow;
    }
  }

  Future<void> deleteSharedContent(String id) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      _deleteLocalSharedContent(id);
      return;
    }

    try {
      await _dio.delete<void>('$_prefix/community/share/$id');
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        _deleteLocalSharedContent(id);
        return;
      }
      rethrow;
    }
  }

  Future<CommunityReport> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _createLocalReport(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/community/reports',
        data: {
          'targetType': targetType.apiValue,
          'targetId': int.tryParse(targetId) ?? targetId,
          'reason': reason,
        },
      );
      return CommunityReport.fromJson(
        response.data ?? const <String, dynamic>{},
      );
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _createLocalReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
        );
      }
      rethrow;
    }
  }

  Future<List<CommunityReport>> getReports({
    ReportStatus status = ReportStatus.pending,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localReports
          .where((report) => report.status == status)
          .toList(growable: false);
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/admin/reports',
        queryParameters: {'status': status.apiValue},
      );
      return _decodeList(response.data, CommunityReport.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localReports
            .where((report) => report.status == status)
            .toList(growable: false);
      }
      rethrow;
    }
  }

  Future<CommunityReport> moderateReport({
    required String reportId,
    required ReportStatus status,
    String? actionTaken,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _moderateLocalReport(
        reportId: reportId,
        status: status,
        actionTaken: actionTaken,
      );
    }

    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_prefix/admin/reports/$reportId/resolve',
        data: {
          'status': status.apiValue,
          if (actionTaken != null) 'actionTaken': actionTaken,
        },
      );
      return CommunityReport.fromJson(
        response.data ?? const <String, dynamic>{},
      );
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _moderateLocalReport(
          reportId: reportId,
          status: status,
          actionTaken: actionTaken,
        );
      }
      rethrow;
    }
  }

  Future<bool> _shouldUseLocalFallbackWithoutRequest() async {
    if (!enableLocalFallback) {
      return false;
    }
    return await _tokenStore.read() == null;
  }

  bool _canUseLocalFallback(DioException error) {
    if (!enableLocalFallback) {
      return false;
    }
    final statusCode = error.response?.statusCode;
    return statusCode == null || statusCode == 401 || statusCode == 403;
  }

  CommunityGroup? _findLocalGroup(String groupId) {
    for (final group in _localGroups) {
      if (group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  List<CommunityGroup> _localGroupsWithJoinState() {
    return _localGroups
        .map((group) => group.copyWith(
              joined: _joinedGroupIds.contains(group.id),
            ))
        .toList(growable: false);
  }

  CommunityGroup _createLocalGroup({
    required String name,
    required String description,
    required bool isPublic,
  }) {
    final group = CommunityGroup(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      isPublic: isPublic,
      ownerId: 'local-user',
      createdAt: DateTime.now(),
      joined: true,
    );
    _localGroups.insert(0, group);
    _joinedGroupIds.add(group.id);
    return group;
  }

  CommunityGroup _updateLocalGroup({
    required String groupId,
    required String name,
    required String description,
    required bool isPublic,
  }) {
    final index = _localGroups.indexWhere((group) => group.id == groupId);
    if (index < 0) {
      throw StateError('Local group not found: $groupId');
    }
    final updated = _localGroups[index].copyWith(
      name: name,
      description: description,
      isPublic: isPublic,
    );
    _localGroups[index] = updated;
    return updated;
  }

  void _deleteLocalGroup(String groupId) {
    _localGroups.removeWhere((group) => group.id == groupId);
    _joinedGroupIds.remove(groupId);
  }

  ShareToken _shareLocalContent({
    required SharedContentType contentType,
    required String contentId,
    required String title,
    required String description,
    required List<String> tags,
  }) {
    final token = 'local-share-${DateTime.now().microsecondsSinceEpoch}';
    final content = SharedContent(
      id: token,
      shareToken: token,
      contentType: contentType,
      contentId: contentId,
      ownerId: 'local-user',
      title: title,
      description: description,
      tags: tags,
      downloadCount: 0,
      sourceShareId: null,
      createdAt: DateTime.now(),
    );
    _localSharedContents.insert(0, content);
    return ShareToken(
      shareToken: token,
      shareUrl: '/community/share/$token',
    );
  }

  GroupMember _localOwnerMember(String groupId) {
    return GroupMember(
      id: 'local-member-$groupId',
      groupId: groupId,
      userId: 'local-user',
      role: 'OWNER',
      status: 'ACTIVE',
      joinedAt: DateTime.now(),
    );
  }

  GroupMember _localJoinedMember(String groupId) {
    return GroupMember(
      id: 'local-join-$groupId',
      groupId: groupId,
      userId: 'local-user',
      role: 'MEMBER',
      status: 'ACTIVE',
      joinedAt: DateTime.now(),
    );
  }

  List<SharedContent> _filterLocalSharedContent({
    required String? query,
    required SharedContentType? contentType,
  }) {
    final normalizedQuery = query?.toLowerCase();
    return _localSharedContents.where((content) {
      final matchesType =
          contentType == null || content.contentType == contentType;
      final matchesQuery = normalizedQuery == null ||
          normalizedQuery.isEmpty ||
          content.title.toLowerCase().contains(normalizedQuery) ||
          content.description.toLowerCase().contains(normalizedQuery) ||
          content.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      return matchesType && matchesQuery;
    }).toList(growable: false);
  }

  SharedContent? _findLocalSharedContent(String token) {
    for (final content in _localSharedContents) {
      if (content.shareToken == token) {
        return content;
      }
    }
    return null;
  }

  SharedContent? _incrementLocalSharedContentDownloadCount(String token) {
    final index = _localSharedContents.indexWhere(
      (content) => content.shareToken == token,
    );
    if (index < 0) {
      return null;
    }
    final updated = _localSharedContents[index].copyWith(
      downloadCount: _localSharedContents[index].downloadCount + 1,
    );
    _localSharedContents[index] = updated;
    return updated;
  }

  void _deleteLocalSharedContent(String id) {
    _localSharedContents.removeWhere(
      (content) => content.id == id || content.shareToken == id,
    );
  }

  CommunityReport _createLocalReport({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) {
    final report = CommunityReport(
      id: 'local-report-${_localReports.length + 1}',
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      status: ReportStatus.pending,
      adminNote: null,
      createdAt: DateTime.now(),
      resolvedAt: null,
    );
    _localReports.insert(0, report);
    return report;
  }

  CommunityReport _moderateLocalReport({
    required String reportId,
    required ReportStatus status,
    String? actionTaken,
  }) {
    final index = _localReports.indexWhere((report) => report.id == reportId);
    if (index == -1) {
      throw StateError('Report not found: $reportId');
    }

    final updated = _localReports[index].copyWith(
      status: status,
      adminNote: actionTaken,
      resolvedAt: DateTime.now(),
    );
    _localReports[index] = updated;
    return updated;
  }
}

Map<String, dynamic> _unwrapData(Map<String, dynamic>? json) {
  // learning 응답이 { data: {...} } 래핑이든 raw object든 같은 모델로 파싱한다.
  final body = json ?? const <String, dynamic>{};
  final data = body['data'];
  return data is Map<String, dynamic> ? data : body;
}

List<CommunityGroup> _initialLocalGroups() {
  final now = DateTime.now();
  return [
    CommunityGroup(
      id: 'local-community-1',
      name: '자바스크립트 스터디',
      description: '프론트엔드 핵심 개념을 같이 복습하는 공개 그룹입니다.',
      isPublic: true,
      ownerId: 'local-user',
      createdAt: now.subtract(const Duration(minutes: 10)),
    ),
    CommunityGroup(
      id: 'local-community-2',
      name: 'CS 전공 면접 준비',
      description: '운영체제, 네트워크, 데이터베이스 질문을 함께 정리합니다.',
      isPublic: true,
      ownerId: 'local-user',
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
  ];
}

final _localSharedContents = [
  SharedContent(
    id: 'local-share-1',
    shareToken: 'local-deck-js',
    contentType: SharedContentType.deck,
    contentId: 'local-deck-1',
    ownerId: '101',
    title: '자바스크립트 핵심 문법 덱',
    description: '스코프, 클로저, 프로토타입을 짧은 카드로 정리했습니다.',
    tags: const ['javascript', 'frontend'],
    downloadCount: 42,
    sourceShareId: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  SharedContent(
    id: 'local-share-2',
    shareToken: 'local-deck-cs',
    contentType: SharedContentType.deck,
    contentId: 'local-deck-2',
    ownerId: '102',
    title: 'CS 면접 빈출 덱',
    description: '운영체제와 네트워크 질문을 면접 답변 형태로 묶었습니다.',
    tags: const ['cs', 'interview'],
    downloadCount: 31,
    sourceShareId: null,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  SharedContent(
    id: 'local-share-3',
    shareToken: 'local-note-db',
    contentType: SharedContentType.note,
    contentId: 'local-note-1',
    ownerId: '103',
    title: '데이터베이스 인덱스 정리 노트',
    description: 'B-Tree 인덱스와 복합 인덱스 선택 기준을 정리했습니다.',
    tags: const ['database', 'index'],
    downloadCount: 18,
    sourceShareId: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  SharedContent(
    id: 'local-share-4',
    shareToken: 'local-note-cloud',
    contentType: SharedContentType.note,
    contentId: 'local-note-2',
    ownerId: '104',
    title: '클라우드 배포 체크리스트',
    description: '로컬 k8s에서 Gateway 라우팅과 서비스 health check를 확인합니다.',
    tags: const ['cloud', 'k8s'],
    downloadCount: 27,
    sourceShareId: null,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// 백엔드가 리스트를 내려줄 때 null이나 예상 밖 타입이 섞여도 화면이 깨지지 않도록,
// Map 형태의 항목만 골라 각 도메인 모델로 변환한다.
List<T> _decodeList<T>(
  List<dynamic>? data,
  T Function(Map<String, dynamic>) decoder,
) {
  return (data ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(decoder)
      .toList(growable: false);
}

class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.ownerId,
    required this.createdAt,
    this.joined = false,
  });

  final String id;
  final String name;
  final String description;
  final bool isPublic;
  final String ownerId;
  final DateTime? createdAt;
  final bool joined;

  CommunityGroup copyWith({
    String? name,
    String? description,
    bool? isPublic,
    String? ownerId,
    DateTime? createdAt,
    bool? joined,
  }) {
    return CommunityGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      joined: joined ?? this.joined,
    );
  }

  // API 응답의 숫자 id도 화면과 라우팅에서는 문자열로 다루기 위해 문자열화한다.
  // 누락 가능한 필드는 기본값을 둬서 일부 데이터가 비어도 리스트 렌더링은 유지한다.
  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?) ?? '이름 없는 그룹',
      description: (json['description'] as String?) ?? '',
      isPublic: (json['isPublic'] as bool?) ?? false,
      ownerId: '${json['ownerId'] ?? ''}',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      joined: (json['joined'] as bool?) ?? false,
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  final String id;
  final String groupId;
  final String userId;
  final String role;
  final String status;
  final DateTime? joinedAt;

  // 멤버 권한과 상태는 백엔드 enum 문자열을 그대로 보존해 화면에서 표시/분기할 수 있게 한다.
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: '${json['id'] ?? ''}',
      groupId: '${json['groupId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      role: (json['role'] as String?) ?? 'MEMBER',
      status: (json['status'] as String?) ?? 'ACTIVE',
      joinedAt: DateTime.tryParse('${json['joinedAt'] ?? ''}'),
    );
  }
}

enum SharedContentType {
  deck('DECK'),
  note('NOTE');

  const SharedContentType(this.apiValue);

  // Dart enum 이름은 소문자로 유지하고, 백엔드 쿼리에는 계약된 대문자 값을 보낸다.
  final String apiValue;
}

enum ReportTargetType {
  sharedDeck('SHARED_DECK'),
  sharedNote('SHARED_NOTE'),
  studyGroup('STUDY_GROUP'),
  user('USER');

  const ReportTargetType(this.apiValue);

  final String apiValue;

  static ReportTargetType fromApiValue(String value) {
    return ReportTargetType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => ReportTargetType.sharedNote,
    );
  }
}

enum ReportStatus {
  pending('pending'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.apiValue);

  final String apiValue;

  static ReportStatus fromApiValue(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'resolved' || 'approved' => ReportStatus.resolved,
      'dismissed' || 'rejected' => ReportStatus.dismissed,
      _ => ReportStatus.pending,
    };
  }
}

class ShareToken {
  const ShareToken({
    required this.shareToken,
    required this.shareUrl,
  });

  final String shareToken;
  final String shareUrl;

  factory ShareToken.fromJson(Map<String, dynamic> json) {
    return ShareToken(
      shareToken: (json['shareToken'] as String?) ?? '',
      shareUrl: (json['shareUrl'] as String?) ?? '',
    );
  }
}

class CommunityReport {
  const CommunityReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.adminNote,
    required this.createdAt,
    required this.resolvedAt,
  });

  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reason;
  final ReportStatus status;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  CommunityReport copyWith({
    String? id,
    ReportTargetType? targetType,
    String? targetId,
    String? reason,
    ReportStatus? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return CommunityReport(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory CommunityReport.fromJson(Map<String, dynamic> json) {
    return CommunityReport(
      id: '${json['id'] ?? ''}',
      targetType: ReportTargetType.fromApiValue(
        '${json['targetType'] ?? 'SHARED_NOTE'}',
      ),
      targetId: '${json['targetId'] ?? ''}',
      reason: (json['reason'] as String?) ?? '',
      status: ReportStatus.fromApiValue('${json['status'] ?? 'pending'}'),
      adminNote: (json['actionTaken'] ?? json['adminNote']) as String?,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      resolvedAt: DateTime.tryParse('${json['resolvedAt'] ?? ''}'),
    );
  }
}

class SharedContent {
  const SharedContent({
    required this.id,
    required this.shareToken,
    required this.contentType,
    required this.contentId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.tags,
    required this.downloadCount,
    required this.sourceShareId,
    required this.createdAt,
  });

  final String id;
  final String shareToken;
  final SharedContentType contentType;
  final String contentId;
  final String ownerId;
  final String title;
  final String description;
  final List<String> tags;
  final int downloadCount;
  final String? sourceShareId;
  final DateTime? createdAt;

  SharedContent copyWith({
    String? id,
    String? shareToken,
    SharedContentType? contentType,
    String? contentId,
    String? ownerId,
    String? title,
    String? description,
    List<String>? tags,
    int? downloadCount,
    String? sourceShareId,
    DateTime? createdAt,
  }) {
    return SharedContent(
      id: id ?? this.id,
      shareToken: shareToken ?? this.shareToken,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      downloadCount: downloadCount ?? this.downloadCount,
      sourceShareId: sourceShareId ?? this.sourceShareId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 공유 콘텐츠는 덱/노트가 같은 API를 사용하므로 contentType으로 화면 흐름을 나눈다.
  // 서버 값이 없거나 알 수 없으면 기존 노트 공유 화면으로 안전하게 떨어뜨린다.
  factory SharedContent.fromJson(Map<String, dynamic> json) {
    final type = '${json['contentType'] ?? 'NOTE'}';
    return SharedContent(
      id: '${json['id'] ?? ''}',
      shareToken: (json['shareToken'] as String?) ?? '',
      contentType: type == 'DECK'
          ? SharedContentType.deck
          : SharedContentType.note,
      contentId: '${json['contentId'] ?? ''}',
      ownerId: '${json['ownerId'] ?? ''}',
      title: (json['title'] as String?) ?? '제목 없음',
      description: (json['description'] as String?) ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      sourceShareId: json['sourceShareId'] == null
          ? null
          : '${json['sourceShareId']}',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}

class SharedDeckDetail {
  const SharedDeckDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.cards,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String color;
  final List<SharedDeckCard> cards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get cardCount => cards.length;

  factory SharedDeckDetail.fromJson(Map<String, dynamic> json) {
    // learning 쪽 DTO 이름이 최종 확정되기 전까지 cards/cardPreview/items를 모두 받아
    // 화면은 카드 배열만 있으면 먼저 동작할 수 있게 한다.
    final rawCards = json['cards'] ?? json['cardPreview'] ?? json['items'];
    return SharedDeckDetail(
      id: '${json['id'] ?? json['deckId'] ?? ''}',
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      cards: rawCards is List
          ? rawCards
              .whereType<Map<String, dynamic>>()
              .map(SharedDeckCard.fromJson)
              .toList(growable: false)
          : const [],
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
    );
  }
}

class SharedDeckCard {
  const SharedDeckCard({
    required this.id,
    required this.frontContent,
    required this.backContent,
    required this.cardType,
  });

  final String id;
  final String frontContent;
  final String backContent;
  final String cardType;

  factory SharedDeckCard.fromJson(Map<String, dynamic> json) {
    // 카드 식별자와 앞/뒷면 필드는 서비스마다 이름이 달라질 수 있어 대표 후보를 순서대로 읽는다.
    return SharedDeckCard(
      id: '${json['id'] ?? json['cardId'] ?? ''}',
      frontContent: (json['frontContent'] ?? json['front'] ?? '').toString(),
      backContent: (json['backContent'] ?? json['back'] ?? '').toString(),
      cardType: (json['cardType'] ?? json['type'] ?? '').toString(),
    );
  }
}

class SharedDeckCopyResult {
  const SharedDeckCopyResult({required this.deckId});

  final String deckId;

  factory SharedDeckCopyResult.fromJson(Map<String, dynamic> json) {
    // 복사 API가 새 덱 id를 어떤 필드명으로 주더라도 내 덱 목록 갱신 흐름은 유지한다.
    return SharedDeckCopyResult(
      deckId: '${json['id'] ?? json['deckId'] ?? json['copiedDeckId'] ?? ''}',
    );
  }
}

class DeckShareableStatus {
  const DeckShareableStatus({
    required this.shareable,
    required this.reason,
  });

  final bool shareable;
  final String reason;

  factory DeckShareableStatus.fromJson(Map<String, dynamic> json) {
    // boolean 필드명이 shareable/isShareable 중 어느 쪽이어도 같은 의미로 처리한다.
    return DeckShareableStatus(
      shareable: (json['shareable'] as bool?) ??
          (json['isShareable'] as bool?) ??
          false,
      reason: (json['reason'] ?? json['message'] ?? '').toString(),
    );
  }
}
