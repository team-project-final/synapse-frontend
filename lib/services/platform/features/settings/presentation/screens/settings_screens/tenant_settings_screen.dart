part of '../settings_screens.dart';

// ── TenantSettingsScreen (SCR-W-SETTINGS-005) ──

class TenantSettingsScreen extends ConsumerStatefulWidget {
  const TenantSettingsScreen({super.key});

  @override
  ConsumerState<TenantSettingsScreen> createState() =>
      _TenantSettingsScreenState();
}

class _TenantSettingsScreenState extends ConsumerState<TenantSettingsScreen> {
  final _inviteEmailController = TextEditingController();
  final _workspaceNameController = TextEditingController(
    text: 'Synapse 팀',
  ); // TODO: 팀원 구현 — 테넌트 정보 연동

  // TODO: 팀원 구현 — platform-svc 멤버 목록 API 연동
  final _mockMembers = [
    {'name': '김시냅스', 'email': 'admin@example.com', 'role': '관리자'},
    {'name': '이러닝', 'email': 'user1@example.com', 'role': '멤버'},
    {'name': '박지식', 'email': 'user2@example.com', 'role': '멤버'},
    {'name': '최뷰어', 'email': 'viewer@example.com', 'role': '뷰어'},
  ];

  @override
  void dispose() {
    _inviteEmailController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  void _showInviteDialog() {
    _inviteEmailController.clear();
    String dialogRole = '멤버';
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('멤버 초대'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _inviteEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '이메일 주소',
                      hintText: 'user@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: dialogRole,
                    decoration: InputDecoration(
                      labelText: '역할',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '관리자', child: Text('관리자')),
                      DropdownMenuItem(value: '멤버', child: Text('멤버')),
                      DropdownMenuItem(value: '뷰어', child: Text('뷰어')),
                    ],
                    onChanged: (v) => setDialogState(() => dialogRole = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — platform-svc 초대 전송 API 연동
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('초대 전송'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const ConceptViewHead(title: '테넌트 관리'),
        const SizedBox(height: AppSpacing.xl),

        // Invite button
        FilledButton.icon(
          onPressed: _showInviteDialog,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('멤버 초대'),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Members section
        Text('멤버 관리', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ..._mockMembers.map(
          (member) => Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  member['name']!.substring(0, 1),
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
              title: Text(member['name']!, style: textTheme.bodyMedium),
              subtitle: Text(
                member['email']!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: member['role'] == '관리자'
                          ? colorScheme.primaryContainer
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      member['role']!,
                      style: textTheme.labelSmall?.copyWith(
                        color: member['role'] == '관리자'
                            ? colorScheme.primary
                            : AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: 팀원 구현 — 역할 변경/삭제 API 연동
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'role_admin',
                        child: Text('관리자로 변경'),
                      ),
                      const PopupMenuItem(
                        value: 'role_member',
                        child: Text('멤버로 변경'),
                      ),
                      const PopupMenuItem(
                        value: 'role_viewer',
                        child: Text('뷰어로 변경'),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text(
                          '멤버 삭제',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Tenant info section
        Text('테넌트 정보', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _workspaceNameController,
          decoration: InputDecoration(
            labelText: '워크스페이스 이름',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
          // TODO: 팀원 구현 — 테넌트 정보 저장 연동
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — platform-svc 테넌트 정보 저장 API 연동
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
