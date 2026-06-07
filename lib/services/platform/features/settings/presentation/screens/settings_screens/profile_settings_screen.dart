part of '../settings_screens.dart';

// ── ProfileSettingsScreen (SCR-W-SETTINGS-001) ──

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _nameController = TextEditingController(
    text: '김시냅스',
  ); // TODO: 팀원 구현 — 프로필 데이터 연동
  final _emailController = TextEditingController(
    text: 'user@example.com',
  ); // TODO: 팀원 구현 — 이메일 연동
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

    return ConceptPage(
      maxWidth: 560,
      children: [
        const ConceptViewHead(title: '프로필 설정'),
        const SizedBox(height: AppSpacing.xl),
        // Avatar with camera overlay
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      '김',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          // TODO: 팀원 구현 — 프로필 사진 업로드
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                      ),
                    ),
                  ),
                ],
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
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
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
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface2,
          ),
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          // TODO: 팀원 구현 — 이메일 (인증 서비스에서 가져옴, 읽기 전용)
        ),
        const SizedBox(height: AppSpacing.md),
        // Language dropdown
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _selectedLanguage,
          decoration: InputDecoration(
            labelText: '언어',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: const [
            DropdownMenuItem(value: '한국어', child: Text('한국어')),
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: '日本語', child: Text('日本語')),
          ],
          onChanged: (v) => setState(() => _selectedLanguage = v!),
          // TODO: 팀원 구현 — 언어 설정 저장
        ),
        const SizedBox(height: AppSpacing.md),
        // Timezone dropdown
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _selectedTimezone,
          decoration: InputDecoration(
            labelText: '타임존',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Asia/Seoul (UTC+9)',
              child: Text('Asia/Seoul (UTC+9)'),
            ),
            DropdownMenuItem(value: 'UTC', child: Text('UTC')),
            DropdownMenuItem(
              value: 'America/New_York (UTC-5)',
              child: Text('America/New_York (UTC-5)'),
            ),
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
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await ConfirmDialog.show(
              context,
              title: '로그아웃',
              content: '로그아웃하시겠습니까?',
              confirmLabel: '로그아웃',
              isDestructive: true,
            );
            if (ok == true) {
              // 상태가 unauthenticated가 되면 라우터 redirect가 /login으로 보낸다.
              await ref.read(authNotifierProvider.notifier).logout();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('로그아웃'),
        ),
      ],
    );
  }
}
