import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/blog_service.dart';
import '../widgets/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/post_widgets.dart';
import 'artikel_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<CategoryModel> _cats = [];
  Map<int, int> _counts = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await BlogService.getCategories();
      final posts = await BlogService.getPosts();
      final counts = <int, int>{};
      for (final p in posts) {
        for (final id in p.allCategoryIds) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
      }
      if (!mounted) return;
      setState(() {
        _cats = cats;
        _counts = counts;
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

  Future<void> _showAdd() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (name == null || !mounted) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    bool sudahAda = _cats.any(
        (c) => c.name.trim().toLowerCase() == trimmed.toLowerCase());
    if (sudahAda) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori "$trimmed" sudah ada')),
      );
      return;
    }
    try {
      await BlogService.createCategory(trimmed);
      if (mounted) _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const LoadingView()
        : _error != null
            ? ErrorView(message: _error!, onRetry: _load)
            : _cats.isEmpty
                ? const EmptyView(message: 'Belum ada kategori.')
                : RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _load,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 120),
                      itemCount: _cats.length,
                      separatorBuilder: (c, i) =>
                          const SizedBox(height: 12),
                      itemBuilder: (c, i) {
                        final cat = _cats[i];
                        final jumlah = _counts[cat.id] ?? 0;
                        String huruf = '?';
                        if (cat.name.trim().isNotEmpty) {
                          huruf = cat.name.trim()[0].toUpperCase();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryArticlesPage(
                                  category: cat,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    huruf,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '$jumlah artikel',
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
                        );
                      },
                    ),
                  );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.accent, size: 30),
                    onPressed: () => _showAdd(),
                    tooltip: 'Tambah kategori',
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class CategoryArticlesPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryArticlesPage({super.key, required this.category});

  @override
  State<CategoryArticlesPage> createState() =>
      _CategoryArticlesPageState();
}

class _CategoryArticlesPageState
    extends State<CategoryArticlesPage> {
  List<PostModel> _posts = [];
  final Map<int, String> _catName = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
        _posts = posts
            .map((p) => p.withResolvedCategory(names))
            .where((p) => p.hasCategory(widget.category.id))
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

  Future<void> _openDetail(PostModel p) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ArtikelDetailPage(postId: p.id)),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading:
            const BackButton(color: AppColors.textPrimary),
        title: Text(widget.category.name),
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingView()
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : _posts.isEmpty
                    ? const EmptyView(
                        message:
                            'Belum ada artikel di kategori ini.')
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              16, 12, 16, 24),
                          itemCount: _posts.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (c, i) {
                            final p = _posts[i];
                            return PostFeedCard(
                              post: p,
                              categoryNames: _catName,
                              onTap: () => _openDetail(p),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
