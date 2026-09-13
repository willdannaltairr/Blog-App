import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';
import 'artikel_detail_screen.dart';

class CategoryArticlesScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryArticlesScreen({super.key, required this.category});

  @override
  State<CategoryArticlesScreen> createState() =>
      _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState
    extends State<CategoryArticlesScreen> {
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
      final cats = await ApiService.getCategories();
      final posts = await ApiService.getPosts();
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
          builder: (_) => ArtikelDetailScreen(postId: p.id)),
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
