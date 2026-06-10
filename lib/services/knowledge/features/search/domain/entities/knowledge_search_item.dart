class KnowledgeSearchItem {
  const KnowledgeSearchItem({
    required this.noteId,
    required this.title,
    required this.snippet,
    required this.highlights,
    this.keywordScore,
    this.semanticScore,
    this.rrfScore,
  });

  final String noteId;
  final String title;
  final String snippet;
  final List<String> highlights;
  final double? keywordScore;
  final double? semanticScore;
  final double? rrfScore;
}
