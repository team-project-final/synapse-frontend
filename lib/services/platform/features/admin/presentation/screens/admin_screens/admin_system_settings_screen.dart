part of '../admin_screens.dart';

// ============================================================================
// AdminSystemSettingsScreen (SCR-A-ADMIN-005)
// ============================================================================

class AdminSystemSettingsScreen extends ConsumerStatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  ConsumerState<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState
    extends ConsumerState<AdminSystemSettingsScreen>
    with TickerProviderStateMixin {
  static const int _rateLimitMin = 1;
  static const int _rateLimitMax = 10000;

  late final TabController _tabController;
  final _rateLimitController = TextEditingController();

  AdminSettings? _settings;
  List<AdminFeatureFlag> _flags = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rateLimitController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = await ref.read(getAdminSettingsUseCaseProvider)();
      if (!mounted) return;
      setState(() {
        _applySettings(settings);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '시스템 설정을 불러오지 못했습니다.';
      });
    }
  }

  void _applySettings(AdminSettings settings) {
    _settings = settings;
    _flags = settings.featureFlags;
    _rateLimitController.text = '${settings.rateLimitPerMinute}';
  }

  int? _parseRateLimit() {
    final value = int.tryParse(_rateLimitController.text.trim());
    if (value == null || value < _rateLimitMin || value > _rateLimitMax) {
      return null;
    }
    return value;
  }

  Future<void> _save() async {
    final rateLimit = _parseRateLimit();
    if (rateLimit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('속도 제한은 $_rateLimitMin~$_rateLimitMax 사이여야 합니다.'),
        ),
      );
      _tabController.animateTo(2);
      return;
    }

    setState(() => _saving = true);
    try {
      final saved = await ref.read(updateAdminSettingsUseCaseProvider)(
        AdminSettingsUpdate(
          featureFlags: _flags,
          rateLimitPerMinute: rateLimit,
        ),
      );
      if (!mounted) return;
      setState(() {
        _applySettings(saved);
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 저장되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final settings = _settings;
    if (_error != null || settings == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? '시스템 설정을 불러오지 못했습니다.'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('시스템 설정', style: textTheme.headlineSmall),
              const Spacer(),
              FilledButton(
                key: const Key('admin-settings-save'),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '플랜 할당량'),
              Tab(text: '피처 플래그'),
              Tab(text: '속도 제한'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Plan Quota (조회 전용 — 백엔드 수정 계약 없음) ──
                SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.surface2,
                      ),
                      columns: const [
                        DataColumn(label: Text('플랜')),
                        DataColumn(label: Text('노트'), numeric: true),
                        DataColumn(label: Text('카드'), numeric: true),
                        DataColumn(label: Text('AI 토큰/월'), numeric: true),
                        DataColumn(label: Text('AI 생성/월'), numeric: true),
                        DataColumn(label: Text('스토리지'), numeric: true),
                        DataColumn(label: Text('멤버 한도'), numeric: true),
                      ],
                      rows: settings.planQuotas.map((quota) {
                        return DataRow(
                          cells: [
                            DataCell(Text(quota.displayName)),
                            DataCell(Text(_quotaText(quota.maxNotes))),
                            DataCell(Text(_quotaText(quota.maxCards))),
                            DataCell(
                              Text(_quotaText(quota.maxAiTokensMonthly)),
                            ),
                            DataCell(
                              Text(
                                _quotaText(quota.maxAiCardGenerationsMonthly),
                              ),
                            ),
                            DataCell(Text(_storageText(quota.maxStorageBytes))),
                            DataCell(Text(_quotaText(quota.maxUsersPerTenant))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Tab 2: Feature Flags ──
                ListView(
                  children: _flags.map((flag) {
                    return SwitchListTile(
                      key: Key('flag-${flag.key}'),
                      title: Text(flag.label),
                      subtitle: Text(
                        flag.key,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      value: flag.enabled,
                      onChanged: (v) {
                        setState(() {
                          _flags = _flags
                              .map(
                                (f) => f.key == flag.key
                                    ? f.copyWith(enabled: v)
                                    : f,
                              )
                              .toList();
                        });
                      },
                    );
                  }).toList(),
                ),

                // ── Tab 3: Rate Limit ──
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API 요청 속도 제한 (req/min)',
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        key: const Key('admin-settings-rate-limit'),
                        controller: _rateLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '요청 수/분',
                          helperText: '$_rateLimitMin ~ $_rateLimitMax',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _quotaText(int? value) => value == null ? '무제한' : _grouped(value);

  String _storageText(int? bytes) {
    if (bytes == null) return '무제한';
    final gb = bytes / (1024 * 1024 * 1024);
    final text = gb == gb.roundToDouble()
        ? gb.toInt().toString()
        : gb.toStringAsFixed(1);
    return '$text GB';
  }
}
