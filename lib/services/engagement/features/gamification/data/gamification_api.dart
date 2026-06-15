import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final gamificationApiProvider = Provider<GamificationApi>((ref) {
  final environment = ref.watch(environmentProvider);
  return GamificationApi(
    ref.watch(dioProvider),
    ref.watch(tokenStoreProvider),
    environment.gamificationApiPrefix,
    enableLocalFallback: environment == AppEnvironment.dev,
  );
});

// TODO(gamification-api-integration): 나중에 실제 engagement API 연결 시 교체/검증할 것.
// 지금은 gamification 화면을 백엔드 auth/Flyway 이슈와 분리해서 작업하기 위해
// dev 환경에서 로컬 fallback 데이터를 허용한다. 나중에 platform-svc JWT subject와
// engagement-svc CurrentUser 계약이 맞춰지면 fallback 의존을 제거하고 실제 응답을 검증한다.
// gamification도 engagement 서비스 안의 기능이므로 일반 환경에서는 Gateway route를 사용한다.
// TODO(gamification-api-integration): platform-dev 경로는 임시 직접 호출 경로다.
// Gateway/서비스 라우팅 정책이 확정되면 실제 배포 경로와 동일하게 교체한다.
// platform-dev는 서비스 단독 실행을 전제로 해서 /api/v1로 직접 호출한다.
extension GamificationApiPrefix on AppEnvironment {
  String get gamificationApiPrefix {
    return switch (this) {
      AppEnvironment.dev ||
      AppEnvironment.staging ||
      AppEnvironment.prod => '/api/engagement/api/v1',
      AppEnvironment.platformDev => '/api/v1',
    };
  }
}

class GamificationApi {
  const GamificationApi(
    this._dio,
    this._tokenStore,
    this._prefix, {
    this.enableLocalFallback = false,
  });

  final Dio _dio;
  final TokenStore _tokenStore;
  final String _prefix;
  final bool enableLocalFallback;

  // 서비스 클래스는 HTTP 호출과 JSON -> 도메인 모델 변환만 담당한다.
  // 화면 상태 관리는 providers 계층에서 처리해서 네트워크 코드와 UI 코드를 분리한다.
  Future<UserGamification> getMyGamification() async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localGamification;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/gamification/me',
      );
      return UserGamification.fromJson(
        response.data ?? const <String, dynamic>{},
      );
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localGamification;
      }
      rethrow;
    }
  }

  Future<List<BadgeInfo>> getBadges() async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localBadges;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/gamification/badges',
      );
      return _decodeList(response.data, BadgeInfo.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localBadges;
      }
      rethrow;
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'all',
    int limit = 20,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localLeaderboard.take(limit).toList(growable: false);
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/gamification/leaderboard',
        queryParameters: {'period': period, 'limit': limit},
      );
      return _decodeList(response.data, LeaderboardEntry.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localLeaderboard.take(limit).toList(growable: false);
      }
      rethrow;
    }
  }

  Future<List<XpEvent>> getXpHistory() async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _localXpHistory;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_prefix/gamification/xp/history',
      );
      return _decodeList(response.data, XpEvent.fromJson);
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _localXpHistory;
      }
      rethrow;
    }
  }

  Future<UserGamification> addXpEvent({
    required GamificationEventType eventType,
    required String sourceId,
    required String sourceType,
    required String eventId,
    int? xpAmount,
  }) async {
    if (await _shouldUseLocalFallbackWithoutRequest()) {
      return _addLocalXpEvent(
        eventType: eventType,
        sourceId: sourceId,
        sourceType: sourceType,
        eventId: eventId,
        xpAmount: xpAmount,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/gamification/xp/events',
        data: {
          'eventType': eventType.apiValue,
          if (xpAmount != null) 'xpAmount': xpAmount,
          'sourceId': sourceId,
          'sourceType': sourceType,
          'eventId': eventId,
        },
      );
      return UserGamification.fromJson(
        response.data ?? const <String, dynamic>{},
      );
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) {
        return _addLocalXpEvent(
          eventType: eventType,
          sourceId: sourceId,
          sourceType: sourceType,
          eventId: eventId,
          xpAmount: xpAmount,
        );
      }
      rethrow;
    }
  }

  Future<bool> _shouldUseLocalFallbackWithoutRequest() async {
    // TODO(gamification-auth-integration): 실제 로그인 연동 후에는 토큰이 없을 때 로그인 화면으로 보내고,
    // 이 mock fallback은 storybook/demo 또는 테스트 전용으로만 남긴다.
    if (!enableLocalFallback) {
      return false;
    }
    return await _tokenStore.read() == null;
  }

  bool _canUseLocalFallback(DioException error) {
    // TODO(gamification-auth-integration): engagement API 안정화 후 401/403은 fallback 대신 인증 실패 UI로 노출한다.
    // 현재는 gamification 프론트 작업이 platform 로그인 연동에 막히지 않게 임시 허용한다.
    if (!enableLocalFallback) {
      return false;
    }
    final statusCode = error.response?.statusCode;
    return statusCode == null || statusCode == 401 || statusCode == 403;
  }

  UserGamification _addLocalXpEvent({
    required GamificationEventType eventType,
    required String sourceId,
    required String sourceType,
    required String eventId,
    int? xpAmount,
  }) {
    final existing = _localXpHistory.any((event) => event.eventId == eventId);
    if (existing) {
      return _localGamification;
    }

    final amount = xpAmount ?? 20;
    final nextXp = _localGamification.xp + amount;
    _localGamification = _localGamification.copyWith(
      xp: nextXp,
      level: (nextXp ~/ 250) + 1,
      currentStreak: _localGamification.currentStreak + 1,
      longestStreak: _localGamification.currentStreak + 1 >
              _localGamification.longestStreak
          ? _localGamification.currentStreak + 1
          : _localGamification.longestStreak,
    );
    _localXpHistory.insert(
      0,
      XpEvent(
        eventType: eventType.apiValue,
        xpAmount: amount,
        sourceId: sourceId,
        sourceType: sourceType,
        eventId: eventId,
        createdAt: DateTime.now(),
      ),
    );
    return _localGamification;
  }
}

// TODO(gamification-api-integration): 아래 로컬 데이터는 실제 API 응답 연결 전까지만 사용한다.
// 백엔드 응답 DTO가 확정되면 이 샘플과 fromJson 필드명을 대조한 뒤 제거하거나 테스트 fixture로 이동한다.
final _localBadges = [
  BadgeInfo(
    code: 'FIRST_XP',
    name: '첫 XP',
    description: '첫 학습 활동으로 XP를 획득했습니다.',
    iconUrl: '',
    conditionType: 'XP',
    conditionValue: 1,
    earnedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  const BadgeInfo(
    code: 'WEEKLY_STREAK',
    name: '꾸준함',
    description: '이번 주 학습 흐름을 이어가고 있습니다.',
    iconUrl: '',
    conditionType: 'STREAK',
    conditionValue: 7,
    earnedAt: null,
  ),
];

var _localGamification = UserGamification(
  xp: 1280,
  level: 6,
  currentStreak: 4,
  longestStreak: 9,
  badges: _localBadges,
);

const _localLeaderboard = [
  LeaderboardEntry(
    rank: 1,
    userId: '101',
    nickname: '김스터디',
    xp: 2480,
    level: 9,
  ),
  LeaderboardEntry(
    rank: 2,
    userId: '102',
    nickname: '이암기',
    xp: 2210,
    level: 8,
  ),
  LeaderboardEntry(
    rank: 3,
    userId: '103',
    nickname: '박리뷰',
    xp: 1980,
    level: 7,
  ),
  LeaderboardEntry(
    rank: 4,
    userId: 'local-user',
    nickname: '나',
    xp: 1280,
    level: 6,
  ),
];

final _localXpHistory = [
  XpEvent(
    eventType: 'CARD_REVIEWED',
    xpAmount: 20,
    sourceId: 'local-card-1',
    sourceType: 'card',
    eventId: 'local-xp-1',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  XpEvent(
    eventType: 'QUIZ_COMPLETED',
    xpAmount: 35,
    sourceId: 'local-quiz-1',
    sourceType: 'quiz',
    eventId: 'local-xp-2',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// 리스트 응답에서 유효한 JSON object만 모델로 바꾼다.
// 잘못된 항목 하나 때문에 전체 화면 로딩이 실패하지 않도록 방어적으로 처리한다.
List<T> _decodeList<T>(
  List<dynamic>? data,
  T Function(Map<String, dynamic>) decoder,
) {
  return (data ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(decoder)
      .toList(growable: false);
}

class UserGamification {
  const UserGamification({
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
  });

  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final List<BadgeInfo> badges;

  UserGamification copyWith({
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    List<BadgeInfo>? badges,
  }) {
    return UserGamification(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      badges: badges ?? this.badges,
    );
  }

  // 내 gamification 요약은 프로필 카드와 배지 목록에서 같이 쓰이므로
  // 중첩된 badges 배열까지 BadgeInfo 모델로 정규화한다.
  factory UserGamification.fromJson(Map<String, dynamic> json) {
    return UserGamification(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BadgeInfo.fromJson)
          .toList(growable: false),
    );
  }
}

enum GamificationEventType {
  cardReviewed('CARD_REVIEWED'),
  noteCreated('NOTE_CREATED'),
  contentShared('CONTENT_SHARED'),
  contentCopied('CONTENT_COPIED'),
  groupJoined('GROUP_JOINED');

  const GamificationEventType(this.apiValue);

  final String apiValue;
}

class BadgeInfo {
  const BadgeInfo({
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.conditionType,
    required this.conditionValue,
    required this.earnedAt,
  });

  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final String conditionType;
  final int conditionValue;
  final DateTime? earnedAt;

  bool get acquired => earnedAt != null;

  // earnedAt 존재 여부를 acquired로 계산해서
  // 화면은 날짜 파싱 로직 없이 획득/미획득 상태만 확인하면 된다.
  factory BadgeInfo.fromJson(Map<String, dynamic> json) {
    return BadgeInfo(
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '배지',
      description: (json['description'] as String?) ?? '',
      iconUrl: (json['iconUrl'] as String?) ?? '',
      conditionType: (json['conditionType'] as String?) ?? '',
      conditionValue: (json['conditionValue'] as num?)?.toInt() ?? 0,
      earnedAt: DateTime.tryParse('${json['earnedAt'] ?? ''}'),
    );
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

  final int rank;
  final String userId;
  final String nickname;
  final int xp;
  final int level;

  // 백엔드 리더보드 응답에 현재 사용자 여부가 없어서 isMe 같은 임시 필드는 두지 않는다.
  // 화면은 서버가 내려준 rank/user/xp 정보만 신뢰해서 표시한다.
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: '${json['userId'] ?? ''}',
      nickname: (json['nickname'] as String?) ?? 'User ${json['userId'] ?? ''}',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
    );
  }
}

class XpEvent {
  const XpEvent({
    required this.eventType,
    required this.xpAmount,
    required this.sourceId,
    required this.sourceType,
    required this.eventId,
    required this.createdAt,
  });

  final String eventType;
  final int xpAmount;
  final String sourceId;
  final String sourceType;
  final String eventId;
  final DateTime? createdAt;

  // XP 이력은 이벤트 종류와 출처를 그대로 보존한다.
  // 이후 화면에서 이벤트 타입별 문구나 필터를 붙여도 API 모델을 다시 바꿀 필요가 없다.
  factory XpEvent.fromJson(Map<String, dynamic> json) {
    return XpEvent(
      eventType: (json['eventType'] as String?) ?? 'XP',
      xpAmount: (json['xpAmount'] as num?)?.toInt() ?? 0,
      sourceId: (json['sourceId'] as String?) ?? '',
      sourceType: (json['sourceType'] as String?) ?? '',
      eventId: (json['eventId'] as String?) ?? '',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}
