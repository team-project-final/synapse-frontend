import 'package:dio/dio.dart';

class GamificationProfile {
  const GamificationProfile({
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      xp: _intValue(json['xp']) ?? 0,
      level: _intValue(json['level']) ?? 1,
      currentStreak: _intValue(json['currentStreak']) ?? 0,
      longestStreak: _intValue(json['longestStreak']) ?? 0,
      badges: _listValue(json['badges'])
          .whereType<Map<String, dynamic>>()
          .map(GamificationBadge.fromJson)
          .toList(growable: false),
    );
  }

  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final List<GamificationBadge> badges;

  int get nextLevelXp => switch (level) {
    1 => 100,
    2 => 300,
    3 => 600,
    _ => 600 + ((level - 3) * 500),
  };

  int get previousLevelXp => switch (level) {
    <= 1 => 0,
    2 => 100,
    3 => 300,
    _ => 600 + ((level - 4) * 500),
  };

  int get remainingXp => (nextLevelXp - xp).clamp(0, nextLevelXp).toInt();

  double get levelProgress {
    final span = nextLevelXp - previousLevelXp;
    if (span <= 0) return 0;
    return ((xp - previousLevelXp) / span).clamp(0, 1).toDouble();
  }
}

class GamificationBadge {
  const GamificationBadge({
    required this.code,
    required this.name,
    required this.description,
    required this.conditionType,
    required this.conditionValue,
    this.iconUrl,
    this.earnedAt,
  });

  factory GamificationBadge.fromJson(Map<String, dynamic> json) {
    return GamificationBadge(
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '이름 없는 배지',
      description: (json['description'] as String?) ?? '',
      iconUrl: json['iconUrl'] as String?,
      conditionType: (json['conditionType'] as String?) ?? 'UNKNOWN',
      conditionValue: _intValue(json['conditionValue']) ?? 0,
      earnedAt: _dateTimeValue(json['earnedAt']),
    );
  }

  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final String conditionType;
  final int conditionValue;
  final DateTime? earnedAt;

  bool get earned => earnedAt != null;

  GamificationBadge copyWithEarnedAt(DateTime? value) {
    return GamificationBadge(
      code: code,
      name: name,
      description: description,
      iconUrl: iconUrl,
      conditionType: conditionType,
      conditionValue: conditionValue,
      earnedAt: value,
    );
  }

  String get conditionLabel {
    return switch (conditionType) {
      'TOTAL_XP' => '누적 XP $conditionValue 이상',
      'LEVEL' => '레벨 $conditionValue 달성',
      'STREAK' => '$conditionValue일 연속 활동',
      _ => description.isEmpty ? '조건 정보 없음' : description,
    };
  }
}

class XpEvent {
  const XpEvent({
    required this.eventType,
    required this.xpAmount,
    required this.sourceId,
    required this.sourceType,
    required this.eventId,
    this.createdAt,
  });

  factory XpEvent.fromJson(Map<String, dynamic> json) {
    return XpEvent(
      eventType: (json['eventType'] as String?) ?? '',
      xpAmount: _intValue(json['xpAmount']) ?? 0,
      sourceId: _stringId(json['sourceId']),
      sourceType: (json['sourceType'] as String?) ?? '',
      eventId: (json['eventId'] as String?) ?? '',
      createdAt: _dateTimeValue(json['createdAt']),
    );
  }

  final String eventType;
  final int xpAmount;
  final String sourceId;
  final String sourceType;
  final String eventId;
  final DateTime? createdAt;

  String get title {
    return switch (eventType) {
      'REVIEW_COMPLETED' => '복습 완료',
      'NOTE_CREATED' => '노트 작성',
      'CARD_CREATED' => '카드 생성',
      'DECK_SHARED' => '콘텐츠 공유',
      'QUIZ_COMPLETED' => '퀴즈 완료',
      _ => eventType.replaceAll('_', ' '),
    };
  }

  String get sourceLabel {
    if (sourceType.isEmpty && sourceId.isEmpty) return '출처 없음';
    if (sourceId.isEmpty) return sourceType;
    if (sourceType.isEmpty) return sourceId;
    return '$sourceType · $sourceId';
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    required this.xp,
    required this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: _intValue(json['rank']) ?? 0,
      userId: _stringId(json['userId']),
      nickname: (json['nickname'] as String?) ?? '사용자',
      xp: _intValue(json['xp']) ?? 0,
      level: _intValue(json['level']) ?? 1,
    );
  }

  final int rank;
  final String userId;
  final String nickname;
  final int xp;
  final int level;
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
    this.sourceShareId,
    this.createdAt,
  });

  factory SharedContent.fromJson(Map<String, dynamic> json) {
    return SharedContent(
      id: _stringId(json['id']),
      shareToken: (json['shareToken'] as String?) ?? '',
      contentType: (json['contentType'] as String?) ?? '',
      contentId: _stringId(json['contentId']),
      ownerId: _stringId(json['ownerId']),
      title: (json['title'] as String?) ?? '제목 없는 공유 콘텐츠',
      description: (json['description'] as String?) ?? '',
      tags: _stringList(json['tags']),
      downloadCount: _intValue(json['downloadCount']) ?? 0,
      sourceShareId: json['sourceShareId'] == null
          ? null
          : _stringId(json['sourceShareId']),
      createdAt: _dateTimeValue(json['createdAt']),
    );
  }

  final String id;
  final String shareToken;
  final String contentType;
  final String contentId;
  final String ownerId;
  final String title;
  final String description;
  final List<String> tags;
  final int downloadCount;
  final String? sourceShareId;
  final DateTime? createdAt;

  String get ownerLabel => ownerId.isEmpty ? '소유자 미상' : '사용자 #$ownerId';
  String get createdLabel => _relativeDate(createdAt);
}

class ShareToken {
  const ShareToken({required this.shareToken, required this.shareUrl});

  factory ShareToken.fromJson(Map<String, dynamic> json) {
    return ShareToken(
      shareToken: (json['shareToken'] as String?) ?? '',
      shareUrl: (json['shareUrl'] as String?) ?? '',
    );
  }

  final String shareToken;
  final String shareUrl;
}

class EngagementReport {
  const EngagementReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    this.adminNote,
    this.createdAt,
    this.resolvedAt,
  });

  factory EngagementReport.fromJson(Map<String, dynamic> json) {
    return EngagementReport(
      id: _stringId(json['id']),
      targetType: (json['targetType'] as String?) ?? '',
      targetId: _stringId(json['targetId']),
      reason: (json['reason'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'PENDING',
      adminNote: json['adminNote'] as String?,
      createdAt: _dateTimeValue(json['createdAt']),
      resolvedAt: _dateTimeValue(json['resolvedAt']),
    );
  }

  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  String get targetLabel {
    final typeLabel = switch (targetType) {
      'SHARED_DECK' => '공유 덱',
      'SHARED_NOTE' => '공유 노트',
      'STUDY_GROUP' => '스터디 그룹',
      'USER' => '사용자',
      _ => targetType,
    };
    return '$typeLabel #$targetId';
  }

  String get statusLabel {
    return switch (status) {
      'APPROVED' => '승인',
      'REJECTED' => '기각',
      _ => '대기',
    };
  }

  String get createdLabel => _relativeDate(createdAt);
}

class EngagementApi {
  const EngagementApi(this._dio);

  final Dio _dio;

  Future<GamificationProfile> getGamificationProfile() async {
    final response = await _dio.get<dynamic>('/api/v1/gamification/me');
    return GamificationProfile.fromJson(_unwrapMap(response.data));
  }

  Future<List<XpEvent>> getXpHistory() async {
    final response = await _dio.get<dynamic>('/api/v1/gamification/xp/history');
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(XpEvent.fromJson)
        .toList(growable: false);
  }

  Future<List<GamificationBadge>> getBadges() async {
    final response = await _dio.get<dynamic>('/api/v1/gamification/badges');
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(GamificationBadge.fromJson)
        .toList(growable: false);
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'all',
    int limit = 20,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/gamification/leaderboard',
      queryParameters: {'period': period, 'limit': limit},
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardEntry.fromJson)
        .toList(growable: false);
  }

  Future<GamificationProfile> addXpEvent({
    required String eventType,
    required String sourceId,
    required String sourceType,
    required String eventId,
    int? xpAmount,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/gamification/xp/events',
      data: {
        'eventType': eventType,
        'sourceId': sourceId,
        'sourceType': sourceType,
        'eventId': eventId,
        if (xpAmount != null) 'xpAmount': xpAmount,
      },
    );
    return GamificationProfile.fromJson(_unwrapMap(response.data));
  }

  Future<ShareToken> shareContent({
    required String contentType,
    required String contentId,
    required String title,
    required String description,
    List<String> tags = const [],
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/community/share',
      data: {
        'contentType': contentType,
        'contentId': int.tryParse(contentId) ?? contentId,
        'title': title,
        'description': description,
        'tags': tags,
      },
    );
    return ShareToken.fromJson(_unwrapMap(response.data));
  }

  Future<SharedContent> getSharedContent(String token) async {
    final response = await _dio.get<dynamic>('/api/v1/community/share/$token');
    return SharedContent.fromJson(_unwrapMap(response.data));
  }

  Future<List<SharedContent>> searchSharedContent({
    String? query,
    String? contentType,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/community/search',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (contentType != null && contentType.isNotEmpty)
          'contentType': contentType,
      },
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(SharedContent.fromJson)
        .toList(growable: false);
  }

  Future<SharedContent> forkSharedContent(String token) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/community/share/$token/fork',
    );
    return SharedContent.fromJson(_unwrapMap(response.data));
  }

  Future<void> deleteSharedContent(String id) async {
    await _dio.delete<void>('/api/v1/community/share/$id');
  }

  Future<EngagementReport> createReport({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/community/reports',
      data: {
        'targetType': targetType,
        'targetId': int.tryParse(targetId) ?? targetId,
        'reason': reason,
      },
    );
    return EngagementReport.fromJson(_unwrapMap(response.data));
  }

  Future<List<EngagementReport>> getReports({String status = 'PENDING'}) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/admin/reports',
      queryParameters: {'status': status},
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(EngagementReport.fromJson)
        .toList(growable: false);
  }

  Future<EngagementReport> moderateReport({
    required String reportId,
    required String status,
    String? adminNote,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/api/v1/admin/reports/$reportId',
      data: {
        'status': status,
        if (adminNote != null && adminNote.trim().isNotEmpty)
          'adminNote': adminNote.trim(),
      },
    );
    return EngagementReport.fromJson(_unwrapMap(response.data));
  }
}

Map<String, dynamic> _unwrapMap(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is Map<String, dynamic>) return unwrapped;
  if (unwrapped is Map) {
    return unwrapped.map((key, value) => MapEntry('$key', value));
  }
  throw const FormatException('Invalid engagement API response.');
}

List<dynamic> _unwrapList(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is List) return unwrapped;
  if (unwrapped is Map<String, dynamic>) {
    return _listValue(
      unwrapped['content'] ??
          unwrapped['items'] ??
          unwrapped['results'] ??
          unwrapped['data'],
    );
  }
  return const [];
}

Object? _unwrapData(Object? payload) {
  if (payload is Map<String, dynamic> && payload.containsKey('data')) {
    return payload['data'];
  }
  if (payload is Map && payload.containsKey('data')) {
    return payload['data'];
  }
  return payload;
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => '$item').toList(growable: false);
}

String _stringId(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is num) return value.toInt().toString();
  return '$value';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _dateTimeValue(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _relativeDate(DateTime? value) {
  if (value == null) return '시간 미상';
  final difference = DateTime.now().difference(value.toLocal());
  if (difference.inMinutes < 1) return '방금 전';
  if (difference.inHours < 1) return '${difference.inMinutes}분 전';
  if (difference.inDays < 1) return '${difference.inHours}시간 전';
  if (difference.inDays < 7) return '${difference.inDays}일 전';
  final local = value.toLocal();
  return '${local.month.toString().padLeft(2, '0')}/'
      '${local.day.toString().padLeft(2, '0')}';
}
