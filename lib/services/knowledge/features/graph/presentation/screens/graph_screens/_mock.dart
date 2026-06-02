part of '../graph_screens.dart';

// ── Mock data models ──

class _MockGraphNode {
  const _MockGraphNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.cluster = 0,
    this.linkCount = 0,
    this.pageRank = 0.0,
  });
  final String id;
  final String label;
  final double x;
  final double y;
  final int cluster;
  final int linkCount;
  final double pageRank;
}

class _MockGraphEdge {
  const _MockGraphEdge({required this.from, required this.to});
  final String from;
  final String to;
}

// ── Mock data ──

const List<_MockGraphNode> _mockNodes = [
  _MockGraphNode(
    id: '1',
    label: '정규화 기법',
    x: 350,
    y: 200,
    cluster: 0,
    linkCount: 6,
    pageRank: 0.85,
  ),
  _MockGraphNode(
    id: '2',
    label: '드롭아웃',
    x: 200,
    y: 120,
    cluster: 0,
    linkCount: 4,
    pageRank: 0.62,
  ),
  _MockGraphNode(
    id: '3',
    label: '배치 정규화',
    x: 480,
    y: 140,
    cluster: 0,
    linkCount: 3,
    pageRank: 0.55,
  ),
  _MockGraphNode(
    id: '4',
    label: '과적합 방지',
    x: 150,
    y: 300,
    cluster: 1,
    linkCount: 5,
    pageRank: 0.78,
  ),
  _MockGraphNode(
    id: '5',
    label: '교차 검증',
    x: 280,
    y: 380,
    cluster: 1,
    linkCount: 3,
    pageRank: 0.50,
  ),
  _MockGraphNode(
    id: '6',
    label: '학습률 스케줄링',
    x: 550,
    y: 280,
    cluster: 1,
    linkCount: 2,
    pageRank: 0.40,
  ),
  _MockGraphNode(
    id: '7',
    label: '합성곱 신경망',
    x: 500,
    y: 420,
    cluster: 2,
    linkCount: 4,
    pageRank: 0.72,
  ),
  _MockGraphNode(
    id: '8',
    label: '순환 신경망',
    x: 650,
    y: 350,
    cluster: 2,
    linkCount: 3,
    pageRank: 0.58,
  ),
];

const List<_MockGraphEdge> _mockEdges = [
  _MockGraphEdge(from: '1', to: '2'),
  _MockGraphEdge(from: '1', to: '3'),
  _MockGraphEdge(from: '1', to: '4'),
  _MockGraphEdge(from: '2', to: '4'),
  _MockGraphEdge(from: '4', to: '5'),
  _MockGraphEdge(from: '3', to: '6'),
  _MockGraphEdge(from: '6', to: '7'),
  _MockGraphEdge(from: '7', to: '8'),
  _MockGraphEdge(from: '1', to: '7'),
];

// 컨셉 팔레트(보라/핑크/파랑/초록) — 목업 그래프 노드 색과 매칭.
const List<Color> _clusterColors = [
  AppColors.primary,
  AppColors.accent,
  AppColors.info,
  AppColors.success,
];
