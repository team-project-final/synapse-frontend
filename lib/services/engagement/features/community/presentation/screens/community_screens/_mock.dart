part of '../community_screens.dart';

class _GroupData {
  const _GroupData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accessLabel,
    required this.joined,
    required this.lastActivity,
    required this.memberAvatars,
  });
  final String id;
  final String name;
  final String emoji;
  final String accessLabel;
  final bool joined;
  final String lastActivity;
  final List<String> memberAvatars;
}

_GroupData _groupDataFromApi(
  CommunityGroup group, {
  bool joined = false,
}) {
  return _GroupData(
    id: group.id,
    name: group.name,
    emoji: group.isPublic ? '🌐' : '🔒',
    accessLabel: group.isPublic ? '공개' : '승인제',
    joined: joined || group.joined,
    lastActivity: _formatRelativeTime(group.createdAt),
    memberAvatars: [
      if (group.name.isNotEmpty) _initial(group.name),
      if (group.ownerId.isNotEmpty) group.ownerId.substring(group.ownerId.length - 1),
    ],
  );
}

String _initial(String value) => value.isEmpty ? '?' : value.substring(0, 1);

String _formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) {
    return '최근';
  }
  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.inMinutes < 1) return '방금';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${dateTime.month}/${dateTime.day}';
}
