import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── ProfileSettingsScreen (SCR-W-SETTINGS-001) ──

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState
    extends ConsumerState<ProfileSettingsScreen> {
  final _nameController =
      TextEditingController(text: '김시냅스'); // TODO: 팀원 구현 — 프로필 데이터 연동
  final _emailController =
      TextEditingController(text: 'user@example.com'); // TODO: 팀원 구현 — 이메일 연동
  String _selectedLanguage = '한국어';
  String _selectedTimezone = 'Asia/Seoul (UTC+9)';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('프로필 설정', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        // Avatar
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  '김',
                  style: textTheme.headlineMedium
                      ?.copyWith(color: colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 팀원 구현 — 프로필 사진 업로드
                },
                child: const Text('사진 변경'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Display name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '표시 이름',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 표시 이름 저장 연동
        ),
        const SizedBox(height: AppSpacing.md),
        // Email (read-only)
        TextFormField(
          controller: _emailController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: '이메일',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            filled: true,
            fillColor: AppColors.stone100,
          ),
          style: textTheme.bodyMedium
              ?.copyWith(color: AppColors.stone400),
          // TODO: 팀원 구현 — 이메일 (인증 서비스에서 가져옴, 읽기 전용)
        ),
        const SizedBox(height: AppSpacing.md),
        // Language dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedLanguage,
          decoration: InputDecoration(
            labelText: '언어',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          items: const [
            DropdownMenuItem(value: '한국어', child: Text('한국어')),
            DropdownMenuItem(value: 'English', child: Text('English')),
          ],
          onChanged: (v) => setState(() => _selectedLanguage = v!),
          // TODO: 팀원 구현 — 언어 설정 저장
        ),
        const SizedBox(height: AppSpacing.md),
        // Timezone dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedTimezone,
          decoration: InputDecoration(
            labelText: '타임존',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: 'Asia/Seoul (UTC+9)',
                child: Text('Asia/Seoul (UTC+9)')),
            DropdownMenuItem(
                value: 'UTC', child: Text('UTC')),
            DropdownMenuItem(
                value: 'America/New_York (UTC-5)',
                child: Text('America/New_York (UTC-5)')),
          ],
          onChanged: (v) => setState(() => _selectedTimezone = v!),
          // TODO: 팀원 구현 — 타임존 설정 저장
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — platform-svc 프로필 저장 API 연동
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// ── SecuritySettingsScreen (SCR-W-SETTINGS-002) ──

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _mfaEnabled = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('보안 설정', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // Password section
        Text('비밀번호 변경', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _currentPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '현재 비밀번호',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 비밀번호 변경 API 연동
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '새 비밀번호',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            // TODO: 팀원 구현 — auth-svc 비밀번호 변경 API 연동
          },
          child: const Text('변경'),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // MFA section
        Text('2단계 인증 (MFA)', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          title: const Text('TOTP 인증기'),
          subtitle: const Text('Google Authenticator 등 앱을 사용한 2단계 인증'),
          value: _mfaEnabled,
          onChanged: (v) {
            setState(() => _mfaEnabled = v);
            // TODO: 팀원 구현 — auth-svc MFA 설정 API 연동
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '2단계 인증을 활성화하면 로그인 시 추가 확인 코드가 필요합니다.',
            style: textTheme.bodySmall
                ?.copyWith(color: AppColors.stone400),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Connected accounts section
        Text('연결된 계정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          leading: const Icon(Icons.g_mobiledata, size: 28,
              color: AppColors.info),
          title: const Text('Google'),
          subtitle: const Text('연결되지 않음'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — Google OAuth 연결
            },
            child: const Text('연결하기'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code, size: 24,
              color: AppColors.stone700),
          title: const Text('GitHub'),
          subtitle: const Text('연결되지 않음'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — GitHub OAuth 연결
            },
            child: const Text('연결하기'),
          ),
        ),
      ],
    );
  }
}

// ── NotificationSettingsScreen (SCR-W-SETTINGS-003) ──

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _reviewReminder = true;
  bool _communityNotif = true;
  bool _achievementNotif = true;
  bool _emailNotif = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 설정 API 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('알림 설정', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Text('알림 설정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          title: const Text('복습 리마인더'),
          subtitle: const Text('매일 복습 시간에 알림을 받습니다'),
          value: _reviewReminder,
          onChanged: (v) => setState(() => _reviewReminder = v),
        ),
        SwitchListTile(
          title: const Text('커뮤니티 알림'),
          subtitle: const Text('그룹 활동 및 새 콘텐츠 알림'),
          value: _communityNotif,
          onChanged: (v) => setState(() => _communityNotif = v),
        ),
        SwitchListTile(
          title: const Text('성취/배지 알림'),
          subtitle: const Text('레벨업 및 배지 획득 알림'),
          value: _achievementNotif,
          onChanged: (v) => setState(() => _achievementNotif = v),
        ),
        SwitchListTile(
          title: const Text('이메일 알림'),
          subtitle: const Text('이메일로 주요 알림을 받습니다'),
          value: _emailNotif,
          onChanged: (v) => setState(() => _emailNotif = v),
        ),
        const Divider(),
        ListTile(
          title: const Text('방해금지 시간'),
          subtitle: const Text('22:00 ~ 08:00'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — 방해금지 시간 설정 다이얼로그
            },
            child: const Text('설정'),
          ),
        ),
      ],
    );
  }
}

// ── DataSettingsScreen (SCR-W-SETTINGS-004) ──

class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() =>
      _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
  String _exportFormat = 'JSON';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('데이터 관리', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // Export section
        Text('데이터 내보내기', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '노트, 카드, 태그를 선택한 형식으로 내보낼 수 있습니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: _exportFormat,
          decoration: InputDecoration(
            labelText: '형식',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'JSON', child: Text('JSON')),
            DropdownMenuItem(value: 'CSV', child: Text('CSV')),
            DropdownMenuItem(value: 'Markdown', child: Text('Markdown')),
          ],
          onChanged: (v) => setState(() => _exportFormat = v!),
          // TODO: 팀원 구현 — 내보내기 형식 선택
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: 팀원 구현 — platform-svc 데이터 내보내기 API 연동
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('내보내기 요청'),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Import section
        Text('데이터 가져오기', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Anki (.apkg), Markdown 파일을 가져올 수 있습니다.\n기존 데이터와 병합되며 중복 항목은 무시됩니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: 팀원 구현 — 파일 선택 및 가져오기 API 연동
          },
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('파일 선택'),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Danger zone
        Text(
          '계정 삭제',
          style: textTheme.titleMedium
              ?.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '계정을 삭제하면 모든 노트, 카드, 학습 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            // TODO: 팀원 구현 — 계정 삭제 확인 다이얼로그 및 API 연동
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          child: const Text('계정 삭제'),
        ),
      ],
    );
  }
}

// ── TenantSettingsScreen (SCR-W-SETTINGS-005) ──

class TenantSettingsScreen extends ConsumerStatefulWidget {
  const TenantSettingsScreen({super.key});

  @override
  ConsumerState<TenantSettingsScreen> createState() =>
      _TenantSettingsScreenState();
}

class _TenantSettingsScreenState extends ConsumerState<TenantSettingsScreen> {
  final _inviteEmailController = TextEditingController();
  final _workspaceNameController =
      TextEditingController(text: 'Synapse 팀'); // TODO: 팀원 구현 — 테넌트 정보 연동

  // TODO: 팀원 구현 — platform-svc 멤버 목록 API 연동
  final _mockMembers = [
    {'name': '김시냅스', 'email': 'admin@example.com', 'role': '관리자'},
    {'name': '이러닝', 'email': 'user1@example.com', 'role': '멤버'},
    {'name': '박지식', 'email': 'user2@example.com', 'role': '멤버'},
  ];

  @override
  void dispose() {
    _inviteEmailController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('테넌트 관리', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // Members section
        Text('멤버 관리', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ..._mockMembers.map((member) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    member['name']!.substring(0, 1),
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                title: Text(member['name']!,
                    style: textTheme.bodyMedium),
                subtitle: Text(member['email']!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone400)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: member['role'] == '관리자'
                            ? colorScheme.primaryContainer
                            : AppColors.stone100,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Text(member['role']!,
                          style: textTheme.labelSmall?.copyWith(
                              color: member['role'] == '관리자'
                                  ? colorScheme.primary
                                  : AppColors.stone500)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: 팀원 구현 — 역할 변경 API 연동
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('역할 변경'),
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Invite section
        Text('초대', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _inviteEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일 주소',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
                // TODO: 팀원 구현 — 초대 이메일 입력
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: () {
                // TODO: 팀원 구현 — platform-svc 초대 전송 API 연동
              },
              child: const Text('초대 전송'),
            ),
          ],
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
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
