import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/auth_service.dart';
import '../services/blog_service.dart';
import '../widgets/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/post_widgets.dart';
import 'artikel_detail_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<PostModel> _mine = [];
  final Map<int, String> _catName = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isMine(PostModel p) {
    final u = AuthService.currentUser;
    if (u == null) return false;
    if (p.authorId != null && p.authorId == u.id) return true;
    final String a = p.authorName.toLowerCase();
    return a == u.name.toLowerCase() || a == u.username.toLowerCase();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await BlogService.getCategories();
      final posts = await BlogService.getPosts();
      if (!mounted) return;
      final names = {for (final c in cats) c.id: c.name};
      setState(() {
        _catName
          ..clear()
          ..addAll(names);
        _mine = posts
            .map((p) => p.withResolvedCategory(names))
            .where(_isMine)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Keluar?'),
        content:
            const Text('Token sesi akan dihapus dari perangkat.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    String nama = user?.name.trim() ?? '';
    if (nama.isEmpty) nama = 'K';
    String initial = nama[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.surfaceBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.accentFg,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '-',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            '@${user?.username ?? '-'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const EditProfilePage()),
                  );
                  if (changed == true && mounted) {
                    setState(() {});
                    _load();
                  }
                },
                child: const Text('Edit profil'),
              ),
              const SizedBox(height: 20),
              Text(
                'Artikel Saya (${_mine.length})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingView(),
                )
              else if (_error != null)
                ErrorView(message: _error!, onRetry: _load)
              else if (_mine.isEmpty)
                const EmptyView(
                    message: 'Belum ada artikel milikmu.')
              else
                ..._mine.map((p) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: PostFeedCard(
                        post: p,
                        categoryNames: _catName,
                        onTap: () async {
                          final changed =
                              await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ArtikelDetailPage(
                                        postId: p.id)),
                          );
                          if (changed == true && mounted) {
                            _load();
                          }
                        },
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _name = TextEditingController(text: u?.name ?? '');
    _username = TextEditingController(text: u?.username ?? '');
    _email = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.updateProfile(
        name: _name.text,
        username: _username.text,
        email: _email.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading:
            const BackButton(color: AppColors.textPrimary),
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _name,
                label: 'Nama',
                hint: 'Nama lengkap',
                validator: (v) => validateRequired(v, 'Nama'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _username,
                label: 'Username',
                hint: 'tanpaspasi',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Username wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Username minimal 3 karakter';
                  }
                  if (v.contains(' ')) return 'Username tanpa spasi';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _email,
                label: 'Email',
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentFg))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
