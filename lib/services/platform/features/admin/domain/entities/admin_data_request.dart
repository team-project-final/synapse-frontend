// `GET/POST /api/v1/admin/data-requests` 도메인 엔티티.

enum AdminDataRequestType {
  dataAccess,
  dataExport,
  dataErasure,
  unknown;

  static AdminDataRequestType parse(String? raw) {
    return switch (raw) {
      'DATA_ACCESS' => AdminDataRequestType.dataAccess,
      'DATA_EXPORT' => AdminDataRequestType.dataExport,
      'DATA_ERASURE' => AdminDataRequestType.dataErasure,
      _ => AdminDataRequestType.unknown,
    };
  }

  String get serverValue => switch (this) {
        AdminDataRequestType.dataAccess => 'DATA_ACCESS',
        AdminDataRequestType.dataExport => 'DATA_EXPORT',
        AdminDataRequestType.dataErasure => 'DATA_ERASURE',
        AdminDataRequestType.unknown => '',
      };
}

enum AdminDataRequestStatus {
  pending,
  processing,
  completed,
  rejected,
  unknown;

  static AdminDataRequestStatus parse(String? raw) {
    return switch (raw) {
      'PENDING' => AdminDataRequestStatus.pending,
      'PROCESSING' => AdminDataRequestStatus.processing,
      'COMPLETED' => AdminDataRequestStatus.completed,
      'REJECTED' => AdminDataRequestStatus.rejected,
      _ => AdminDataRequestStatus.unknown,
    };
  }

  String get serverValue => switch (this) {
        AdminDataRequestStatus.pending => 'PENDING',
        AdminDataRequestStatus.processing => 'PROCESSING',
        AdminDataRequestStatus.completed => 'COMPLETED',
        AdminDataRequestStatus.rejected => 'REJECTED',
        AdminDataRequestStatus.unknown => '',
      };
}

/// 관리자 처리 액션. 전이 규칙은 백엔드가 강제한다
/// (PENDING→approve→PROCESSING→execute→COMPLETED, reject는 진행 중 상태에서만).
enum AdminDataRequestAction {
  approve,
  execute,
  reject;

  String get serverValue => switch (this) {
        AdminDataRequestAction.approve => 'APPROVE',
        AdminDataRequestAction.execute => 'EXECUTE',
        AdminDataRequestAction.reject => 'REJECT',
      };
}

/// 상태 전이 충돌(409) — 다른 관리자가 먼저 처리했거나 허용되지 않는 전이.
class AdminDataRequestConflictException implements Exception {
  const AdminDataRequestConflictException(this.message);

  final String message;

  @override
  String toString() => 'AdminDataRequestConflictException($message)';
}

class AdminDataRequest {
  const AdminDataRequest({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userDisplayName,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    required this.daysRemaining,
    required this.executionLogs,
    this.receivedAt,
    this.dueAt,
    this.processedAt,
    this.reason,
    this.adminNote,
    this.dataSummary,
    this.latestLog,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String userDisplayName;
  final AdminDataRequestType type;

  /// 서버 제공 한국어 라벨(예: '데이터 열람') — 프론트 별도 매핑 불필요.
  final String typeLabel;
  final AdminDataRequestStatus status;
  final String statusLabel;
  final DateTime? receivedAt;
  final DateTime? dueAt;
  final int daysRemaining;
  final DateTime? processedAt;
  final String? reason;
  final String? adminNote;
  final String? dataSummary;
  final String? latestLog;
  final List<String> executionLogs;

  bool get isOpen =>
      status == AdminDataRequestStatus.pending ||
      status == AdminDataRequestStatus.processing;

  /// 삭제(ERASURE) 요청은 전용 삭제 워크플로가 필요해 즉시 실행이 막혀 있다(백엔드 409).
  bool get canExecute =>
      status == AdminDataRequestStatus.processing &&
      type != AdminDataRequestType.dataErasure;

  bool get canApprove => status == AdminDataRequestStatus.pending;
}
