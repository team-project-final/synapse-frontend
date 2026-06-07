import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

/// 내 덱/노트를 그룹·커뮤니티에 공유하는 다이얼로그(UI 목업).
///
/// 기능 연동은 팀원 몫이며, 여기서는 대상 그룹 + 공개 범위 + 메모를
/// 선택해 결과 Map을 반환하는 화면만 제공한다. [ReportDialog]와 동일 패턴.
class ShareDialog extends StatefulWidget {
  const ShareDialog({this.targetTitle, super.key});

  /// 공유 대상(덱/노트) 제목. 헤더에 표시.
  final String? targetTitle;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? targetTitle,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ShareDialog(targetTitle: targetTitle),
    );
  }

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  // TODO: 팀원 구현 — engagement-svc 내 그룹 목록 API로 교체.
  static const _groups = ['AWS 자격증 스터디', '알고리즘 마스터즈', '딥러닝 논문 읽기'];
  static const _visibilities = ['그룹 전용', '공개 (전체)'];

  String? _selectedGroup;
  String _visibility = '그룹 전용';
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('공유하기'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.targetTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  '대상: ${widget.targetTitle}',
                  style: textTheme.bodySmall,
                ),
              ),
            Text('공유할 그룹', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedGroup,
              hint: const Text('그룹을 선택하세요'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _groups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGroup = v),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('공개 범위', style: textTheme.labelLarge),
            RadioGroup<String>(
              groupValue: _visibility,
              onChanged: (v) => setState(() => _visibility = v ?? _visibility),
              child: Column(
                children: _visibilities
                    .map(
                      (v) => RadioListTile<String>(
                        title: Text(v),
                        value: v,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '공유 메모 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          // 그룹을 골라야 공유 가능.
          onPressed: _selectedGroup == null
              ? null
              : () => Navigator.of(context).pop({
                  'group': _selectedGroup!,
                  'visibility': _visibility,
                  'memo': _memoController.text,
                }),
          child: const Text('공유'),
        ),
      ],
    );
  }
}
