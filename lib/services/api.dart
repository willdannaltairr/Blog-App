import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _serverMsg =
    'Tidak bisa terhubung ke server. Pastikan HP dan laptop satu WiFi dan backend jalan.';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user_session';
  static const String _baseUrlKey = 'custom_base_url';

  static String? _token;
  static UserModel? _currentUser;

  static String? get token => _token;
  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://10.2.11.153:8000';
    try {
      if (Platform.isAndroid) return 'http://192.168.1.15:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
  }

  static Map<String, String> _headers({bool withAuth = false}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
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

  static UserModel? _parseUser(Map<String, dynamic> json) {
    var raw = json['user'] ?? json['data'];
    if (raw is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static String? _parseToken(Map<String, dynamic> json) {
    var t = json['token'];
    if (t is String && t.isNotEmpty) return t;
    return null;
  }

  static Future<void> _save(UserModel user, String token) async {
    _currentUser = user;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    String? savedUser = prefs.getString(_userKey);
    if (savedUser != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(savedUser));
      } catch (_) {
        _currentUser = null;
      }
    }

    if (_token != null && _token!.isNotEmpty) {
      try {
        UserModel me = await fetchMe();
        await _save(me, _token!);
      } catch (_) {
        await logout();
      }
    }
  }

  static Future<UserModel> login(String email, String password) async {
    String base = await getBaseUrl();
    String body = jsonEncode({'email': email.trim(), 'password': password});

    try {
      var res = await http
          .post(
            Uri.parse('$base/api/auth/login'),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      var json = _decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        var user = _parseUser(json);
        var token = _parseToken(json);
        if (user != null && token != null) {
          await _save(user, token);
          return user;
        }
      }
      if (res.statusCode != 404) {
        throw Exception(
            json['message'] ?? 'Login gagal. Periksa email & password.');
      }
    } on TimeoutException {
      throw Exception(_serverMsg);
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Login gagal') || msg.contains('Tidak bisa terhubung')) {
        rethrow;
      }
    }

    try {
      var res = await http
          .post(
            Uri.parse('$base/api/login'),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      var json = _decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        var user = _parseUser(json);
        if (user == null) throw Exception('Respons login tidak valid.');
        String token = _parseToken(json) ?? 'legacy-${user.id}';
        await _save(user, token);
        return user;
      }
      throw Exception(
          json['message'] ?? 'Login gagal. Periksa email & password.');
    } on TimeoutException {
      throw Exception(_serverMsg);
    }
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    String base = await getBaseUrl();
    String body = jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });

    try {
      var res = await http
          .post(
            Uri.parse('$base/api/auth/register'),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      var json = _decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        var user = _parseUser(json);
        var token = _parseToken(json);
        if (user != null && token != null) {
          await _save(user, token);
          return user;
        }
        return await login(email.trim(), password);
      }
      if (res.statusCode != 404) {
        var errors = json['errors'];
        if (errors is List && errors.isNotEmpty) {
          throw Exception(errors.first.toString());
        }
        throw Exception(json['message'] ?? 'Registrasi gagal.');
      }
    } on TimeoutException {
      throw Exception(_serverMsg);
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Registrasi gagal') ||
          msg.contains('sudah terdaftar') ||
          msg.contains('Tidak bisa terhubung')) {
        rethrow;
      }
    }

    try {
      var res = await http
          .post(
            Uri.parse('$base/api/users'),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      var json = _decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return await login(email.trim(), password);
      }
      var errors = json['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw Exception(errors.first.toString());
      }
      throw Exception(json['message'] ?? 'Registrasi gagal.');
    } on TimeoutException {
      throw Exception(_serverMsg);
    }
  }

  static Future<UserModel> fetchMe() async {
    String base = await getBaseUrl();
    var res = await http
        .get(
          Uri.parse('$base/api/auth/me'),
          headers: _headers(withAuth: true),
        )
        .timeout(const Duration(seconds: 15));
    var json = _decode(res.body);

    if (res.statusCode == 200) {
      var user = _parseUser(json);
      if (user != null) return user;
    }
    throw Exception(json['message'] ?? 'Sesi berakhir.');
  }

  static Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? email,
  }) async {
    if (_currentUser == null) {
      throw Exception('Sesi berakhir. Login ulang.');
    }

    String base = await getBaseUrl();
    Map<String, dynamic> payload = {};
    if (name != null) payload['name'] = name.trim();
    if (email != null) payload['email'] = email.trim();

    var res = await http
        .put(
          Uri.parse('$base/api/auth/me'),
          headers: _headers(withAuth: true),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));
    var json = _decode(res.body);

    if (res.statusCode == 200) {
      var user = _parseUser(json);
      if (user == null) throw Exception('Respons server tidak valid.');

      String token = _parseToken(json) ?? _token ?? '';
      String uname = (username ?? _currentUser!.username).trim();
      if (uname.isEmpty) uname = _currentUser!.username;

      UserModel updated = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        username: uname,
        avatarUrl: _currentUser!.avatarUrl,
        createdAt: _currentUser!.createdAt,
      );
      await _save(updated, token);
      return updated;
    }

    if (res.statusCode == 401) {
      throw Exception(json['message'] ?? 'Sesi berakhir.');
    }
    var errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw Exception(errors.map((e) => e.toString()).join(', '));
    }
    throw Exception(json['message'] ?? 'Gagal mengupdate profil');
  }

  static Future<void> logout() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

class ApiService {
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
