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
  final _workspaceNameController = TextEditingController();

  bool _loading = true;
  String? _error;
  TenantInfo? _tenant;
  List<TenantMember> _members = const [];
  bool _saving = false;
  bool _inviting = false;
  String? _busyMemberId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _inviteEmailController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(tenantApiProvider);
      final tenant = await api.getMyTenant();
      final members = await api.listMembers();
      if (!mounted) return;
      setState(() {
        _tenant = tenant;
        _members = members.items;
        _workspaceNameController.text = tenant.name;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '테넌트 정보를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _reloadMembers() async {
    try {
      final members = await ref.read(tenantApiProvider).listMembers();
      if (!mounted) return;
      setState(() => _members = members.items);
    } catch (_) {
      // 목록 갱신 실패는 조용히 무시(액션 자체는 이미 성공/실패가 안내됨).
    }
  }

  Future<void> _saveTenant() async {
    final name = _workspaceNameController.text.trim();
    if (name.isEmpty) {
      _snack('테넌트 이름을 입력해주세요.');
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(tenantApiProvider)
          .updateMyTenant(name: name);
      if (!mounted) return;
      setState(() {
        _tenant = updated;
        _saving = false;
      });
      _snack('테넌트 정보가 저장되었습니다.');
    } on TenantApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('테넌트 정보 저장에 실패했습니다.');
    }
  }

  Future<void> _invite(String email, String role) async {
    setState(() => _inviting = true);
    try {
      await ref
          .read(tenantApiProvider)
          .createInvitation(email: email, role: role);
      if (!mounted) return;
      setState(() => _inviting = false);
      _snack('초대를 전송했습니다.');
    } on TenantApiException catch (error) {
      if (!mounted) return;
      setState(() => _inviting = false);
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _inviting = false);
      _snack('초대 전송에 실패했습니다.');
    }
  }

  Future<void> _changeRole(TenantMember member, String role) async {
    setState(() => _busyMemberId = member.userId);
    try {
      await ref.read(tenantApiProvider).updateMemberRole(member.userId, role);
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      await _reloadMembers();
      _snack('역할을 변경했습니다.');
    } on TenantApiException catch (error) {
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      _snack('역할 변경에 실패했습니다.');
    }
  }

  Future<void> _removeMember(TenantMember member) async {
    final label = (member.displayName?.isNotEmpty ?? false)
        ? member.displayName!
        : (member.email ?? '이 멤버');
    final confirmed = await ConfirmDialog.show(
      context,
      title: '멤버 삭제',
      content: '$label 님을 테넌트에서 삭제하시겠습니까?',
      confirmLabel: '삭제',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyMemberId = member.userId);
    try {
      await ref.read(tenantApiProvider).removeMember(member.userId);
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      await _reloadMembers();
      _snack('멤버를 삭제했습니다.');
    } on TenantApiException catch (error) {
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      _snack('멤버 삭제에 실패했습니다.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 관리 가능: 매니저(owner/admin) + 본인 아님 + 대상이 소유자 아님.
  bool _canManage(TenantMember member, String? currentUserId) {
    return (_tenant?.isManager ?? false) &&
        member.userId != currentUserId &&
        member.role != 'owner';
  }

  void _showInviteDialog() {
    _inviteEmailController.clear();
    String dialogRole = 'member';
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
                      DropdownMenuItem(value: 'admin', child: Text('관리자')),
                      DropdownMenuItem(value: 'member', child: Text('멤버')),
                      DropdownMenuItem(value: 'viewer', child: Text('뷰어')),
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
                    final email = _inviteEmailController.text.trim();
                    if (email.isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    _invite(email, dialogRole);
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
    final isManager = _tenant?.isManager ?? false;
    final currentUserId = userIdFromAccessToken(
      ref.read(authNotifierProvider).accessToken,
    );

    return ConceptPage(
      maxWidth: 560,
      children: [
        const ConceptViewHead(title: '테넌트 관리'),
        const SizedBox(height: AppSpacing.xl),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
              ],
            ),
          )
        else ...[
          if (isManager) ...[
            FilledButton.icon(
              onPressed: _inviting ? null : _showInviteDialog,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('멤버 초대'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          Text('멤버 관리', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ..._members.map(
            (member) =>
                _memberCard(member, currentUserId, textTheme, colorScheme),
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),

          Text('테넌트 정보', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _workspaceNameController,
            readOnly: !isManager,
            decoration: InputDecoration(
              labelText: '워크스페이스 이름',
              border: _conceptBorder(),
              enabledBorder: _conceptBorder(),
              filled: true,
              fillColor: isManager ? AppColors.surface : AppColors.surface2,
            ),
          ),
          if (isManager) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _saving ? null : _saveTenant,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _memberCard(
    TenantMember member,
    String? currentUserId,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final name = (member.displayName?.isNotEmpty ?? false)
        ? member.displayName!
        : (member.email ?? member.userId);
    final isAdmin = member.role == 'owner' || member.role == 'admin';
    final busy = _busyMemberId == member.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name.substring(0, 1) : '?',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        title: Text(name, style: textTheme.bodyMedium),
        subtitle: member.email != null
            ? Text(
                member.email!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: isAdmin ? colorScheme.primaryContainer : AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                tenantRoleLabel(member.role),
                style: textTheme.labelSmall?.copyWith(
                  color: isAdmin ? colorScheme.primary : AppColors.muted,
                ),
              ),
            ),
            if (_canManage(member, currentUserId)) ...[
              const SizedBox(width: AppSpacing.xs),
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'remove') {
                      _removeMember(member);
                    } else {
                      _changeRole(member, value);
                    }
                  },
                  itemBuilder: (context) => [
                    // 현재 역할은 메뉴에서 제외(불필요한 동일 역할 변경 방지).
                    if (member.role != 'admin')
                      const PopupMenuItem(
                        value: 'admin',
                        child: Text('관리자로 변경'),
                      ),
                    if (member.role != 'member')
                      const PopupMenuItem(
                        value: 'member',
                        child: Text('멤버로 변경'),
                      ),
                    if (member.role != 'viewer')
                      const PopupMenuItem(
                        value: 'viewer',
                        child: Text('뷰어로 변경'),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('멤버 삭제', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
