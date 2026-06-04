part of '../admin_screens.dart';

// ============================================================================
// AdminUserScreen (SCR-A-ADMIN-003)
// ============================================================================

class _MockUser {
  const _MockUser({
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.joinedAt,
  });
  final String email;
  final String name;
  final String role;
  final String status;
  final String joinedAt;
}

// TODO: 팀원 구현 — platform-svc 사용자 목록 API 연동
const _mockUsers = [
  _MockUser(
    email: 'admin@synapse.io',
    name: '김관리',
    role: 'ADMIN',
    status: '활성',
    joinedAt: '2025-01-10',
  ),
  _MockUser(
    email: 'user1@example.com',
    name: '이학생',
    role: 'USER',
    status: '활성',
    joinedAt: '2025-03-22',
  ),
  _MockUser(
    email: 'user2@example.com',
    name: '박선생',
    role: 'MODERATOR',
    status: '활성',
    joinedAt: '2025-05-15',
  ),
  _MockUser(
    email: 'banned@test.com',
    name: '최정지',
    role: 'USER',
    status: '정지',
    joinedAt: '2025-06-01',
  ),
  _MockUser(
    email: 'deleted@old.com',
    name: '정탈퇴',
    role: 'USER',
    status: '삭제됨',
    joinedAt: '2024-12-01',
  ),
];

class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('사용자 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '이메일 또는 이름 검색...',
              filters: const ['활성', '정지', '삭제됨'],
              columns: const [
                DataColumn(label: Text('이메일')),
                DataColumn(label: Text('이름')),
                DataColumn(label: Text('역할')),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('가입일')),
              ],
              rows: _mockUsers.indexed.map((entry) {
                final u = entry.$2;
                return DataRow(
                  onSelectChanged: (_) {
                    // TODO: 팀원 구현 — 사용자 상세 다이얼로그
                    showDialog<void>(
                      context: context,
                      builder: (_) => _UserDetailDialog(user: u),
                    );
                  },
                  cells: [
                    DataCell(Text(u.email)),
                    DataCell(Text(u.name)),
                    DataCell(Text(u.role)),
                    DataCell(_StatusBadge(status: u.status)),
                    DataCell(Text(u.joinedAt)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({required this.user});
  final _MockUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(user.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이메일: ${user.email}'),
          Text('역할: ${user.role}'),
          Text('상태: ${user.status}'),
          Text('가입일: ${user.joinedAt}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        if (user.status == '활성')
          FilledButton(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: '사용자 정지',
                content: '${user.name} 사용자를 정지하시겠습니까?',
                confirmLabel: '정지',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('정지'),
          ),
      ],
    );
  }
}
