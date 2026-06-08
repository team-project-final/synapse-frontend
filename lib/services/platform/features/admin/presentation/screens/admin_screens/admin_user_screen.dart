part of '../admin_screens.dart';

// ============================================================================
// AdminUserScreen (SCR-A-ADMIN-003)
// platform-svc /api/v1/admin/users 연동 (목록/상태변경/삭제)
// ============================================================================

String _userStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return '활성';
    case 'suspended':
      return '정지';
    case 'deleted':
      return '삭제됨';
    default:
      return status;
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$d';
}

class AdminUserScreen extends ConsumerStatefulWidget {
  const AdminUserScreen({super.key});

  @override
  ConsumerState<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends ConsumerState<AdminUserScreen> {
  late Future<AdminPage<AdminUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<AdminPage<AdminUser>> _fetchUsers() {
    return ref.read(listAdminUsersUseCaseProvider)();
  }

  void _reload() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  Future<void> _changeStatus(AdminUser user, String status) async {
    try {
      await ref.read(changeUserStatusUseCaseProvider)(user.id, status);
      if (mounted) _reload();
    } catch (_) {
      _showError('상태 변경에 실패했습니다.');
    }
  }

  Future<void> _deleteUser(AdminUser user) async {
    try {
      await ref.read(deleteAdminUserUseCaseProvider)(user.id);
      if (mounted) _reload();
    } catch (_) {
      _showError('삭제에 실패했습니다.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('사용자 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: FutureBuilder<AdminPage<AdminUser>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('사용자 목록을 불러오지 못했습니다.'),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: _reload,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }
                final users = snapshot.data?.content ?? const <AdminUser>[];
                // TODO: 팀원 구현 — 검색(q)/상태필터/페이지네이션을 API 파라미터와 연동
                //   (현재 AdminDataGrid는 표시 전용이라 1페이지만 노출)
                return AdminDataGrid(
                  searchHint: '이메일 또는 이름 검색...',
                  filters: const ['활성', '정지', '삭제됨'],
                  columns: const [
                    DataColumn(label: Text('이메일')),
                    DataColumn(label: Text('이름')),
                    DataColumn(label: Text('상태')),
                    DataColumn(label: Text('가입일')),
                  ],
                  rows: users.map((user) {
                    return DataRow(
                      onSelectChanged: (_) {
                        showDialog<void>(
                          context: context,
                          builder: (_) => _UserDetailDialog(
                            user: user,
                            onSuspend: () => _changeStatus(user, 'suspended'),
                            onActivate: () => _changeStatus(user, 'active'),
                            onDelete: () => _deleteUser(user),
                          ),
                        );
                      },
                      cells: [
                        DataCell(Text(user.email)),
                        DataCell(Text(user.displayName)),
                        DataCell(
                          _StatusBadge(status: _userStatusLabel(user.status)),
                        ),
                        DataCell(Text(_formatDate(user.createdAt))),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({
    required this.user,
    required this.onSuspend,
    required this.onActivate,
    required this.onDelete,
  });

  final AdminUser user;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = user.status.toLowerCase() == 'active';
    return AlertDialog(
      title: Text(user.displayName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이메일: ${user.email}'),
          Text('상태: ${_userStatusLabel(user.status)}'),
          Text('가입일: ${_formatDate(user.createdAt)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        TextButton(
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: '사용자 삭제',
              content: '${user.displayName} 사용자를 삭제하시겠습니까?',
              confirmLabel: '삭제',
              isDestructive: true,
            );
            if (confirmed == true && context.mounted) {
              Navigator.pop(context);
              onDelete();
            }
          },
          child: const Text('삭제', style: TextStyle(color: AppColors.error)),
        ),
        if (isActive)
          FilledButton(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: '사용자 정지',
                content: '${user.displayName} 사용자를 정지하시겠습니까?',
                confirmLabel: '정지',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                Navigator.pop(context);
                onSuspend();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('정지'),
          )
        else
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onActivate();
            },
            child: const Text('활성화'),
          ),
      ],
    );
  }
}
