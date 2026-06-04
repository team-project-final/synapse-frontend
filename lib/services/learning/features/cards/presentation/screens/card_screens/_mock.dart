part of '../card_screens.dart';

// ── Mock data ──

class _MockDeck {
  const _MockDeck({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cardCount,
    required this.dueCount,
    required this.progress,
    this.description = '',
  });
  final String id;
  final String name;
  final String emoji;
  final int cardCount;
  final int dueCount;
  final double progress;
  final String description;
}

const _mockDecks = [
  _MockDeck(
    id: '1',
    name: '프로그래밍 기초',
    emoji: '💻',
    cardCount: 45,
    dueCount: 12,
    progress: 0.6,
    description: '자료구조·언어 문법 등 기초 개념 정리 덱',
  ),
  _MockDeck(
    id: '2',
    name: '알고리즘 & 자료구조',
    emoji: '🧩',
    cardCount: 80,
    dueCount: 5,
    progress: 0.75,
    description: 'DP·그래프·정렬 등 핵심 알고리즘 모음',
  ),
  _MockDeck(
    id: '3',
    name: 'AWS 자격증',
    emoji: '☁️',
    cardCount: 30,
    dueCount: 20,
    progress: 0.3,
    description: 'SAA 대비 핵심 서비스 요약',
  ),
];
