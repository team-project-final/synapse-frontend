part of '../admin_screens.dart';

// ============================================================================
// AdminDataRequestScreen (SCR-A-ADMIN-010)
// ============================================================================

class AdminDataRequestScreen extends ConsumerStatefulWidget {
  const AdminDataRequestScreen({super.key});

  @override
  ConsumerState<AdminDataRequestScreen> createState() =>
      _AdminDataRequestScreenState();
}

class _AdminDataRequestScreenState
    extends ConsumerState<AdminDataRequestScreen> {
  static const Map<String, AdminDataRequestStatus> _statusFilters = {
    '대기': AdminDataRequestStatus.pending,
    '처리중': AdminDataRequestStatus.processing,
    '완료': AdminDataRequestStatus.completed,
    '거부': AdminDataRequestStatus.rejected,
  };

  AdminPage<AdminDataRequest>? _page;
  AdminDataRequestStatus? _statusFilter;
  String? _query;
  int _pageIndex = 0;
  bool _loading = true;
  bool _acting = false;
  String? _error;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(listAdminDataRequestsUseCaseProvider)(
        status: _statusFilter,
        query: _query,
        page: _pageIndex,
      );
      if (!mounted) return;
      setState(() {
        _page = page;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '데이터 요청 목록을 불러오지 못했습니다.';
      });
    }
  }

  AdminDataRequest? get _selected {
    final page = _page;
    if (page == null || _selectedId == null) return null;
    for (final request in page.content) {
      if (request.id == _selectedId) return request;
    }
    return null;
  }

  Future<void> _applyAction(
    AdminDataRequest request,
    AdminDataRequestAction action,
  ) async {
    final config = switch (action) {
      AdminDataRequestAction.approve => (
          title: '요청 승인',
          message: '${request.userEmail}의 ${request.typeLabel} 요청을 승인하시겠습니까?',
          destructive: false,
        ),
      AdminDataRequestAction.execute => (
          title: '요청 실행',
          message: '${request.typeLabel} 처리를 즉시 실행하시겠습니까?',
          destructive: false,
        ),
      AdminDataRequestAction.reject => (
          title: '요청 거부',
          message: '${request.userEmail}의 ${request.typeLabel} 요청을 거부하시겠습니까?',
          destructive: true,
        ),
    };

    final reason = await _DataRequestReasonDialog.show(
      context,
      title: config.title,
      message: config.message,
      confirmLabel: config.title.substring(3),
      isDestructive: config.destructive,
    );
    if (reason == null || !mounted) return;

    setState(() => _acting = true);
    try {
      final updated = await ref.read(
        applyAdminDataRequestActionUseCaseProvider,
      )(id: request.id, action: action, reason: reason.isEmpty ? null : reason);
      if (!mounted) return;
      setState(() {
        _acting = false;
        final page = _page;
        if (page != null) {
          _page = AdminPage<AdminDataRequest>(
            content: page.content
                .map((r) => r.id == updated.id ? updated : r)
                .toList(),
            page: page.page,
            size: page.size,
            totalElements: page.totalElements,
            totalPages: page.totalPages,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${config.title}이 처리되었습니다.')),
      );
    } on AdminDataRequestConflictException catch (error) {
      if (!mounted) return;
      setState(() => _acting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _acting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요청 처리에 실패했습니다.')),
      );
    }
  }

  Future<void> _createRequest() async {
    final created = await _DataRequestCreateDialog.show(context, ref);
    if (created == true && mounted) {
      setState(() {
        _pageIndex = 0;
        _statusFilter = null;
      });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final page = _page;

    if (_loading && page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && page == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final requests = page?.content ?? const <AdminDataRequest>[];
    final selected = _selected;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('데이터 요청 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '사용자 이메일/이름 검색...',
              filters: _statusFilters.keys.toList(),
              onFilterSelected: (label) {
                setState(() {
                  _statusFilter = label == null ? null : _statusFilters[label];
                  _pageIndex = 0;
                  _selectedId = null;
                });
                _load();
              },
              onSearch: (value) {
                setState(() {
                  _query = value.trim().isEmpty ? null : value.trim();
                  _pageIndex = 0;
                  _selectedId = null;
                });
                _load();
              },
              page: page?.page ?? 0,
              totalPages: page?.totalPages ?? 1,
              totalElements: page?.totalElements,
              onPageChanged: (next) {
                setState(() {
                  _pageIndex = next;
                  _selectedId = null;
                });
                _load();
              },
              actions: [
                FilledButton.icon(
                  key: const Key('data-request-create'),
                  onPressed: _createRequest,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('요청 등록'),
                ),
              ],
              emptyMessage: '데이터 요청이 없습니다.',
              columns: const [
                DataColumn(label: Text('접수일')),
                DataColumn(label: Text('사용자')),
                DataColumn(label: Text('유형')),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('기한')),
              ],
              rows: requests.map((request) {
                return DataRow(
                  selected: request.id == _selectedId,
                  onSelectChanged: (_) {
                    setState(() => _selectedId = request.id);
                  },
                  cells: [
                    DataCell(Text(_formatDate(request.receivedAt))),
                    DataCell(Text(request.userEmail)),
                    DataCell(Text(request.typeLabel)),
                    DataCell(_DataRequestStatusChip(request: request)),
                    DataCell(Text(_dueText(request))),
                  ],
                );
              }).toList(),
            ),
          ),
          if (selected != null)
            _DataRequestDetail(
              request: selected,
              acting: _acting,
              onAction: (action) => _applyAction(selected, action),
            ),
        ],
      ),
    );
  }

  String _dueText(AdminDataRequest request) {
    if (!request.isOpen) return '—';
    return 'D-${request.daysRemaining}';
  }
}

class _DataRequestStatusChip extends StatelessWidget {
  const _DataRequestStatusChip({required this.request});
  final AdminDataRequest request;

  @override
  Widget build(BuildContext context) {
    final color = switch (request.status) {
      AdminDataRequestStatus.pending => AppColors.warning,
      AdminDataRequestStatus.processing => AppColors.info,
      AdminDataRequestStatus.completed => AppColors.success,
      AdminDataRequestStatus.rejected => AppColors.error,
      AdminDataRequestStatus.unknown => AppColors.muted,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(request.statusLabel),
      ],
    );
  }
}

class _DataRequestDetail extends StatelessWidget {
  const _DataRequestDetail({
    required this.request,
    required this.acting,
    required this.onAction,
  });

  final AdminDataRequest request;
  final bool acting;
  final ValueChanged<AdminDataRequestAction> onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final daysColor =
        request.isOpen && request.daysRemaining <= 7 ? AppColors.error : null;

    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('요청 상세', style: textTheme.titleSmall),
                const Spacer(),
                if (request.canApprove)
                  OutlinedButton.icon(
                    key: const Key('dr-action-approve'),
                    onPressed: acting
                        ? null
                        : () => onAction(AdminDataRequestAction.approve),
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.success,
                    ),
                    label: const Text('승인'),
                  ),
                if (request.status == AdminDataRequestStatus.processing) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Tooltip(
                    message: request.canExecute
                        ? ''
                        : '삭제 요청은 전용 삭제 워크플로로 처리해야 합니다.',
                    child: OutlinedButton.icon(
                      key: const Key('dr-action-execute'),
                      onPressed: acting || !request.canExecute
                          ? null
                          : () => onAction(AdminDataRequestAction.execute),
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: AppColors.info,
                      ),
                      label: const Text('실행'),
                    ),
                  ),
                ],
                if (request.isOpen) ...[
                  const SizedBox(width: AppSpacing.xs),
                  OutlinedButton.icon(
                    key: const Key('dr-action-reject'),
                    onPressed: acting
                        ? null
                        : () => onAction(AdminDataRequestAction.reject),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.error,
                    ),
                    label: const Text('거부'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('사용자: ${request.userDisplayName} (${request.userEmail})'),
            Text('유형: ${request.typeLabel}'),
            Text('상태: ${request.statusLabel}'),
            Text('접수일: ${_formatDate(request.receivedAt)}'),
            if (request.isOpen)
              Text(
                '처리 기한: ${_formatDate(request.dueAt)} (D-${request.daysRemaining})',
                style: textTheme.bodyMedium?.copyWith(
                  color: daysColor,
                  fontWeight: daysColor != null ? FontWeight.bold : null,
                ),
              ),
            if (request.processedAt != null)
              Text('처리일: ${_formatDate(request.processedAt)}'),
            if (request.reason?.isNotEmpty ?? false)
              Text('요청 사유: ${request.reason}'),
            if (request.adminNote?.isNotEmpty ?? false)
              Text('관리자 메모: ${request.adminNote}'),
            if (request.dataSummary?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('데이터 요약: ${request.dataSummary}', style: textTheme.bodySmall),
            ],
            if (request.executionLogs.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('실행 로그', style: textTheme.labelMedium),
              ...request.executionLogs.map(
                (log) => Text(
                  log,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '실행 로그: (처리 대기 중)',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 액션 확인 + 사유 입력 다이얼로그. 취소 시 null, 확인 시 입력한 사유(빈 문자열 가능).
class _DataRequestReasonDialog extends StatefulWidget {
  const _DataRequestReasonDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDestructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _DataRequestReasonDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  State<_DataRequestReasonDialog> createState() =>
      _DataRequestReasonDialogState();
}

class _DataRequestReasonDialogState extends State<_DataRequestReasonDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('dr-reason-field'),
            controller: _reasonController,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: '사유 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const Key('dr-reason-confirm'),
          onPressed: () =>
              Navigator.of(context).pop(_reasonController.text.trim()),
          style: widget.isDestructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// GDPR 요청 수동 등록 다이얼로그(접수 채널이 따로 없어 관리자가 직접 기록).
class _DataRequestCreateDialog extends ConsumerStatefulWidget {
  const _DataRequestCreateDialog();

  static Future<bool?> show(BuildContext context, WidgetRef ref) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const _DataRequestCreateDialog(),
    );
  }

  @override
  ConsumerState<_DataRequestCreateDialog> createState() =>
      _DataRequestCreateDialogState();
}

class _DataRequestCreateDialogState
    extends ConsumerState<_DataRequestCreateDialog> {
  final _userIdController = TextEditingController();
  final _reasonController = TextEditingController();
  AdminDataRequestType _type = AdminDataRequestType.dataAccess;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _userIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() => _error = '사용자 ID(UUID)를 입력해주세요.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(createAdminDataRequestUseCaseProvider)(
        userId: userId,
        type: _type,
        reason: _reasonController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '요청 등록에 실패했습니다. 사용자 ID를 확인해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('데이터 요청 등록'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('dr-create-user-id'),
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: '사용자 ID (UUID)',
                helperText: '사용자 관리 화면에서 ID를 복사해 입력하세요.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<AdminDataRequestType>(
              key: const Key('dr-create-type'),
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: '요청 유형',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: AdminDataRequestType.dataAccess,
                  child: Text('데이터 열람'),
                ),
                DropdownMenuItem(
                  value: AdminDataRequestType.dataExport,
                  child: Text('데이터 내보내기'),
                ),
                DropdownMenuItem(
                  value: AdminDataRequestType.dataErasure,
                  child: Text('데이터 삭제'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('dr-create-reason'),
              controller: _reasonController,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: '사유 (선택)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const Key('dr-create-submit'),
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('등록'),
        ),
      ],
    );
  }
}
