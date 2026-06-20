import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AdminDataGrid extends StatefulWidget {
  const AdminDataGrid({
    required this.columns,
    required this.rows,
    this.searchHint = '검색...',
    this.filters = const [],
    this.onRowTap,
    this.actions,
    super.key,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String searchHint;
  final List<String> filters;
  final ValueChanged<int>? onRowTap;
  final List<Widget>? actions;

  @override
  State<AdminDataGrid> createState() => _AdminDataGridState();
}

class _AdminDataGridState extends State<AdminDataGrid> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search + filters + actions bar
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (widget.filters.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['전체', ...widget.filters].map((f) {
                      final selected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(f),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            if (widget.actions != null) ...[
              const SizedBox(width: AppSpacing.md),
              ...widget.actions!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Data table
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.stone100,
                      ),
                      columns: widget.columns,
                      rows: widget.rows,
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Pagination
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '1-10 / ${widget.rows.length}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.stone500),
            ),
            const SizedBox(width: AppSpacing.sm),
            const IconButton(
              icon: Icon(Icons.chevron_left, size: 20),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                // TODO: 팀원 구현 — 커서 페이지네이션
              },
            ),
          ],
        ),
      ],
    );
  }
}
