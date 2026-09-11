// Kode bersama untuk struktur pages-only: tema, model, service, widget.
// Gaya Threads: minimalis, divider tipis, tipografi Inter, hitam/putih dominan.
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ================= KONSTANTA =================

class AppConstants {
  static const String logoPath = 'assets/images/logo.png';
  static const String appName = 'Blog';
  static const int splashDelayMs = 1800;
  static const int searchDebounceMs = 400;
  static const int feedPageLimit = 10;
  static const double feedDividerHeight = 1;
  static const double inputRadius = 10;
  static const double buttonRadius = 10;
  static const double imageRadius = 10;
}

// ================= TEMA THREADS =================

class ThreadsColors {
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFA8A8A8);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkButtonBg = Color(0xFFFFFFFF);
  static const Color darkButtonFg = Color(0xFF000000);
  static const Color darkInputBg = Color(0xFF000000);
  static const Color error = Color(0xFFE5484D);
}

class AppTheme {
  static TextTheme _inter(TextTheme base, Color primary, Color secondary) {
    final t = GoogleFonts.interTextTheme(base);
    return t.copyWith(
      titleSmall: t.titleSmall?.copyWith(
          color: primary, fontWeight: FontWeight.w700, fontSize: 14),
      titleMedium: t.titleMedium?.copyWith(
          color: primary, fontWeight: FontWeight.w700, fontSize: 15),
      bodyMedium: t.bodyMedium?.copyWith(
          color: primary, fontWeight: FontWeight.w400, fontSize: 14, height: 1.5),
      bodySmall: t.bodySmall?.copyWith(
          color: secondary, fontWeight: FontWeight.w400, fontSize: 12),
    );
  }

  static ThemeData get darkTheme {
    const primary = ThreadsColors.darkPrimaryText;
    const secondary = ThreadsColors.darkSecondaryText;
    const divider = ThreadsColors.darkDivider;
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ThreadsColors.darkBackground,
      dividerColor: divider,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: ThreadsColors.darkSurface,
        onPrimary: ThreadsColors.darkButtonFg,
        onSurface: primary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: _inter(base.textTheme, primary, secondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThreadsColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
            color: primary, fontSize: 17, fontWeight: FontWeight.w700),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThreadsColors.darkBackground,
        selectedItemColor: primary,
        unselectedItemColor: secondary,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
          color: divider, thickness: 0.8, space: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThreadsColors.darkInputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputRadius),
          borderSide:
              const BorderSide(color: ThreadsColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputRadius),
          borderSide:
              const BorderSide(color: ThreadsColors.error, width: 1),
        ),
        hintStyle: const TextStyle(color: secondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThreadsColors.darkButtonBg,
          foregroundColor: ThreadsColors.darkButtonFg,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ================= UTIL =================

String timeAgo(String? isoString) {
  if (isoString == null || isoString.isEmpty) return 'baru saja';
  try {
    final dt = DateTime.parse(isoString).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return 'baru saja';
  }
}

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
  final t = v.trim();
  if (!t.contains('@') || !t.contains('.')) return 'Format email tidak valid';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password wajib diisi';
  if (v.length < 6) return 'Password minimal 6 karakter';
  return null;
}

String? validateRequired(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label wajib diisi';
  return null;
}

String? validateUsername(String? v) {
  if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
  if (v.trim().length < 3) return 'Username minimal 3 karakter';
  if (v.contains(' ')) return 'Username tanpa spasi';
  return null;
}

// ================= MODEL =================

class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    String? username,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  }) : username = (username == null || username.isEmpty)
            ? email.split('@').first
            : username;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString().isNotEmpty == true
          ? json['username'].toString()
          : email.split('@').first,
      email: email,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatarUrl']?.toString() ??
          json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final int blogCount;
  final String? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.blogCount = 0,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    final raw = json['blog_count'] ?? json['blogCount'];
    if (raw is int) {
      count = raw;
    } else if (raw != null) {
      count = int.tryParse(raw.toString()) ?? 0;
    }
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      blogCount: count,
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class BlogModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final int? categoryId;
  final String categoryName;
  final int? authorId;
  final String authorName;
  final String? authorAvatar;
  final String? createdAt;
  final String? updatedAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.categoryId,
    this.categoryName = '',
    this.authorId,
    this.authorName = 'Anonymous',
    this.authorAvatar,
    this.createdAt,
    this.updatedAt,
  });

  // Kompatibel backend lama (category_id tunggal, author string)
  // maupun kontrak baru (categories array, authorName, dsb).
  factory BlogModel.fromJson(Map<String, dynamic> json) {
    String catName = json['categoryName']?.toString() ??
        json['category_name']?.toString() ??
        '';
    int? catId;
    final rawCatId = json['category_id'] ?? json['categoryId'];
    if (rawCatId is int) {
      catId = rawCatId;
    } else if (rawCatId != null) {
      catId = int.tryParse(rawCatId.toString());
    }

    // Dukungan format lama many-to-many bila backend mengirimnya.
    final rawCats = json['categories'];
    if (rawCats is List && rawCats.isNotEmpty) {
      final first = rawCats.first;
      if (first is Map) {
        final m = Map<String, dynamic>.from(first);
        catId ??= m['id'] is int
            ? m['id'] as int
            : int.tryParse(m['id']?.toString() ?? '');
        if (catName.isEmpty) catName = m['name']?.toString() ?? '';
      }
    }

    int? authId;
    final rawAuthId = json['author_id'] ?? json['authorId'];
    if (rawAuthId is int) {
      authId = rawAuthId;
    } else if (rawAuthId != null) {
      authId = int.tryParse(rawAuthId.toString());
    }

    return BlogModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Tanpa judul',
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      categoryId: catId,
      categoryName: catName,
      authorId: authId,
      authorName: json['authorName']?.toString() ??
          json['author_name']?.toString() ??
          json['author']?.toString() ??
          'Anonymous',
      authorAvatar: json['authorAvatar']?.toString() ??
          json['author_avatar']?.toString() ??
          json['avatar']?.toString(),
      createdAt: json['createdAt']?.toString() ??
          json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ??
          json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'image': imageUrl,
        'category_id': categoryId,
        'author': authorName,
      };

  // Payload sesuai validasi Express (zod): category_id tunggal.
  Map<String, dynamic> toApiPayload() => {
        'title': title,
        'content': content,
        'author': authorName,
        'image': imageUrl,
        'category_id': categoryId,
      };
}

// ================= SERVICE =================

class AuthService {
  static const String _userKey = 'cached_user_session';
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return;
    try {
      _currentUser =
          UserModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {
      _currentUser = null;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Edit profil lokal (backend belum menyediakan PUT /users/me).
  static Future<void> updateLocalProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final cur = _currentUser;
    if (cur == null) return;
    final next = UserModel(
      id: cur.id,
      name: (name ?? cur.name).trim().isEmpty ? cur.name : (name ?? cur.name),
      email: cur.email,
      username: username ?? cur.username,
      avatarUrl: avatarUrl ?? cur.avatarUrl,
      bio: bio ?? cur.bio,
      createdAt: cur.createdAt,
    );
    await saveUser(next);
  }

  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

class ApiService {
  static const String _baseUrlKey = 'custom_base_url';

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  static String _activeBaseUrl = '';

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

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      return {'data': v};
    } catch (_) {
      return {};
    }
  }

  static Future<UserModel> login(String email, String password) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/login'),
      headers: _headers,
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    final data = _decode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final userJson = data['data'];
      if (userJson is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
      throw Exception('Respons login tidak valid.');
    }
    throw Exception(data['message']?.toString() ??
        'Login gagal. Periksa email & password.');
  }

  // Backend register hanya mengembalikan message, jadi auto-login sesudahnya.
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? username,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/users'),
      headers: _headers,
      body: jsonEncode(
          {'name': name.trim(), 'email': email.trim(), 'password': password}),
    );
    final data = _decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final userJson = data['data'];
      if (userJson is Map) {
        final u = UserModel.fromJson(Map<String, dynamic>.from(userJson));
        return UserModel(
          id: u.id,
          name: u.name.isEmpty ? name.trim() : u.name,
          email: u.email.isEmpty ? email.trim() : u.email,
          username: username?.trim().isNotEmpty == true
              ? username!.trim()
              : u.username,
          createdAt: u.createdAt,
        );
      }
      final logged = await login(email.trim(), password);
      return UserModel(
        id: logged.id,
        name: logged.name,
        email: logged.email,
        username: username?.trim().isNotEmpty == true
            ? username!.trim()
            : logged.username,
        createdAt: logged.createdAt,
      );
    }
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) {
      throw Exception(errs.first.toString());
    }
    throw Exception(data['message']?.toString() ?? 'Registrasi gagal.');
  }

  static Future<List<CategoryModel>> getCategories() async {
    final base = await getBaseUrl();
    final res =
        await http.get(Uri.parse('$base/api/categories'), headers: _headers);
    if (res.statusCode == 200) {
      final data = _decode(res.body);
      final raw = data['data'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => CategoryModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }
    throw Exception('Gagal memuat kategori');
  }

  static Future<CategoryModel> createCategory(String name) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/categories'),
      headers: _headers,
      body: jsonEncode({'name': name.trim()}),
    );
    final data = _decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final cj = data['data'];
      if (cj is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(cj));
      }
      // Fallback: ambil ulang untuk dapat id baru.
      final all = await getCategories();
      return all.firstWhere(
        (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
        orElse: () => CategoryModel(id: 0, name: name.trim()),
      );
    }
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) throw Exception(errs.first.toString());
    throw Exception(data['message']?.toString() ?? 'Gagal membuat kategori');
  }

  static Future<CategoryModel> updateCategory(int id, String name) async {
    final base = await getBaseUrl();
    final res = await http.put(
      Uri.parse('$base/api/categories/$id'),
      headers: _headers,
      body: jsonEncode({'name': name.trim()}),
    );
    final data = _decode(res.body);
    if (res.statusCode == 200) {
      final cj = data['data'];
      if (cj is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(cj));
      }
      return CategoryModel(id: id, name: name.trim());
    }
    throw Exception(data['message']?.toString() ?? 'Gagal mengupdate kategori');
  }

  static Future<void> deleteCategory(int id) async {
    final base = await getBaseUrl();
    final res = await http.delete(Uri.parse('$base/api/categories/$id'),
        headers: _headers);
    if (res.statusCode == 200) return;
    final data = _decode(res.body);
    throw Exception(data['message']?.toString() ?? 'Gagal menghapus kategori');
  }

  // Backend belum ada pagination; page/limit disimulasikan di klien.
  static Future<List<BlogModel>> getBlogs({
    String? search,
    int? categoryId,
    int page = 1,
    int limit = AppConstants.feedPageLimit,
  }) async {
    final base = await getBaseUrl();
    final qp = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      qp['search'] = search.trim();
    }
    if (categoryId != null && categoryId > 0) {
      qp['category_id'] = categoryId.toString();
    }
    final uri = Uri.parse('$base/api/blogs')
        .replace(queryParameters: qp.isEmpty ? null : qp);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) throw Exception('Gagal memuat artikel');
    final data = _decode(res.body);
    final raw = data['data'];
    if (raw is! List) return [];
    final all = raw
        .whereType<Map>()
        .map((e) => BlogModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (limit <= 0) return all;
    final start = (page - 1) * limit;
    if (start >= all.length) return [];
    final end = (start + limit).clamp(0, all.length);
    return all.sublist(start, end);
  }

  // Ambil semua sekaligus (untuk hitung pagination & jumlah per kategori).
  static Future<List<BlogModel>> getAllBlogs(
      {String? search, int? categoryId}) async {
    return getBlogs(search: search, categoryId: categoryId, limit: 0);
  }

  static Future<BlogModel> getBlogById(int id) async {
    final base = await getBaseUrl();
    final res = await http.get(Uri.parse('$base/api/blogs/$id'),
        headers: _headers);
    if (res.statusCode == 200) {
      final data = _decode(res.body);
      final bj = data['data'];
      if (bj is Map) {
        return BlogModel.fromJson(Map<String, dynamic>.from(bj));
      }
    }
    throw Exception('Artikel tidak ditemukan');
  }

  static Future<BlogModel> createBlog({
    required String title,
    required String content,
    required String author,
    String? image,
    required int categoryId,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/api/blogs'),
      headers: _headers,
      body: jsonEncode({
        'title': title.trim(),
        'content': content.trim(),
        'author': author.trim(),
        'image': (image ?? '').trim().isEmpty ? null : image!.trim(),
        'category_id': categoryId,
      }),
    );
    final data = _decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final bj = data['data'];
      if (bj is Map) {
        return BlogModel.fromJson(Map<String, dynamic>.from(bj));
      }
      return BlogModel(
        id: 0,
        title: title.trim(),
        content: content.trim(),
        imageUrl: (image ?? '').trim().isEmpty ? null : image!.trim(),
        categoryId: categoryId,
        authorName: author.trim(),
      );
    }
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) throw Exception(errs.first.toString());
    throw Exception(data['message']?.toString() ?? 'Gagal membuat artikel');
  }

  static Future<void> updateBlog({
    required int id,
    String? title,
    String? content,
    String? author,
    String? image,
    int? categoryId,
  }) async {
    final base = await getBaseUrl();
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title.trim();
    if (content != null) payload['content'] = content.trim();
    if (author != null) payload['author'] = author.trim();
    if (image != null) {
      payload['image'] = image.trim().isEmpty ? null : image.trim();
    }
    if (categoryId != null) payload['category_id'] = categoryId;
    final res = await http.put(
      Uri.parse('$base/api/blogs/$id'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200) return;
    final data = _decode(res.body);
    final errs = data['errors'];
    if (errs is List && errs.isNotEmpty) throw Exception(errs.first.toString());
    throw Exception(data['message']?.toString() ?? 'Gagal mengupdate artikel');
  }

  static Future<void> deleteBlog(int id) async {
    final base = await getBaseUrl();
    final res = await http.delete(Uri.parse('$base/api/blogs/$id'),
        headers: _headers);
    if (res.statusCode == 200) return;
    final data = _decode(res.body);
    throw Exception(data['message']?.toString() ?? 'Gagal menghapus artikel');
  }
}

// ================= WIDGET BERSAMA =================

// True bila url adalah gambar jaringan (bukan path file lokal dari picker).
bool isNetworkUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

// Gambar artikel yang mendukung URL jaringan maupun file lokal
// hasil image_picker saat tambah blog.
Widget blogImageView(
  String url, {
  double placeholderHeight = 180,
  required Color placeholderColor,
  required Color iconColor,
}) {
  Widget fallback(double h) => Container(
        height: h,
        width: double.infinity,
        color: placeholderColor,
        child: Icon(Icons.image_outlined, color: iconColor),
      );
  if (isNetworkUrl(url)) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (c, u) => Container(
        height: placeholderHeight,
        width: double.infinity,
        color: placeholderColor,
      ),
      errorWidget: (c, u, e) => fallback(120),
    );
  }
  // Path file lokal (hasil picker di HP). Image.file tidak didukung Web,
  // jadi di Web coba render sebagai network (blob URL) dengan fallback aman.
  if (!kIsWeb) {
    return Image.file(
      File(url),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => fallback(120),
    );
  }
  return Image.network(
    url,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (c, e, s) => fallback(120),
  );
}

class ThreadsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final bool obscure;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ThreadsTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffix,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: labelStyle?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}

// Item feed Threads: avatar bulat kiri, divider tipis bawah.
class ThreadsBlogItem extends StatelessWidget {
  final BlogModel blog;
  final String categoryLabel;
  final bool isMine;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ThreadsBlogItem({
    super.key,
    required this.blog,
    required this.categoryLabel,
    required this.onTap,
    this.isMine = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.secondary;

    return InkWell(
      onTap: onTap,
      onLongPress: isMine ? onEdit : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: blog.authorName,
                                    style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  TextSpan(
                                    text: ' · ${timeAgo(blog.createdAt)}',
                                    style: TextStyle(
                                        color: secondary,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMine)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: Icon(Icons.more_horiz,
                                  color: secondary, size: 18),
                              onSelected: (v) {
                                if (v == 'edit') onEdit?.call();
                                if (v == 'hapus') onDelete?.call();
                              },
                              itemBuilder: (c) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'hapus', child: Text('Hapus')),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        blog.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.35),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        blog.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.45),
                      ),
                      if (categoryLabel.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(
                                color: secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                      if ((blog.imageUrl ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Hero(
                          tag: 'blog-image-${blog.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppConstants.imageRadius),
                            child: blogImageView(
                              blog.imageUrl!,
                              placeholderColor: theme.dividerColor
                                  .withValues(alpha: 0.4),
                              iconColor: secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: AppConstants.feedDividerHeight),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 44, color: secondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 44, color: ThreadsColors.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondary, fontSize: 14)),
            const SizedBox(height: 14),
            OutlinedButton(
                onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
