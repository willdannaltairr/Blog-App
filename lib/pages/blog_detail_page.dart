import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'blog_form_page.dart';

// Detail: konten lengkap, gambar full-width Hero, info penulis & kategori.
class BlogDetailPage extends StatefulWidget {
  final int blogId;
  final BlogModel? initial;
  final BlogModel? blog;
  // `blog` adalah alias lama agar pemanggil BlogDetailPage(blog: ...) tetap jalan.
  BlogDetailPage(
      {super.key, int? blogId, this.initial, this.blog})
      : assert(blogId != null || blog != null || initial != null,
            'blogId atau blog wajib diisi'),
        blogId = blogId ?? blog?.id ?? initial!.id;

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  BlogModel? _blog;
  String _catLabel = '';
  bool _loading = true;
  String? _error;
  bool _deleting = false;

  BlogModel? get _initial => widget.initial ?? widget.blog;

  @override
  void initState() {
    super.initState();
    _blog = _initial;
    if (_blog != null) {
      _catLabel = _blog!.categoryName;
      _loading = false;
      _refreshSilently();
    } else {
      _load();
    }
  }

  bool get _isMine {
    final u = AuthService.currentUser;
    final b = _blog;
    if (u == null || b == null) return false;
    return b.authorName.toLowerCase() == u.name.toLowerCase() ||
        b.authorName.toLowerCase() == u.username.toLowerCase();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final b = await ApiService.getBlogById(widget.blogId);
      String label = b.categoryName;
      if (label.isEmpty && b.categoryId != null) {
        try {
          final cats = await ApiService.getCategories();
          label = cats
              .firstWhere((c) => c.id == b.categoryId,
                  orElse: () => CategoryModel(id: 0, name: ''))
              .name;
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _blog = b;
        _catLabel = label;
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

  Future<void> _refreshSilently() async {
    try {
      final b = await ApiService.getBlogById(widget.blogId);
      if (!mounted) return;
      setState(() {
        _blog = b;
        if (b.categoryName.isNotEmpty) _catLabel = b.categoryName;
      });
    } catch (_) {}
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus artikel?'),
        content: const Text('Artikel akan dihapus permanen.'),
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
    if (ok != true || _blog == null) return;
    setState(() => _deleting = true);
    try {
      await ApiService.deleteBlog(_blog!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _openEdit() async {
    if (_blog == null) return;
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => BlogFormPage(blogToEdit: _blog)),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isMine) ...[
            IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _openEdit,
                tooltip: 'Edit'),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: ThreadsColors.error,
              onPressed: _deleting ? null : _confirmDelete,
              tooltip: 'Hapus',
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _blog == null
                  ? const EmptyState(message: 'Artikel tidak ditemukan')
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(_blog!.authorName,
                                        style: TextStyle(
                                            color: theme
                                                .colorScheme.onSurface,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14)),
                                    Text(timeAgo(_blog!.createdAt),
                                        style: TextStyle(
                                            color: secondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (_catLabel.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(_catLabel,
                                      style: TextStyle(
                                          color: secondary, fontSize: 11)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(_blog!.title,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.3)),
                          const SizedBox(height: 12),
                          if ((_blog!.imageUrl ?? '').isNotEmpty)
                            Hero(
                              tag: 'blog-image-${_blog!.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.imageRadius),
                                child: blogImageView(
                                  _blog!.imageUrl!,
                                  placeholderHeight: 160,
                                  placeholderColor: theme.dividerColor
                                      .withValues(alpha: 0.4),
                                  iconColor: secondary,
                                ),
                              ),
                            ),
                          if ((_blog!.imageUrl ?? '').isNotEmpty)
                            const SizedBox(height: 12),
                          Text(_blog!.content,
                              style: TextStyle(
                                  color:
                                      theme.colorScheme.onSurface,
                                  fontSize: 15,
                                  height: 1.6)),
                        ],
                      ),
                    ),
    );
  }
}
