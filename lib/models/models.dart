int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _toIntNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    String? username,
    this.avatarUrl,
    this.createdAt,
  }) : username = (username == null || username.isEmpty)
            ? email.split('@').first
            : username;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String email = json['email']?.toString() ?? '';
    String uname = json['username']?.toString() ?? '';
    if (uname.isEmpty && email.contains('@')) {
      uname = email.split('@').first;
    }
    return UserModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: email,
      username: uname,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatarUrl']?.toString() ??
          json['avatar']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? createdAt;

  CategoryModel({required this.id, required this.name, this.createdAt});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}

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

  List<String> displayCategoryNames(Map<int, String> names) {
    List<String> result = [];
    for (int id in allCategoryIds) {
      String name = (names[id] ?? '').trim();
      if (name.isNotEmpty && !result.contains(name)) {
        result.add(name);
      }
    }
    if (result.isEmpty && categoryName.trim().isNotEmpty) {
      result.add(categoryName.trim());
    }
    return result;
  }

  PostModel withResolvedCategory(Map<int, String> names) {
    List<String> list = displayCategoryNames(names);
    return PostModel(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      categoryId: categoryId,
      categoryIds: categoryIds,
      categoryName: list.isEmpty ? categoryName : list.first,
      authorId: authorId,
      authorName: authorName,
      createdAt: createdAt,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<int> ids = [];
    var rawIds =
        json['category_ids'] ?? json['categoryIds'] ?? json['categories'];
    if (rawIds is List) {
      for (var item in rawIds) {
        int? id = item is Map ? _toIntNull(item['id']) : _toIntNull(item);
        if (id != null && id > 0 && !ids.contains(id)) ids.add(id);
      }
    } else if (rawIds != null) {
      int? id = _toIntNull(rawIds);
      if (id != null && id > 0) ids.add(id);
    }

    int? single = _toIntNull(json['category_id'] ?? json['categoryId']);
    if (single != null && single > 0 && !ids.contains(single)) {
      ids.add(single);
    }

    String catName = json['category_name']?.toString() ??
        json['categoryName']?.toString() ??
        '';
    if (catName.isEmpty && json['categories'] is List) {
      for (var item in json['categories']) {
        if (item is Map && item['name'] != null) {
          catName = item['name'].toString();
          break;
        }
      }
    }

    return PostModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? 'Tanpa judul',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      categoryId: ids.isEmpty ? null : ids.first,
      categoryIds: ids,
      categoryName: catName,
      authorId: _toIntNull(json['author_id'] ?? json['authorId']),
      authorName: json['author']?.toString() ??
          json['author_name']?.toString() ??
          json['authorName']?.toString() ??
          'Anonymous',
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}
