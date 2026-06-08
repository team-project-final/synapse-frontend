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
    this.onSearch,
    this.onFilterSelected,
    this.page = 0,
    this.totalPages = 1,
    this.totalElements,
    this.onPageChanged,
    super.key,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String searchHint;
  final List<String> filters;
  final ValueChanged<int>? onRowTap;
  final List<Widget>? actions;

  /// 제공 시 검색어 제출(엔터)을 서버로 전달한다. null이면 검색창은 비활성.
  final ValueChanged<String>? onSearch;

  /// 제공 시 필터 칩 선택을 서버로 전달한다('전체'는 null).
  final ValueChanged<String?>? onFilterSelected;

  /// 서버 페이지네이션 상태/콜백. onPageChanged 제공 시 이전/다음 버튼 활성.
  final int page;
  final int totalPages;
  final int? totalElements;
  final ValueChanged<int>? onPageChanged;

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
                enabled: widget.onSearch != null,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
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
                          onSelected: (_) {
                            setState(() => _selectedFilter = f);
                            widget.onFilterSelected
                                ?.call(f == '전체' ? null : f);
                          },
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
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.stone100),
                columns: widget.columns,
                rows: widget.rows,
                showCheckboxColumn: false,
              ),
            ),
          ),
        ),
        // Pagination
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_pageLabel(),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.stone500)),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: (widget.onPageChanged != null && widget.page > 0)
                  ? () => widget.onPageChanged!(widget.page - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: (widget.onPageChanged != null &&
                      widget.page < widget.totalPages - 1)
                  ? () => widget.onPageChanged!(widget.page + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  String _pageLabel() {
    if (widget.onPageChanged != null) {
      final totalPages = widget.totalPages <= 0 ? 1 : widget.totalPages;
      final base = '${widget.page + 1} / $totalPages';
      final total = widget.totalElements;
      return total != null ? '$base · 총 $total건' : base;
    }
    return '${widget.rows.length}건';
  }
}
