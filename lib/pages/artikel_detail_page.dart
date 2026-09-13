import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api.dart';
import '../widgets/widgets.dart';
import 'artikel_form_page.dart';

class ArtikelDetailPage extends StatefulWidget {
  final int postId;
  final PostModel? initial;

  const ArtikelDetailPage({super.key, required this.postId, this.initial});

  @override
  State<ArtikelDetailPage> createState() => _ArtikelDetailPageState();
}

class _ArtikelDetailPageState extends State<ArtikelDetailPage> {
  PostModel? _post;
  final Map<int, String> _catName = {};
  bool _loading = true;
  bool _expanded = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _post = widget.initial;
    if (_post != null) {
      _loading = false;
      _refreshSilently();
    } else {
      _load();
    }
  }

  bool get _isMine {
    final u = AuthService.currentUser;
    final p = _post;
    if (u == null || p == null) return false;
    if (p.authorId != null && p.authorId == u.id) return true;
    return p.authorName.toLowerCase() == u.name.toLowerCase() ||
        p.authorName.toLowerCase() == u.username.toLowerCase();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await ApiService.getCategories();
      final p = await ApiService.getPostById(widget.postId);
      final names = {for (final c in cats) c.id: c.name};
      if (!mounted) return;
      setState(() {
        _catName
          ..clear()
          ..addAll(names);
        _post = p.withResolvedCategory(names);
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
      final cats = await ApiService.getCategories();
      final names = {for (final c in cats) c.id: c.name};
      final p = await ApiService.getPostById(widget.postId);
      if (!mounted) return;
      setState(() {
        _catName
          ..clear()
          ..addAll(names);
        _post = p.withResolvedCategory(names);
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
            style:
                TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || _post == null) return;
    setState(() => _deleting = true);
    try {
      await ApiService.deletePost(_post!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _openEdit() async {
    if (_post == null) return;
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ArtikelFormPage(postToEdit: _post)),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const SafeArea(child: LoadingView())
          : _error != null
              ? SafeArea(
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: AppColors.background,
                        leading: const BackButton(
                            color: AppColors.textPrimary),
                      ),
                      Expanded(
                          child: ErrorView(
                              message: _error!, onRetry: _load)),
                    ],
                  ),
                )
              : _post == null
                  ? const SafeArea(
                      child:
                          EmptyView(message: 'Artikel tidak ditemukan'))
                  : _content(),
    );
  }

  Widget _content() {
    final p = _post!;
    final needsToggle = p.content.length > 220;
    final text = _expanded || !needsToggle
        ? p.content
        : '${p.content.substring(0, 220)}...';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          leading:
              const BackButton(color: AppColors.textPrimary),
          actions: [
            if (_isMine) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
                onPressed: _openEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger),
                onPressed: _deleting ? null : _confirmDelete,
                tooltip: 'Hapus',
              ),
            ],
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostImage(url: p.imageUrl, height: 240, radius: 20),
                const SizedBox(height: 16),
                if (p.displayCategoryNames(_catName).isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final n
                          in p.displayCategoryNames(_catName))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent
                                .withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.accent
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            n,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                Text(
                  p.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Oleh ${p.authorName} · ${timeAgo(p.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
                if (needsToggle)
                  TextButton(
                    onPressed: () =>
                        setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.only(top: 8),
                    ),
                    child: Text(_expanded
                        ? 'Tutup'
                        : 'Baca Selengkapnya'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
