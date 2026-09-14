import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';
import 'auth_service.dart';

class BlogService {
  static Map<String, String> _headers() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    String? token = AuthService.token;
    if (token != null && token.isNotEmpty && !token.startsWith('legacy-')) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      var json = jsonDecode(body);
      if (json is Map<String, dynamic>) return json;
      return {'data': json};
    } catch (_) {
      return {};
    }
  }

  static String _errorMsg(Map<String, dynamic> json, String fallback) {
    var errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }
    return json['message']?.toString() ?? fallback;
  }

  static Future<List<CategoryModel>> getCategories() async {
    String base = await AuthService.getBaseUrl();
    var res = await http
        .get(Uri.parse('$base/api/categories'), headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) throw Exception('Gagal memuat kategori');

    var list = _decode(res.body)['data'];
    if (list is! List) return [];

    List<CategoryModel> result = [];
    for (var item in list) {
      if (item is Map) {
        result.add(CategoryModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  static Future<CategoryModel> createCategory(String name) async {
    String base = await AuthService.getBaseUrl();
    var res = await http
        .post(
          Uri.parse('$base/api/categories'),
          headers: _headers(),
          body: jsonEncode({'name': name.trim()}),
        )
        .timeout(const Duration(seconds: 15));
    var json = _decode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      var raw = json['data'];
      if (raw is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
      }
      List<CategoryModel> all = await getCategories();
      for (var c in all) {
        if (c.name.toLowerCase() == name.trim().toLowerCase()) return c;
      }
      return CategoryModel(id: 0, name: name.trim());
    }
    throw Exception(_errorMsg(json, 'Gagal membuat kategori'));
  }

  static Future<List<PostModel>> getPosts({
    String? search,
    int? categoryId,
  }) async {
    String base = await AuthService.getBaseUrl();

    Map<String, String> query = {};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (categoryId != null && categoryId > 0) {
      query['category_id'] = categoryId.toString();
    }

    var url = Uri.parse('$base/api/blogs')
        .replace(queryParameters: query.isEmpty ? null : query);
    var res = await http
        .get(url, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) throw Exception('Gagal memuat artikel');

    var list = _decode(res.body)['data'];
    if (list is! List) return [];

    List<PostModel> result = [];
    for (var item in list) {
      if (item is Map) {
        result.add(PostModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  static Future<PostModel> getPostById(int id) async {
    String base = await AuthService.getBaseUrl();
    var res = await http
        .get(Uri.parse('$base/api/blogs/$id'), headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      var raw = _decode(res.body)['data'];
      if (raw is Map) {
        return PostModel.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    throw Exception('Artikel tidak ditemukan');
  }

  static Future<void> createPost({
    required String title,
    required String content,
    required String author,
    String? image,
    required List<int> categoryIds,
  }) async {
    if (categoryIds.isEmpty) throw Exception('Pilih minimal 1 kategori');

    String base = await AuthService.getBaseUrl();
    String? img = (image ?? '').trim().isEmpty ? null : image!.trim();

    var res = await http
        .post(
          Uri.parse('$base/api/blogs'),
          headers: _headers(),
          body: jsonEncode({
            'title': title.trim(),
            'content': content.trim(),
            'author': author.trim(),
            'image': img,
            'category_ids': categoryIds,
            'category_id': categoryIds.first,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200 || res.statusCode == 201) return;
    throw Exception(_errorMsg(_decode(res.body), 'Gagal membuat artikel'));
  }

  static Future<void> updatePost({
    required int id,
    String? title,
    String? content,
    String? author,
    String? image,
    List<int>? categoryIds,
  }) async {
    String base = await AuthService.getBaseUrl();
    Map<String, dynamic> payload = {};

    if (title != null) payload['title'] = title.trim();
    if (content != null) payload['content'] = content.trim();
    if (author != null) payload['author'] = author.trim();
    if (image != null) {
      payload['image'] = image.trim().isEmpty ? null : image.trim();
    }
    if (categoryIds != null) {
      if (categoryIds.isEmpty) throw Exception('Pilih minimal 1 kategori');
      payload['category_ids'] = categoryIds;
      payload['category_id'] = categoryIds.first;
    }

    var res = await http
        .put(
          Uri.parse('$base/api/blogs/$id'),
          headers: _headers(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) return;
    throw Exception(_errorMsg(_decode(res.body), 'Gagal mengupdate artikel'));
  }

  static Future<void> deletePost(int id) async {
    String base = await AuthService.getBaseUrl();
    var res = await http
        .delete(Uri.parse('$base/api/blogs/$id'), headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) return;
    throw Exception(_errorMsg(_decode(res.body), 'Gagal menghapus artikel'));
  }
}
