import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

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
    if (kIsWeb) return 'http://10.2.15.67:8000';
    try {
      if (Platform.isAndroid) return 'http://127.0.0.1:8000';
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
