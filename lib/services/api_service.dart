import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

// Fetch sederhana pakai package http ^1.6.0.
// Pola dasar: Uri.parse -> http.get/post/put/delete -> jsonDecode.
class ApiService {
  // Header JSON dasar + token bila ada.
  static Map<String, String> _headers() {
    final Map<String, String> h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String? t = AuthService.token;
    if (t != null && t.isNotEmpty && !t.startsWith('legacy-')) {
      h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // Ubah body string jadi Map agar aman dibaca.
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
    if (errs is List && errs.isNotEmpty) {
      return errs.map((e) => e.toString()).join(', ');
    }
    return data['message']?.toString() ?? fallback;
  }

  // ---------- Kategori ----------

  static Future<List<CategoryModel>> getCategories() async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/categories');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final raw = _decode(response.body)['data'];
      if (raw is List) {
        final List<CategoryModel> list = [];
        for (final e in raw) {
          if (e is Map) {
            list.add(CategoryModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
        return list;
      }
      return [];
    }
    throw Exception('Gagal memuat kategori');
  }

  static Future<CategoryModel> createCategory(String name) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/categories');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({'name': name.trim()}),
    );
    final Map<String, dynamic> data = _decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final cj = data['data'];
      if (cj is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(cj));
      }
      final List<CategoryModel> all = await getCategories();
      for (final c in all) {
        if (c.name.toLowerCase() == name.trim().toLowerCase()) return c;
      }
      return CategoryModel(id: 0, name: name.trim());
    }
    throw Exception(_msg(data, 'Gagal membuat kategori'));
  }

  static Future<void> updateCategory(int id, String name) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/categories/$id');
    final response = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode({'name': name.trim()}),
    );
    if (response.statusCode == 200) return;
    throw Exception(_msg(_decode(response.body), 'Gagal mengupdate kategori'));
  }

  static Future<void> deleteCategory(int id) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/categories/$id');
    final response = await http.delete(url, headers: _headers());
    if (response.statusCode == 200) return;
    throw Exception(_msg(_decode(response.body), 'Gagal menghapus kategori'));
  }

  // ---------- Artikel ----------

  static Future<List<PostModel>> getPosts({
    String? search,
    int? categoryId,
  }) async {
    final String base = await AuthService.getBaseUrl();
    final Map<String, String> qp = {};
    if (search != null && search.trim().isNotEmpty) {
      qp['search'] = search.trim();
    }
    if (categoryId != null && categoryId > 0) {
      qp['category_id'] = categoryId.toString();
    }
    final Uri url =
        Uri.parse('$base/api/blogs').replace(queryParameters: qp.isEmpty ? null : qp);
    final response = await http.get(url, headers: _headers());
    if (response.statusCode != 200) throw Exception('Gagal memuat artikel');
    final raw = _decode(response.body)['data'];
    if (raw is! List) return [];
    final List<PostModel> list = [];
    for (final e in raw) {
      if (e is Map) list.add(PostModel.fromJson(Map<String, dynamic>.from(e)));
    }
    return list;
  }

  static Future<PostModel> getPostById(int id) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/blogs/$id');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final bj = _decode(response.body)['data'];
      if (bj is Map) return PostModel.fromJson(Map<String, dynamic>.from(bj));
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
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/blogs');
    final String? img = (image ?? '').trim().isEmpty ? null : image!.trim();
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'title': title.trim(),
        'content': content.trim(),
        'author': author.trim(),
        'image': img,
        'category_ids': categoryIds,
        'category_id': categoryIds.first,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) return;
    throw Exception(_msg(_decode(response.body), 'Gagal membuat artikel'));
  }

  static Future<void> updatePost({
    required int id,
    String? title,
    String? content,
    String? author,
    String? image,
    List<int>? categoryIds,
  }) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/blogs/$id');
    final Map<String, dynamic> payload = {};
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
    final response =
        await http.put(url, headers: _headers(), body: jsonEncode(payload));
    if (response.statusCode == 200) return;
    throw Exception(_msg(_decode(response.body), 'Gagal mengupdate artikel'));
  }

  static Future<void> deletePost(int id) async {
    final String base = await AuthService.getBaseUrl();
    final Uri url = Uri.parse('$base/api/blogs/$id');
    final response = await http.delete(url, headers: _headers());
    if (response.statusCode == 200) return;
    throw Exception(_msg(_decode(response.body), 'Gagal menghapus artikel'));
  }
}
