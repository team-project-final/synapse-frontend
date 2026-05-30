import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/confirm_dialog.dart';

/// 컨셉 입력 필드 보더 (큰 radius + 토큰 색).
OutlineInputBorder _conceptBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.border),
    );

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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
  final _mfaCodeController = TextEditingController();
  bool _mfaEnabled = false;
  bool _mfaLoading = false;
  bool _mfaVerifyLoading = false;
  bool _mfaVerified = false;
  MfaSetupResult? _mfaSetup;
  String? _mfaError;

  final List<String> _backupCodes = [
    'A1B2-C3D4',
    'E5F6-G7H8',
    'I9J0-K1L2',
    'M3N4-O5P6',
    'Q7R8-S9T0',
    'U1V2-W3X4',
    'Y5Z6-A7B8',
    'C9D0-E1F2',
  ];

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  Future<void> _toggleMfa(bool enabled) async {
    if (!enabled) {
      setState(() {
        _mfaEnabled = false;
        _mfaSetup = null;
        _mfaError = null;
        _mfaVerified = false;
        _mfaCodeController.clear();
      });
      return;
    }

    setState(() {
      _mfaLoading = true;
      _mfaError = null;
    });

    try {
      final setup = await ref.read(platformAuthApiProvider).setupMfa();
      if (!mounted) return;
      setState(() {
        _mfaEnabled = true;
        _mfaSetup = setup;
        _mfaLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaEnabled = false;
        _mfaLoading = false;
        _mfaError = 'MFA 설정을 시작하지 못했습니다.';
      });
    }
  }

  Future<void> _verifyMfa() async {
    final code = _mfaCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _mfaVerifyLoading = true;
      _mfaError = null;
    });

    try {
      final verified = await ref.read(platformAuthApiProvider).verifyMfa(code);
      if (!mounted) return;
      setState(() {
        _mfaVerified = verified;
        _mfaVerifyLoading = false;
        if (!verified) {
          _mfaError = 'MFA 코드가 일치하지 않습니다.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaVerifyLoading = false;
        _mfaError = 'MFA 코드를 검증하지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const ConceptViewHead(title: '보안 설정'),
        const SizedBox(height: AppSpacing.xl),

        // Password section
        Text('비밀번호 변경', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _currentPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '현재 비밀번호',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
          // TODO: 팀원 구현 — 비밀번호 변경 API 연동
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '새 비밀번호',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
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
          onChanged: _mfaLoading ? null : _toggleMfa,
        ),
        if (_mfaError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _mfaError!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '2단계 인증을 활성화하면 로그인 시 추가 확인 코드가 필요합니다.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ),

        // QR code placeholder + backup codes (shown when MFA enabled)
        if (_mfaEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_2,
                  size: 64,
                  color: AppColors.muted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'QR 코드 영역',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_mfaSetup != null) ...[
            Text('수동 입력 키', style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _mfaSetup!.secret,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            key: const Key('mfa-code-field'),
            controller: _mfaCodeController,
            decoration: const InputDecoration(
              labelText: '인증 코드',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const Key('mfa-verify-button'),
              onPressed: _mfaVerifyLoading ? null : _verifyMfa,
              child: _mfaVerifyLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('검증'),
            ),
          ),
          if (_mfaVerified) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'MFA 인증이 완료되었습니다.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('백업 코드', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '인증기 앱을 사용할 수 없을 때 이 코드를 사용하세요.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _backupCodes
                .map(
                  (code) => Chip(
                    label: Text(
                      code,
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    backgroundColor: AppColors.surface2,
                    side: const BorderSide(color: AppColors.border),
                  ),
                )
                .toList(),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Connected accounts section
        Text('연결된 계정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          leading: const Icon(
            Icons.g_mobiledata,
            size: 28,
            color: AppColors.info,
          ),
          title: const Text('Google'),
          subtitle: const Text('user@gmail.com'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — Google OAuth 연결 해제
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('연결 해제'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code, size: 24, color: AppColors.text),
          title: const Text('GitHub'),
          subtitle: const Text('github-user'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — GitHub OAuth 연결 해제
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('연결 해제'),
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
  // Category × channel grid state
  // Rows: 복습 리마인더, 커뮤니티 활동, 성취/배지, 시스템 알림
  // Columns: Push, Email, InApp
  final List<List<bool>> _notifGrid = [
    [true, false, true], // 복습 리마인더
    [true, true, true], // 커뮤니티 활동
    [true, false, true], // 성취/배지
    [false, true, true], // 시스템 알림
  ];

  static const _categoryLabels = ['복습 리마인더', '커뮤니티 활동', '성취/배지', '시스템 알림'];

  static const _channelLabels = ['Push', 'Email', 'InApp'];

  // RangeSlider는 start<=end를 요구하므로 방해금지 시간을 정렬된 범위로 둔다.
  RangeValues _quietHours = const RangeValues(0, 8);

  String _formatHour(double h) {
    final hour = h.toInt() % 24;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — platform-svc 알림 설정 API 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const ConceptViewHead(title: '알림 설정'),
        const SizedBox(height: AppSpacing.lg),
        Text('카테고리별 알림 설정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),

        // Category × channel grid table
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    '카테고리',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(
                  3,
                  (i) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        _channelLabels[i],
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...List.generate(4, (row) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      _categoryLabels[row],
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  ...List.generate(
                    3,
                    (col) => Center(
                      child: Switch(
                        value: _notifGrid[row][col],
                        onChanged: (v) =>
                            setState(() => _notifGrid[row][col] = v),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Quiet hours
        Text('방해금지 시간', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatHour(_quietHours.start),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            Text('~', style: textTheme.bodyMedium),
            Text(
              _formatHour(_quietHours.end),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _quietHours,
          min: 0,
          max: 24,
          divisions: 24,
          labels: RangeLabels(
            _formatHour(_quietHours.start),
            _formatHour(_quietHours.end),
          ),
          onChanged: (v) => setState(() => _quietHours = v),
        ),
        Text(
          '이 시간 동안 Push 알림이 비활성화됩니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

// ── DataSettingsScreen (SCR-W-SETTINGS-004) ──

class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
  String _exportFormat = 'JSON';
  bool _isExporting = false;

  Future<void> _mockExport(String format) async {
    setState(() => _isExporting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const ConceptViewHead(title: '데이터 관리'),
        const SizedBox(height: AppSpacing.xl),

        // Export section
        Text('데이터 내보내기', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '노트, 카드, 태그를 선택한 형식으로 내보낼 수 있습니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _exportFormat,
          decoration: InputDecoration(
            labelText: '형식',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
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

        // Export progress indicator
        if (_isExporting) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
        ],

        // Export buttons
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: _isExporting ? null : () => _mockExport('Markdown'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Markdown'),
            ),
            OutlinedButton.icon(
              onPressed: _isExporting ? null : () => _mockExport('PDF'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
            OutlinedButton.icon(
              onPressed: _isExporting ? null : () => _mockExport('전체'),
              icon: const Icon(Icons.download_outlined),
              label: const Text('전체 데이터'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Import section
        Text('데이터 가져오기', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Anki (.apkg), Markdown 파일을 가져올 수 있습니다.\n기존 데이터와 병합되며 중복 항목은 무시됩니다.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
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
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            side: const BorderSide(color: AppColors.error),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '계정 삭제',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '계정을 삭제하면 모든 노트, 카드, 학습 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: '계정 삭제',
                      content:
                          '정말로 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.',
                      confirmLabel: '삭제',
                      isDestructive: true,
                    );
                    if (confirmed == true) {
                      // TODO: 팀원 구현 — 계정 삭제 API 연동
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('계정 삭제'),
                ),
              ],
            ),
          ),
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
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: dialogRole,
                    decoration: InputDecoration(
                      labelText: '역할',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
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
