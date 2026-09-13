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

  List<int> get allCategoryIds {
    List<int> ids = List.from(categoryIds);
    if (categoryId != null && !ids.contains(categoryId)) {
      ids.add(categoryId!);
    }
    return ids;
  }

  bool hasCategory(int id) {
    return allCategoryIds.contains(id);
  }

  List<String> displayCategoryNames(Map<int, String> namesById) {
    List<String> names = [];
    for (int id in allCategoryIds) {
      String name = (namesById[id] ?? '').trim();
      if (name.isNotEmpty && !names.contains(name)) {
        names.add(name);
      }
    }
    if (names.isEmpty && categoryName.trim().isNotEmpty) {
      names.add(categoryName.trim());
    }
    return names;
  }

  PostModel withResolvedCategory(Map<int, String> namesById) {
    List<String> names = displayCategoryNames(namesById);
    return copyWith(
      categoryName: names.isEmpty ? categoryName : names.first,
    );
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? content,
    String? imageUrl,
    int? categoryId,
    List<int>? categoryIds,
    String? categoryName,
    int? authorId,
    String? authorName,
    String? createdAt,
    String? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      categoryName: categoryName ?? this.categoryName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int toInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<int> parseIds(dynamic raw) {
    List<int> ids = [];

    void addOne(dynamic v) {
      int? id = toIntOrNull(v);
      if (id != null && id > 0 && !ids.contains(id)) {
        ids.add(id);
      }
    }

    if (raw is List) {
      for (var item in raw) {
        if (item is Map && item['id'] != null) {
          addOne(item['id']);
        } else {
          addOne(item);
        }
      }
    } else if (raw != null) {
      addOne(raw);
    }
    return ids;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<int> ids = parseIds(
      json['category_ids'] ?? json['categoryIds'] ?? json['categories'],
    );

    int? singleId = toIntOrNull(json['category_id'] ?? json['categoryId']);
    if (singleId != null && !ids.contains(singleId)) {
      ids.add(singleId);
    }

    String catName = json['category_name']?.toString() ??
        json['categoryName']?.toString() ??
        '';

    if (json['categories'] is List && catName.isEmpty) {
      for (var item in json['categories']) {
        if (item is Map && item['name'] != null) {
          catName = item['name'].toString();
          break;
        }
      }
    }

    return PostModel(
      id: toInt(json['id'], 0),
      title: json['title']?.toString() ?? 'Tanpa judul',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      categoryId: ids.isEmpty ? null : ids.first,
      categoryIds: ids,
      categoryName: catName,
      authorId: toIntOrNull(json['author_id'] ?? json['authorId']),
      authorName: json['author']?.toString() ??
          json['author_name']?.toString() ??
          json['authorName']?.toString() ??
          'Anonymous',
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt:
          json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
    );
  }
}
