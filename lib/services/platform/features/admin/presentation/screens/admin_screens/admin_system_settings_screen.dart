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
  late final TabController _tabController;

  // TODO: 팀원 구현 — platform-svc 피처 플래그 API 연동
  final Map<String, bool> _featureFlags = {
    'AI 카드 자동 생성': true,
    '소셜 로그인 (Google)': true,
    '소셜 로그인 (GitHub)': false,
    '실시간 협업 편집': false,
    '베타: 음성 복습': false,
  };

  final _rateLimitController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rateLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('시스템 설정', style: textTheme.headlineSmall),
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
                // ── Tab 1: Plan Quota ──
                SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.surface2,
                    ),
                    columns: const [
                      DataColumn(label: Text('플랜')),
                      DataColumn(label: Text('AI 토큰/월'), numeric: true),
                      DataColumn(label: Text('스토리지 (GB)'), numeric: true),
                      DataColumn(label: Text('멤버 한도'), numeric: true),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(Text('Free')),
                          DataCell(Text('1,000')),
                          DataCell(Text('1')),
                          DataCell(Text('5')),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Pro')),
                          DataCell(Text('50,000')),
                          DataCell(Text('50')),
                          DataCell(Text('100')),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Enterprise')),
                          DataCell(Text('무제한')),
                          DataCell(Text('500')),
                          DataCell(Text('무제한')),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Tab 2: Feature Flags ──
                ListView(
                  children: _featureFlags.entries.map((entry) {
                    return SwitchListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (v) {
                        setState(() => _featureFlags[entry.key] = v);
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
                        controller: _rateLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '요청 수/분',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () {
                          // TODO: 팀원 구현 — platform-svc 설정 저장 API 연동
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('설정이 저장되었습니다.')),
                          );
                        },
                        child: const Text('저장'),
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
}
