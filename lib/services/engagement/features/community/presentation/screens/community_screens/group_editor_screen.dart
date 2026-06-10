part of '../community_screens.dart';

// ── CommunityGroupEditorScreen (SCR-W-COMM-003) ──

class CommunityGroupEditorScreen extends ConsumerStatefulWidget {
  const CommunityGroupEditorScreen({super.key});

  @override
  ConsumerState<CommunityGroupEditorScreen> createState() =>
      _CommunityGroupEditorScreenState();
}

class _CommunityGroupEditorScreenState
    extends ConsumerState<CommunityGroupEditorScreen> {
  // 그룹 카드가 이모지 아이콘을 쓰므로, 생성 시 아이콘을 직접 고른다.
  static const List<String> _emojiChoices = [
    '📚',
    '🧮',
    '💻',
    '🧠',
    '📰',
    '☁️',
    '🔬',
    '🎯',
    '💼',
    '🟨',
    '📊',
    '🗣️',
  ];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _joinType = 'open';
  double _maxMembers = 20;
  String _emoji = _emojiChoices.first;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      maxWidth: 560,
      children: [
        Text('그룹 만들기', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // Group name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '그룹 이름',
            hintText: '그룹 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Description
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '설명',
            hintText: '그룹에 대해 설명해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Join type with RadioListTile
        Text('가입 방식', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        RadioGroup<String>(
          groupValue: _joinType,
          onChanged: (v) => setState(() => _joinType = v ?? _joinType),
          child: const Column(
            children: [
              RadioListTile<String>(
                title: Text('공개'),
                subtitle: Text('누구나 바로 가입할 수 있습니다'),
                value: 'open',
                dense: true,
              ),
              RadioListTile<String>(
                title: Text('승인 필요'),
                subtitle: Text('관리자가 가입 요청을 승인합니다'),
                value: 'approval',
                dense: true,
              ),
              RadioListTile<String>(
                title: Text('초대만'),
                subtitle: Text('초대받은 사용자만 가입할 수 있습니다'),
                value: 'invite',
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 아이콘 선택(그룹 카드에 표시되는 이모지)
        Text('아이콘', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        ConceptEmojiPicker(
          emojis: _emojiChoices,
          selected: _emoji,
          onSelected: (e) => setState(() => _emoji = e),
        ),
        const SizedBox(height: AppSpacing.md),

        // Max members
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('최대 멤버 수', style: textTheme.bodyMedium),
            Text(
              '${_maxMembers.toInt()}명',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryAmber,
              ),
            ),
          ],
        ),
        Slider(
          value: _maxMembers,
          min: 5,
          max: 100,
          divisions: 19,
          label: '${_maxMembers.toInt()}명',
          onChanged: (v) => setState(() => _maxMembers = v),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Create button
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    AppToast.show(
                      context,
                      message: '그룹 이름을 입력해주세요',
                      type: ToastType.error,
                    );
                    return;
                  }
                  setState(() => _submitting = true);
                  try {
                    final group = await ref
                        .read(communityApiProvider)
                        .createGroup(
                          name: name,
                          description: _descController.text.trim(),
                          isPublic: _joinType == 'open',
                        );
                    ref.invalidate(communityGroupsProvider);
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        message: '그룹을 만들었습니다',
                        type: ToastType.success,
                      );
                      context.go(AppRoutes.communityGroupDetailPath(group.id));
                    }
                  } catch (_) {
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        message: '그룹 생성에 실패했습니다',
                        type: ToastType.error,
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _submitting = false);
                    }
                  }
                },
          child: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : const Text('만들기'),
        ),
      ],
    );
  }
}
