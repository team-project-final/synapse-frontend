import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';

/// 관리자 기능 도메인 포트. HTTP 라이브러리에 무지하다(dio import 금지).
abstract class AdminRepository {
  Future<AdminPage<AdminUser>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  });

  Future<void> changeUserStatus(String id, String status);

  Future<void> deleteUser(String id);
}
