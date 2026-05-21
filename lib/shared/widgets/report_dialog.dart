import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({this.targetTitle, super.key});

  final String? targetTitle;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? targetTitle,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ReportDialog(targetTitle: targetTitle),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _detailController = TextEditingController();

  static const _reasons = [
    '스팸 또는 광고',
    '부적절한 콘텐츠',
    '저작권 침해',
    '혐오 발언',
    '개인정보 노출',
    '기타',
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('신고하기'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.targetTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text('대상: ${widget.targetTitle}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            RadioGroup<String>(
              groupValue: _selectedReason ?? '',
              onChanged: (v) => setState(() => _selectedReason = v),
              child: Column(
                children: _reasons
                    .map((reason) => RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          dense: true,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: '상세 설명 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: _selectedReason == null
              ? null
              : () => Navigator.of(context).pop({
                    'reason': _selectedReason!,
                    'detail': _detailController.text,
                  }),
          child: const Text('제출'),
        ),
      ],
    );
  }
}
