import 'dart:async';
import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'blog_detail_page.dart';
import 'blog_form_page.dart';

// Search sticky rounded, debounce 400ms, list sama seperti Home.
class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<BlogModel> _result = [];
  final Map<int, String> _catName = {};
  bool _loading = true;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initial();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
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

  Future<void> _initial() async {
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
        _result = blogs;
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

  void _onChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _searchNow(q),
    );
  }

  Future<void> _searchNow(String q) async {
    setState(() => _searching = true);
    try {
      final blogs = await ApiService.getAllBlogs(search: q);
      if (!mounted) return;
      setState(() {
        _result = blogs;
        _searching = false;
      });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _openDetail(BlogModel b) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogDetailPage(blogId: b.id)),
    );
    if (changed == true && mounted) _searchNow(_search.text);
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
      if (mounted) _searchNow(_search.text);
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
    if (changed == true && mounted) _searchNow(_search.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ThreadsTextField(
              controller: _search,
              hint: 'Cari artikel...',
              onChanged: _onChanged,
              suffix: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ErrorState(message: _error!, onRetry: _initial)
                    : _result.isEmpty
                        ? const EmptyState(
                            message: 'Artikel tidak ditemukan')
                        : RefreshIndicator(
                            onRefresh: () =>
                                _searchNow(_search.text),
                            child: ListView.builder(
                              itemCount: _result.length,
                              itemBuilder: (c, i) {
                                final b = _result[i];
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
          ),
        ],
      ),
    );
  }
}
