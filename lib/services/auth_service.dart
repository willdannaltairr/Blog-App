import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Menyimpan token JWT + data user, dan memanggil endpoint auth.
// Coba endpoint baru /api/auth/* dulu, fallback ke endpoint lama
// (/api/users & /api/login) supaya tetap jalan walau backend belum diupdate.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user_session';
  static const String _baseUrlKey = 'custom_base_url';

  static String? _token;
  static UserModel? _currentUser;
  static String _activeBaseUrl = '';

  static String? get token => _token;
  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://10.2.11.153:8000';
    try {
      if (Platform.isAndroid) return 'http://10.2.11.153:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  static Future<String> getBaseUrl() async {
    if (_activeBaseUrl.isNotEmpty) return _activeBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    _activeBaseUrl = prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
    return _activeBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    var next = url.trim();
    if (next.endsWith('/')) next = next.substring(0, next.length - 1);
    _activeBaseUrl = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, next);
  }

  static Map<String, String> _headers({bool withAuth = false}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
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

  static UserModel? _parseUser(Map<String, dynamic> data) {
    final raw = data['user'] ?? data['data'];
    if (raw is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static String? _parseToken(Map<String, dynamic> data) {
    final t = data['token'];
    if (t is String && t.isNotEmpty) return t;
    return null;
  }

  // Dipanggil sekali dari main() sebelum runApp.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final raw = prefs.getString(_userKey);
    if (raw != null) {
      try {
        _currentUser =
            UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
      } catch (_) {
        _currentUser = null;
      }
    }
    // Validasi token ke server; kalau basi, hapus agar splash ke Login.
    if (_token != null && _token!.isNotEmpty) {
      try {
        final me = await fetchMe();
        await _persist(me, _token!);
      } catch (_) {
        await logout();
      }
    }
  }

  static Future<void> _persist(UserModel user, String token) async {
    _currentUser = user;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel> login(String email, String password) async {
    final base = await getBaseUrl();
    final body =
        jsonEncode({'email': email.trim(), 'password': password});

    // 1) Endpoint baru.
    try {
      final res = await http.post(
        Uri.parse('$base/api/auth/login'),
        headers: _headers(),
        body: body,
      );
      final data = _decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final user = _parseUser(data);
        final token = _parseToken(data);
        if (user != null && token != null) {
          await _persist(user, token);
          return user;
        }
      }
      // Kalau 404 (backend lama tanpa rute ini), lanjut ke fallback.
      if (res.statusCode != 404) {
        throw Exception(data['message']?.toString() ??
            'Login gagal. Periksa email & password.');
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('Failed host lookup') &&
          !e.toString().contains('Connection refused') &&
          !e.toString().contains('Login gagal') &&
          !e.toString().contains('Email atau password')) {
        // Error jaringan/parsing pada endpoint baru -> coba fallback.
      } else if (e is Exception &&
          (e.toString().contains('Email atau password') ||
              e.toString().contains('Login gagal'))) {
        rethrow;
      }
    }

    // 2) Fallback endpoint lama.
    final res = await http.post(
      Uri.parse('$base/api/login'),
      headers: _headers(),
      body: body,
    );
    final data = _decode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final user = _parseUser(data);
      if (user == null) throw Exception('Respons login tidak valid.');
      final token = _parseToken(data) ?? 'legacy-${user.id}';
      await _persist(user, token);
      return user;
    }
    throw Exception(data['message']?.toString() ??
        'Login gagal. Periksa email & password.');
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final base = await getBaseUrl();
    final body = jsonEncode(
        {'name': name.trim(), 'email': email.trim(), 'password': password});

    try {
      final res = await http.post(
        Uri.parse('$base/api/auth/register'),
        headers: _headers(),
        body: body,
      );
      final data = _decode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        final user = _parseUser(data);
        final token = _parseToken(data);
        if (user != null && token != null) {
          await _persist(user, token);
          return user;
        }
        // Backend baru tapi tanpa token? anggap sukses, auto-login.
        return await login(email.trim(), password);
      }
      if (res.statusCode != 404) {
        final errs = data['errors'];
        if (errs is List && errs.isNotEmpty) {
          throw Exception(errs.first.toString());
        }
        throw Exception(data['message']?.toString() ?? 'Registrasi gagal.');
      }
    } catch (e) {
      if (e is Exception &&
          (e.toString().contains('Registrasi gagal') ||
              e.toString().contains('Email sudah terdaftar') ||
              e.toString().contains('Validasi gagal'))) {
        rethrow;
      }
    }

    // Fallback: backend lama hanya mengembalikan message.
    final res = await http.post(
      Uri.parse('$base/api/users'),
      headers: _headers(),
      body: body,
    );
    final data = _decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return login(email.trim(), password);
    }
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) {
      throw Exception(errs.first.toString());
    }
    throw Exception(data['message']?.toString() ?? 'Registrasi gagal.');
  }

  static Future<UserModel> fetchMe() async {
    final base = await getBaseUrl();
    final res = await http.get(
      Uri.parse('$base/api/auth/me'),
      headers: _headers(withAuth: true),
    );
    final data = _decode(res.body);
    if (res.statusCode == 200) {
      final user = _parseUser(data);
      if (user != null) return user;
    }
    throw Exception(data['message']?.toString() ?? 'Sesi berakhir.');
  }

  // Edit profil lokal (backend belum ada PUT /users/me).
  static Future<void> updateLocalProfile({
    String? name,
    String? username,
    String? email,
    String? avatarUrl,
  }) async {
    final cur = _currentUser;
    if (cur == null) return;
    final nextName =
        (name ?? cur.name).trim().isEmpty ? cur.name : (name ?? cur.name).trim();
    final nextUsername = (username ?? cur.username).trim().isEmpty
        ? cur.username
        : (username ?? cur.username).trim();
    final nextEmail = (email ?? cur.email).trim().isEmpty
        ? cur.email
        : (email ?? cur.email).trim();
    final next = UserModel(
      id: cur.id,
      name: nextName,
      email: nextEmail,
      username: nextUsername,
      avatarUrl: avatarUrl ?? cur.avatarUrl,
      createdAt: cur.createdAt,
    );
    _currentUser = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(next.toJson()));
  }

  static Future<void> logout() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
