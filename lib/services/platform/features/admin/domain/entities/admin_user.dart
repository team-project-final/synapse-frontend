/// 관리자 사용자 관리 화면이 다루는 사용자 도메인 엔티티.
/// status 원본값(active/suspended/deleted 등)을 그대로 보존한다 — 표시용 변환은 presentation에서.
class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.status,
    this.createdAt,
    this.suspendedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String status;
  final DateTime? createdAt;
  final DateTime? suspendedAt;
}
