part of '../settings_screens.dart';

// ── ProfileSettingsScreen (SCR-W-SETTINGS-001) ──

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedLanguage = '한국어';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadProfile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(accountApiProvider).getProfile();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.displayName ?? '';
        _emailController.text = profile.email ?? '';
        _selectedLanguage = _languageLabel(profile.language);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '프로필을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '표시 이름을 입력해주세요.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(accountApiProvider).updateProfile(
            displayName: name,
            language: _languageCode(_selectedLanguage),
          );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
    } on AccountApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '프로필 저장에 실패했습니다.';
      });
    }
  }

  // 백엔드 locale 코드 ↔ UI 표시값 매핑.
  String _languageLabel(String? code) {
    return switch (code) {
      'en-US' || 'en' => 'English',
      'ja-JP' || 'ja' => '日本語',
      _ => '한국어',
    };
  }

  String _languageCode(String label) {
    return switch (label) {
      'English' => 'en-US',
      '日本語' => 'ja-JP',
      _ => 'ko-KR',
    };
  }

  String _avatarInitial() {
    final name = _nameController.text.trim();
    return name.isNotEmpty ? name.substring(0, 1) : '?';
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
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
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
                        _avatarInitial(),
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
                            // TODO: 팀원 구현 — 프로필 사진 업로드 (백엔드 업로드 API 대기)
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
                    // TODO: 팀원 구현 — 프로필 사진 업로드 (백엔드 업로드 API 대기)
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
          ),
          const SizedBox(height: AppSpacing.md),
          // Email (read-only, 인증 서비스 소유)
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
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
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
      ],
    );
  }
}
