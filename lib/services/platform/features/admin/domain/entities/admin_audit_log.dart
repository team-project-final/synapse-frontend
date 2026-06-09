/// 관리자 감사 로그 화면이 다루는 감사 로그 도메인 엔티티.
class AdminAuditLog {
  const AdminAuditLog({
    required this.id,
    required this.eventId,
    required this.action,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    required this.oldValue,
    required this.newValue,
    required this.ipAddress,
    required this.userAgent,
    this.createdAt,
  });

  final String id;
  final String eventId;
  final String action;
  final String userId;
  final String resourceType;
  final String resourceId;
  final String oldValue;
  final String newValue;
  final String ipAddress;
  final String userAgent;
  final DateTime? createdAt;

  /// 대상 표시용 라벨: resourceType:resourceId (없으면 '-').
  String get targetLabel {
    if (resourceType.isEmpty && resourceId.isEmpty) return '-';
    if (resourceId.isEmpty) return resourceType;
    return '$resourceType:$resourceId';
  }
}
