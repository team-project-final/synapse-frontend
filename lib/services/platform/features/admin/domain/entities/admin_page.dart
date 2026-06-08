/// 관리자 목록 API의 페이지 응답을 표현하는 도메인 엔티티.
/// (백엔드 Spring Page 형식: content/page/size/totalElements/totalPages)
class AdminPage<T> {
  const AdminPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}
