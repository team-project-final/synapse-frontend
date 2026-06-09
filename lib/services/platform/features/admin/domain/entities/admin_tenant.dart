/// 관리자 테넌트 관리 화면이 다루는 테넌트 도메인 엔티티.
class AdminTenant {
  const AdminTenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.plan,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String slug;
  final String plan;
  final String status;
  final DateTime? createdAt;
}
