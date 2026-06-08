part of '../admin_screens.dart';

// ============================================================================
// AdminGroupScreen (SCR-A-ADMIN-008)
// ============================================================================

class _MockGroup {
  const _MockGroup({
    required this.name,
    required this.members,
    required this.status,
    required this.createdAt,
  });
  final String name;
  final int members;
  final String status;
  final String createdAt;
}

// TODO: 팀원 구현 — platform-svc 그룹 목록 API 연동
const _mockGroups = [
  _MockGroup(
    name: '알고리즘 스터디',
    members: 12,
    status: '활성',
    createdAt: '2025-09-01',
  ),
  _MockGroup(
    name: 'TOEIC 900 도전',
    members: 45,
    status: '활성',
    createdAt: '2025-10-15',
  ),
  _MockGroup(
    name: '수능 대비반',
    members: 30,
    status: '활성',
    createdAt: '2026-01-10',
  ),
  _MockGroup(
    name: '졸업논문 준비',
    members: 8,
    status: '정지됨',
    createdAt: '2025-07-20',
  ),
  _MockGroup(
    name: '코딩 테스트 준비',
    members: 22,
    status: '활성',
    createdAt: '2026-03-05',
  ),
];

class AdminGroupScreen extends ConsumerWidget {
  const AdminGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('그룹 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '그룹 검색...',
              filters: const ['활성', '정지됨'],
              columns: const [
                DataColumn(label: Text('그룹명')),
                DataColumn(label: Text('멤버 수'), numeric: true),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('생성일')),
              ],
              rows: _mockGroups.map((g) {
                return DataRow(
                  cells: [
                    DataCell(Text(g.name)),
                    DataCell(Text('${g.members}')),
                    DataCell(_StatusBadge(status: g.status)),
                    DataCell(Text(g.createdAt)),
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
