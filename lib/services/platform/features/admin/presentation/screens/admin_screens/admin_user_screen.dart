part of '../admin_screens.dart';

// ============================================================================
// AdminUserScreen (SCR-A-ADMIN-003)
// platform-svc /api/v1/admin/users 연동 (목록/검색/필터/페이지/상태변경/삭제)
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

String? _userStatusFromLabel(String? label) {
  switch (label) {
    case '활성':
      return 'active';
    case '정지':
      return 'suspended';
    case '삭제됨':
      return 'deleted';
    default:
      return null;
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
  AdminPage<AdminUser>? _data;
  bool _loading = true;
  String? _query;
  String? _statusFilter;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(listAdminUsersUseCaseProvider)(
        query: _query,
        status: _statusFilter,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_data != null) _showError('목록을 새로고침하지 못했습니다.');
    }
  }

  void _onSearch(String value) {
    _query = value.trim().isEmpty ? null : value.trim();
    _page = 0;
    _load();
  }

  void _onFilter(String? label) {
    _statusFilter = _userStatusFromLabel(label);
    _page = 0;
    _load();
  }

  void _onPage(int page) {
    _page = page;
    _load();
  }

  Future<void> _changeStatus(AdminUser user, String status) async {
    try {
      await ref.read(changeUserStatusUseCaseProvider)(user.id, status);
      await _load();
    } catch (_) {
      _showError('상태 변경에 실패했습니다.');
    }
  }

  Future<void> _deleteUser(AdminUser user) async {
    try {
      await ref.read(deleteAdminUserUseCaseProvider)(user.id);
      await _load();
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final data = _data;
    if (data == null) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      return _AdminErrorRetry(onRetry: _load);
    }
    return Column(
      children: [
        _AdminTopLoadingBar(loading: _loading),
        Expanded(child: _buildGrid(data)),
      ],
    );
  }

  Widget _buildGrid(AdminPage<AdminUser> data) {
    return AdminDataGrid(
      searchHint: '이메일 또는 이름 검색...',
      emptyMessage: '조건에 맞는 사용자가 없습니다.',
      filters: const ['활성', '정지', '삭제됨'],
      onSearch: _onSearch,
      onFilterSelected: _onFilter,
      page: data.page,
      totalPages: data.totalPages,
      totalElements: data.totalElements,
      onPageChanged: _onPage,
      columns: const [
        DataColumn(label: Text('이메일')),
        DataColumn(label: Text('이름')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('가입일')),
      ],
      rows: data.content.map((user) {
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
            DataCell(_StatusBadge(status: _userStatusLabel(user.status))),
            DataCell(Text(_formatDate(user.createdAt))),
          ],
        );
      }).toList(),
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
          if (user.suspendedAt != null)
            Text('정지일시: ${_formatDate(user.suspendedAt)}'),
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
