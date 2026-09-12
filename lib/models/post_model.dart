// Model artikel. Satu artikel bisa punya banyak kategori dan satu
// kategori bisa dipakai banyak artikel. Field lama `categoryId` tetap
// dipertahankan sebagai kategori pertama agar kompatibel dengan backend.
class PostModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final int? categoryId;
  final List<int> categoryIds;
  final String categoryName;
  final int? authorId;
  final String authorName;
  final String? createdAt;
  final String? updatedAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.categoryId,
    this.categoryIds = const [],
    this.categoryName = '',
    this.authorId,
    this.authorName = 'Anonymous',
    this.createdAt,
    this.updatedAt,
  });

  // Semua id kategori unik: dari list baru + field lama.
  List<int> get allCategoryIds {
    final ids = <int>[...categoryIds];
    if (categoryId != null && !ids.contains(categoryId)) {
      ids.add(categoryId!);
    }
    return ids;
  }

  int? get firstCategoryId =>
      allCategoryIds.isEmpty ? null : allCategoryIds.first;

  bool hasCategory(int id) => allCategoryIds.contains(id);

  // Nama kategori sesuai urutan id. Pakai peta id -> nama dari server.
  List<String> displayCategoryNames(Map<int, String> namesById) {
    final names = <String>[];
    for (final id in allCategoryIds) {
      final name = (namesById[id] ?? '').trim();
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
    }
    if (names.isEmpty && categoryName.trim().isNotEmpty) {
      names.add(categoryName.trim());
    }
    return names;
  }

  PostModel withResolvedCategory(Map<int, String> namesById) {
    final names = displayCategoryNames(namesById);
    return copyWith(
      categoryName: names.isEmpty ? categoryName : names.first,
    );
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? content,
    String? Function()? imageUrl,
    int? Function()? categoryId,
    List<int>? categoryIds,
    String? categoryName,
    int? Function()? authorId,
    String? authorName,
    String? Function()? createdAt,
    String? Function()? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      categoryName: categoryName ?? this.categoryName,
      authorId: authorId != null ? authorId() : this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  static int _toInt(dynamic v, int fallback) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  // Kumpulkan id kategori dari berbagai bentuk respons backend.
  static List<int> _parseIds(dynamic raw) {
    final ids = <int>[];
    void add(dynamic v) {
      final id = _toIntOrNull(v);
      if (id != null && id > 0 && !ids.contains(id)) ids.add(id);
    }

    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          add(e['id']);
        } else {
          add(e);
        }
      }
    } else {
      add(raw);
    }
    return ids;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final ids = _parseIds(
      json['category_ids'] ?? json['categoryIds'] ?? json['categories'],
    );
    final singleId = _toIntOrNull(
      json['category_id'] ?? json['categoryId'],
    );
    if (singleId != null && !ids.contains(singleId)) ids.add(singleId);

    String name = json['categoryName']?.toString() ??
        json['category_name']?.toString() ??
        '';
    final rawCats = json['categories'];
    if (rawCats is List) {
      for (final e in rawCats) {
        if (e is Map) {
          final n = e['name']?.toString() ?? '';
          if (name.isEmpty && n.isNotEmpty) name = n;
        }
      }
    }

    return PostModel(
      id: _toInt(json['id'], 0),
      title: json['title']?.toString() ?? 'Tanpa judul',
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      categoryId: ids.isEmpty ? null : ids.first,
      categoryIds: ids,
      categoryName: name,
      authorId: _toIntOrNull(json['author_id'] ?? json['authorId']),
      authorName: json['authorName']?.toString() ??
          json['author_name']?.toString() ??
          json['author']?.toString() ??
          'Anonymous',
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }
}
