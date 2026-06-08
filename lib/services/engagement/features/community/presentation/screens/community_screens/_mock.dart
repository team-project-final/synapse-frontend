part of '../community_screens.dart';

class _GroupData {
  const _GroupData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accessLabel,
    required this.memberCount,
    required this.maxMembers,
    required this.sharedDeckCount,
    required this.joined,
    required this.lastActivity,
    required this.memberAvatars,
  });
  final String id;
  final String name;
  final String emoji;
  final String accessLabel;
  final int memberCount;
  final int maxMembers;
  final int sharedDeckCount;
  final bool joined;
  final String lastActivity;
  final List<String> memberAvatars;
}

// 탐색 탭용 공개 그룹 mock.
// TODO: 팀원 구현 — engagement-svc 공개 그룹 검색 API 연동.
const _exploreGroups = [
  _GroupData(
    id: 'e1',
    name: '자바스크립트 스터디',
    emoji: '🟨',
    accessLabel: '공개',
    memberCount: 24,
    maxMembers: 50,
    sharedDeckCount: 9,
    joined: false,
    lastActivity: '10분 전',
    memberAvatars: ['김', '이', '박', '최'],
  ),
  _GroupData(
    id: 'e2',
    name: 'CS 전공 면접 준비',
    emoji: '💼',
    accessLabel: '공개',
    memberCount: 41,
    maxMembers: 60,
    sharedDeckCount: 15,
    joined: false,
    lastActivity: '1시간 전',
    memberAvatars: ['정', '강', '한'],
  ),
  _GroupData(
    id: 'e3',
    name: '토익 900+ 도전',
    emoji: '🎯',
    accessLabel: '승인제',
    memberCount: 18,
    maxMembers: 25,
    sharedDeckCount: 6,
    joined: false,
    lastActivity: '어제',
    memberAvatars: ['윤', '임', '조'],
  ),
  _GroupData(
    id: 'e4',
    name: '클라우드 자격증 (AWS/GCP)',
    emoji: '☁️',
    accessLabel: '공개',
    memberCount: 33,
    maxMembers: 50,
    sharedDeckCount: 11,
    joined: false,
    lastActivity: '3시간 전',
    memberAvatars: ['서', '백', '노', '류'],
  ),
  _GroupData(
    id: 'e5',
    name: '운영체제 정복',
    emoji: '🖥️',
    accessLabel: '공개',
    memberCount: 12,
    maxMembers: 30,
    sharedDeckCount: 4,
    joined: false,
    lastActivity: '2일 전',
    memberAvatars: ['오', '신'],
  ),
  _GroupData(
    id: 'e6',
    name: '데이터 분석 입문',
    emoji: '📊',
    accessLabel: '승인제',
    memberCount: 27,
    maxMembers: 40,
    sharedDeckCount: 8,
    joined: false,
    lastActivity: '5시간 전',
    memberAvatars: ['남', '문', '양', '구'],
  ),
];
