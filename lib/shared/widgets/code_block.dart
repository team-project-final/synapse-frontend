import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock({
    required this.code,
    this.language,
    super.key,
  });

  final String code;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.stone800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.stone700,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (language != null)
                  Text(language!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  color: AppColors.stone400,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      AppToast.show(context,
                          message: '복사됨', type: ToastType.success);
                    }
                  },
                  tooltip: '복사',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'GeistMono',
                fontSize: 13,
                color: AppColors.stone100,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
