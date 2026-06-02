part of '../settings_screens.dart';

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

    return ConceptPage(
      maxWidth: 560,
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
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
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
