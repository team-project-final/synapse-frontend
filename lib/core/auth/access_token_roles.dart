import 'dart:convert';

/// access token(JWT) payload에서 `roles` 클레임을 읽는다.
///
/// 서명 검증은 백엔드(JwtAuthenticationFilter)의 책임이며, 여기서는 UI 권한
/// 표시·라우트 가드 같은 UX 목적의 읽기 전용으로만 사용한다. 실제 인가는 매
/// 요청마다 백엔드가 강제한다.
List<String> rolesFromAccessToken(String? token) {
  final payload = _decodePayload(token);
  final roles = payload?['roles'];
  if (roles is List) {
    return roles.whereType<String>().toList(growable: false);
  }
  return const [];
}

Map<String, dynamic>? _decodePayload(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded);
    return json is Map<String, dynamic> ? json : null;
  } catch (_) {
    return null;
  }
}
