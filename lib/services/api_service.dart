import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

// CRUD artikel & kategori ke backend Express. Token JWT dikirim bila ada.
class ApiService {
  static Map<String, String> _headers() {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final t = AuthService.token;
    if (t != null && t.isNotEmpty && !t.startsWith('legacy-')) {
      h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      return {'data': v};
    } catch (_) {
      return {};
    }
  }

  static String _msg(Map<String, dynamic> data, String fallback) {
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) return errs.first.toString();
    return data['message']?.toString() ?? fallback;
  }

  // ---------- Kategori ----------

  static Future<List<CategoryModel>> getCategories() async {
    final base = await AuthService.getBaseUrl();
    final res = await http.get(Uri.parse('$base/api/categories'),
        headers: _headers());
    if (res.statusCode == 200) {
      final raw = _decode(res.body)['data'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) =>
                CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }
    throw Exception('Gagal memuat kategori');
  }

  static Future<CategoryModel> createCategory(String name) async {
    final base = await AuthService.getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/categories'),
      headers: _headers(),
      body: jsonEncode({'name': name.trim()}),
    );
    final data = _decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final cj = data['data'];
      if (cj is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(cj));
      }
      final all = await getCategories();
      return all.firstWhere(
        (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
        orElse: () => CategoryModel(id: 0, name: name.trim()),
      );
    }
    throw Exception(_msg(data, 'Gagal membuat kategori'));
  }

  static Future<void> updateCategory(int id, String name) async {
    final base = await AuthService.getBaseUrl();
    final res = await http.put(
      Uri.parse('$base/api/categories/$id'),
      headers: _headers(),
      body: jsonEncode({'name': name.trim()}),
    );
    if (res.statusCode == 200) return;
    throw Exception(_msg(_decode(res.body), 'Gagal mengupdate kategori'));
  }

  static Future<void> deleteCategory(int id) async {
    final base = await AuthService.getBaseUrl();
    final res = await http.delete(Uri.parse('$base/api/categories/$id'),
        headers: _headers());
    if (res.statusCode == 200) return;
    throw Exception(_msg(_decode(res.body), 'Gagal menghapus kategori'));
  }

  // ---------- Artikel ----------

  static Future<List<PostModel>> getPosts({
    String? search,
    int? categoryId,
  }) async {
    final base = await AuthService.getBaseUrl();
    final qp = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      qp['search'] = search.trim();
    }
    if (categoryId != null && categoryId > 0) {
      qp['category_id'] = categoryId.toString();
    }
    final uri = Uri.parse('$base/api/blogs')
        .replace(queryParameters: qp.isEmpty ? null : qp);
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) throw Exception('Gagal memuat artikel');
    final raw = _decode(res.body)['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => PostModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<PostModel> getPostById(int id) async {
    final base = await AuthService.getBaseUrl();
    final res = await http.get(Uri.parse('$base/api/blogs/$id'),
        headers: _headers());
    if (res.statusCode == 200) {
      final bj = _decode(res.body)['data'];
      if (bj is Map) {
        return PostModel.fromJson(Map<String, dynamic>.from(bj));
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
    final base = await AuthService.getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/blogs'),
      headers: _headers(),
      body: jsonEncode({
        'title': title.trim(),
        'content': content.trim(),
        'author': author.trim(),
        'image': (image ?? '').trim().isEmpty ? null : image!.trim(),
        // Format baru (banyak kategori) + format lama (satu kategori).
        'category_ids': categoryIds,
        'category_id': categoryIds.first,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return;
    throw Exception(_msg(_decode(res.body), 'Gagal membuat artikel'));
  }

  static Future<void> updatePost({
    required int id,
    String? title,
    String? content,
    String? author,
    String? image,
    List<int>? categoryIds,
  }) async {
    final base = await AuthService.getBaseUrl();
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title.trim();
    if (content != null) payload['content'] = content.trim();
    if (author != null) payload['author'] = author.trim();
    if (image != null) {
      payload['image'] = image.trim().isEmpty ? null : image.trim();
    }
    if (categoryIds != null) {
      payload['category_ids'] = categoryIds;
      payload['category_id'] = categoryIds.first;
    }
    final res = await http.put(
      Uri.parse('$base/api/blogs/$id'),
      headers: _headers(),
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200) return;
    throw Exception(_msg(_decode(res.body), 'Gagal mengupdate artikel'));
  }

  static Future<void> deletePost(int id) async {
    final base = await AuthService.getBaseUrl();
    final res = await http.delete(Uri.parse('$base/api/blogs/$id'),
        headers: _headers());
    if (res.statusCode == 200) return;
    throw Exception(_msg(_decode(res.body), 'Gagal menghapus artikel'));
  }
}
