/// Spring Page 형식(JSON) → 제네릭 페이지 모델 파서.
/// content 각 항목은 parseItem 으로 개별 모델로 변환한다.
class AdminPageModel<T> {
  const AdminPageModel({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory AdminPageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final raw = json['content'];
    final items = <T>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          items.add(parseItem(Map<String, dynamic>.from(item)));
        }
      }
    }
    return AdminPageModel<T>(
      content: items,
      page: _asInt(json['page'] ?? json['number']),
      size: _asInt(json['size'], items.length),
      totalElements: _asInt(json['totalElements'], items.length),
      totalPages: _asInt(json['totalPages'], items.isEmpty ? 0 : 1),
    );
  }

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
