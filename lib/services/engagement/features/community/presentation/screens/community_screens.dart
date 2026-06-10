import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/engagement/features/community/data/community_api.dart';
import 'package:synapse_frontend/services/engagement/features/community/providers/community_providers.dart';
import 'package:synapse_frontend/services/engagement/features/gamification/providers/gamification_providers.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/confirm_dialog.dart';
import 'package:synapse_frontend/shared/widgets/report_dialog.dart';
import 'package:synapse_frontend/shared/widgets/study_board_kit.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

part 'community_screens/_mock.dart';
part 'community_screens/group_list_screen.dart';
part 'community_screens/group_detail_screen.dart';
part 'community_screens/group_editor_screen.dart';
part 'community_screens/shared_decks_screen.dart';
part 'community_screens/shared_deck_detail_screen.dart';
part 'community_screens/shared_notes_screen.dart';
part 'community_screens/shared_note_detail_screen.dart';

Future<void> _showReportAndSubmit(
  BuildContext context,
  WidgetRef ref, {
  required String targetTitle,
  required ReportTargetType targetType,
  required String targetId,
}) async {
  final result = await ReportDialog.show(context, targetTitle: targetTitle);
  if (result == null || !context.mounted) {
    return;
  }

  final selectedReason = result['reason'] ?? '신고';
  final detail = result['detail']?.trim();
  final reason = detail == null || detail.isEmpty
      ? selectedReason
      : '$selectedReason\n$detail';

  try {
    await ref.read(communityApiProvider).reportContent(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
        );
    if (context.mounted) {
      AppToast.show(
        context,
        message: '신고가 접수되었습니다',
        type: ToastType.success,
      );
    }
  } on DioException catch (error) {
    if (context.mounted) {
      AppToast.show(
        context,
        message: error.response?.statusCode == 409
            ? '이미 신고한 콘텐츠입니다'
            : '신고 접수에 실패했습니다',
        type: ToastType.error,
      );
    }
  } catch (_) {
    if (context.mounted) {
      AppToast.show(
        context,
        message: '신고 접수에 실패했습니다',
        type: ToastType.error,
      );
    }
  }
}

Future<void> _showInviteAndSubmit(
  BuildContext context,
  WidgetRef ref, {
  required CommunityGroup group,
}) async {
  final controller = TextEditingController();
  final userId = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${group.name} 초대'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '사용자 ID',
            hintText: '초대할 사용자 ID를 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('초대'),
          ),
        ],
      );
    },
  );
  controller.dispose();

  if (userId == null || !context.mounted) {
    return;
  }
  if (int.tryParse(userId) == null || int.parse(userId) <= 0) {
    AppToast.show(
      context,
      message: '숫자 사용자 ID를 입력해주세요',
      type: ToastType.error,
    );
    return;
  }

  try {
    await ref.read(communityApiProvider).inviteGroupMember(
          groupId: group.id,
          userId: userId,
        );
    ref.invalidate(communityGroupMembersProvider(group.id));
    if (context.mounted) {
      AppToast.show(
        context,
        message: '초대를 보냈습니다',
        type: ToastType.success,
      );
    }
  } catch (_) {
    if (context.mounted) {
      AppToast.show(
        context,
        message: '초대에 실패했습니다',
        type: ToastType.error,
      );
    }
  }
}

Future<void> _showGroupEditAndSubmit(
  BuildContext context,
  WidgetRef ref, {
  required CommunityGroup group,
}) async {
  final nameController = TextEditingController(text: group.name);
  final descriptionController = TextEditingController(text: group.description);
  var isPublic = group.isPublic;

  final result = await showDialog<_GroupEditResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${group.name} 수정'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '그룹 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: isPublic,
                    onChanged: (value) =>
                        setDialogState(() => isPublic = value),
                    title: const Text('공개 그룹'),
                    subtitle: Text(isPublic ? '누구나 바로 가입' : '가입 요청 필요'),
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
                onPressed: () {
                  Navigator.of(context).pop(
                    _GroupEditResult(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      isPublic: isPublic,
                    ),
                  );
                },
                child: const Text('저장'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  descriptionController.dispose();

  if (result == null || !context.mounted) {
    return;
  }
  if (result.name.isEmpty) {
    AppToast.show(
      context,
      message: '그룹 이름을 입력해주세요',
      type: ToastType.error,
    );
    return;
  }

  try {
    final updated = await ref.read(communityApiProvider).updateGroup(
          groupId: group.id,
          name: result.name,
          description: result.description,
          isPublic: result.isPublic,
        );
    ref.invalidate(communityGroupsProvider);
    ref.invalidate(communityGroupProvider(group.id));
    if (context.mounted) {
      AppToast.show(
        context,
        message: '그룹을 수정했습니다',
        type: ToastType.success,
      );
      if (updated.id != group.id) {
        context.go(AppRoutes.communityGroupDetailPath(updated.id));
      }
    }
  } catch (_) {
    if (context.mounted) {
      AppToast.show(
        context,
        message: '그룹 수정에 실패했습니다',
        type: ToastType.error,
      );
    }
  }
}

class _GroupEditResult {
  const _GroupEditResult({
    required this.name,
    required this.description,
    required this.isPublic,
  });

  final String name;
  final String description;
  final bool isPublic;
}

Future<void> _confirmDeleteGroupAndSubmit(
  BuildContext context,
  WidgetRef ref, {
  required CommunityGroup group,
}) async {
  final ok = await ConfirmDialog.show(
    context,
    title: '그룹 삭제',
    content: '${group.name} 그룹을 삭제하면 다시 복구할 수 없습니다. 계속할까요?',
    confirmLabel: '삭제',
    isDestructive: true,
  );
  if (ok != true || !context.mounted) {
    return;
  }

  try {
    await ref.read(communityApiProvider).deleteGroup(group.id);
    ref.invalidate(communityGroupsProvider);
    ref.invalidate(communityGroupProvider(group.id));
    ref.invalidate(communityGroupMembersProvider(group.id));
    if (context.mounted) {
      AppToast.show(
        context,
        message: '그룹을 삭제했습니다',
        type: ToastType.success,
      );
      context.go(AppRoutes.communityGroups);
    }
  } catch (_) {
    if (context.mounted) {
      AppToast.show(
        context,
        message: '그룹 삭제에 실패했습니다',
        type: ToastType.error,
      );
    }
  }
}
