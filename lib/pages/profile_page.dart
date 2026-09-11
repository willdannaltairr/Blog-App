import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'blog_detail_page.dart';
import 'blog_form_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<BlogModel> _mine = [];
  final Map<int, String> _catName = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isMine(BlogModel b) {
    final u = AuthService.currentUser;
    if (u == null) return false;
    return b.authorName.toLowerCase() == u.name.toLowerCase() ||
        b.authorName.toLowerCase() == u.username.toLowerCase();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await ApiService.getCategories();
      final blogs = await ApiService.getAllBlogs();
      if (!mounted) return;
      setState(() {
        for (final c in cats) {
          _catName[c.id] = c.name;
        }
        _mine = blogs.where(_isMine).toList();
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
        content: const Text('Token sesi akan dihapus dari perangkat.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: ThreadsColors.error),
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

  Future<void> _openEdit(BlogModel b) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogFormPage(blogToEdit: b)),
    );
    if (changed == true && mounted) _load();
  }

  Future<void> _confirmDelete(BlogModel b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus artikel?'),
        content: Text('"${b.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: ThreadsColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteBlog(b.id);
      if (mounted) _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                  Text('@${user?.username ?? '-'}',
                      style:
                          TextStyle(color: secondary, fontSize: 13)),
                  if ((user?.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(user!.bio!,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Artikel Saya (${_mine.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (_mine.isEmpty)
              const EmptyState(message: 'Belum ada artikel milikmu.')
            else
              ..._mine.map((b) {
                String label = b.categoryName;
                if (label.isEmpty && b.categoryId != null) {
                  label = _catName[b.categoryId] ?? '';
                }
                return ThreadsBlogItem(
                  blog: b,
                  categoryLabel: label,
                  isMine: true,
                  onTap: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              BlogDetailPage(blogId: b.id)),
                    );
                    if (changed == true && mounted) _load();
                  },
                  onEdit: () => _openEdit(b),
                  onDelete: () => _confirmDelete(b),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
