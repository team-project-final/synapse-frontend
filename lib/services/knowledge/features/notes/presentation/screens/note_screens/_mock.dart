part of '../note_screens.dart';

// ── Mock data ──

class _MockNote {
  const _MockNote({
    required this.id,
    required this.title,
    required this.snippet,
    required this.tags,
    required this.timeAgo,
    this.backlinks,
  });
  final String id;
  final String title;
  final String snippet;
  final List<String> tags;
  final String timeAgo;
  final int? backlinks;
}

const _mockNotes = [
  _MockNote(
    id: '1',
    title: '정규화 기법 (Regularization)',
    snippet: 'L1/L2 정규화는 과적합을 방지하기 위한 기법입니다. L1은 Lasso, L2는 Ridge라고 불립니다.',
    tags: ['머신러닝', '딥러닝'],
    timeAgo: '2시간 전',
    backlinks: 5,
  ),
  _MockNote(
    id: '2',
    title: '동적 프로그래밍 기초',
    snippet: '메모이제이션과 타뷸레이션을 사용하여 중복 계산을 피하는 알고리즘 설계 기법입니다.',
    tags: ['알고리즘', '코딩'],
    timeAgo: '어제',
  ),
  _MockNote(
    id: '3',
    title: 'AWS S3 버킷 정책',
    snippet: 'IAM 정책과 버킷 정책의 차이점 및 교차 계정 접근 설정 방법을 다룹니다.',
    tags: ['AWS', '클라우드'],
    timeAgo: '3일 전',
  ),
];
