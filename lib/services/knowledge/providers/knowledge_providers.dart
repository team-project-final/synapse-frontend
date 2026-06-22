import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/knowledge/data/knowledge_api.dart';

final knowledgeApiProvider = Provider<KnowledgeApi>((ref) {
  return KnowledgeApi(ref.watch(dioProvider));
});

final noteListProvider = FutureProvider.autoDispose
    .family<KnowledgeNotePage, NoteListQuery>((ref, query) {
      return ref
          .watch(knowledgeApiProvider)
          .listNotes(
            tag: query.tag,
            page: query.page,
            size: query.size,
            sort: query.sortQuery,
          );
    });

final noteDetailProvider = FutureProvider.autoDispose
    .family<KnowledgeNote, String>((ref, noteId) {
      return ref.watch(knowledgeApiProvider).getNote(noteId);
    });

final noteBacklinksProvider = FutureProvider.autoDispose
    .family<List<KnowledgeNote>, String>((ref, noteId) {
      return ref.watch(knowledgeApiProvider).getBacklinks(noteId);
    });

final noteOutlinksProvider = FutureProvider.autoDispose
    .family<List<KnowledgeNote>, String>((ref, noteId) {
      return ref.watch(knowledgeApiProvider).getOutlinks(noteId);
    });

final noteVersionsProvider = FutureProvider.autoDispose
    .family<List<KnowledgeNoteVersion>, String>((ref, noteId) {
      return ref.watch(knowledgeApiProvider).listVersions(noteId);
    });

final popularTagsProvider = FutureProvider.autoDispose<List<KnowledgeTagStat>>((
  ref,
) {
  return ref.watch(knowledgeApiProvider).popularTags();
});

final tagAutocompleteProvider = FutureProvider.autoDispose
    .family<List<KnowledgeTagStat>, String>((ref, query) {
      return ref.watch(knowledgeApiProvider).autocompleteTags(query);
    });

final knowledgeSearchProvider = FutureProvider.autoDispose
    .family<KnowledgeSearchPage, KnowledgeSearchQuery>((ref, query) {
      if (query.query.trim().isEmpty) {
        return Future.value(KnowledgeSearchPage.empty());
      }
      if (query.semantic) {
        return ref
            .watch(knowledgeApiProvider)
            .hybridSearch(
              query: query.query,
              limit: query.limit,
              tags: query.tags,
            );
      }
      return ref
          .watch(knowledgeApiProvider)
          .searchNotes(
            query: query.query,
            limit: query.limit,
            tags: query.tags,
          );
    });

final knowledgeGraphProvider = FutureProvider.autoDispose<KnowledgeGraphData>((
  ref,
) {
  return ref.watch(knowledgeApiProvider).getGraphData();
});

final neighborGraphProvider = FutureProvider.autoDispose
    .family<KnowledgeGraphData, NeighborGraphQuery>((ref, query) {
      return ref
          .watch(knowledgeApiProvider)
          .getNeighborGraph(noteId: query.noteId, depth: query.depth);
    });

class NoteListQuery {
  const NoteListQuery({
    this.tag,
    this.sortOrder = '최근 수정',
    this.page = 0,
    this.size = 20,
  });

  final String? tag;
  final String sortOrder;
  final int page;
  final int size;

  String get sortQuery {
    return switch (sortOrder) {
      '제목순' => 'title,asc',
      '생성일' => 'createdAt,desc',
      _ => 'updatedAt,desc',
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NoteListQuery &&
            other.tag == tag &&
            other.sortOrder == sortOrder &&
            other.page == page &&
            other.size == size;
  }

  @override
  int get hashCode => Object.hash(tag, sortOrder, page, size);
}

class KnowledgeSearchQuery {
  const KnowledgeSearchQuery({
    required this.query,
    required this.semantic,
    this.tags = const [],
    this.limit = 20,
  });

  final String query;
  final bool semantic;
  final List<String> tags;
  final int limit;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is KnowledgeSearchQuery &&
            other.query == query &&
            other.semantic == semantic &&
            _listEquals(other.tags, tags) &&
            other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(query, semantic, Object.hashAll(tags), limit);
}

class NeighborGraphQuery {
  const NeighborGraphQuery({required this.noteId, required this.depth});

  final String noteId;
  final int depth;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeighborGraphQuery &&
            other.noteId == noteId &&
            other.depth == depth;
  }

  @override
  int get hashCode => Object.hash(noteId, depth);
}

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}
