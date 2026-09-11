import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'blog_detail_page.dart';
import 'blog_form_page.dart';

// Feed Threads: avatar, nama bold, timestamp abu, preview 3 baris,
// gambar rounded kecil, badge kategori, divider tipis.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  List<BlogModel> _all = [];
  List<BlogModel> _shown = [];
  final Map<int, String> _catName = {};
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
              _scroll.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _hasMore &&
          !_loading) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _catLabel(BlogModel b) {
    if (b.categoryName.isNotEmpty) return b.categoryName;
    if (b.categoryId != null) return _catName[b.categoryId] ?? '';
    return '';
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
      _page = 1;
    });
    try {
      final cats = await ApiService.getCategories();
      final blogs = await ApiService.getAllBlogs();
      if (!mounted) return;
      setState(() {
        _catName.clear();
        for (final c in cats) {
          _catName[c.id] = c.name;
        }
        _all = blogs;
        _shown = blogs.take(AppConstants.feedPageLimit).toList();
        _hasMore = blogs.length > _shown.length;
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

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final nextPage = _page + 1;
    final end = (nextPage * AppConstants.feedPageLimit)
        .clamp(0, _all.length);
    setState(() {
      _page = nextPage;
      _shown = _all.take(end).toList();
      _hasMore = _shown.length < _all.length;
      _loadingMore = false;
    });
  }

  Future<void> _openDetail(BlogModel b) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogDetailPage(blogId: b.id)),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel dihapus')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openEdit(BlogModel b) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogFormPage(blogToEdit: b)),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: ErrorState(message: _error!, onRetry: _load),
      );
    }
    if (_all.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: const EmptyState(message: 'Belum ada artikel.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          controller: _scroll,
          itemCount: _shown.length + (_hasMore ? 1 : 0),
          itemBuilder: (c, i) {
            if (i >= _shown.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))),
              );
            }
            final b = _shown[i];
            return ThreadsBlogItem(
              blog: b,
              categoryLabel: _catLabel(b),
              isMine: _isMine(b),
              onTap: () => _openDetail(b),
              onEdit: () => _openEdit(b),
              onDelete: () => _confirmDelete(b),
            );
          },
        ),
      ),
    );
  }
}
