import 'dart:async';
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/blog_service.dart';
import '../widgets/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/post_widgets.dart';
import 'artikel_detail_page.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<CategoryModel> _cats = [];
  List<PostModel> _result = [];
  final Map<int, String> _catName = {};
  int? _selectedCat;
  bool _loading = true;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    if (_loading == false) setState(() => _searching = true);
    try {
      final cats = await BlogService.getCategories();
      final posts =
          await BlogService.getPosts(search: _search.text);
      if (!mounted) return;
      final names = {for (final c in cats) c.id: c.name};
      setState(() {
        _cats = cats;
        _catName
          ..clear()
          ..addAll(names);
        _result = posts
            .map((p) => p.withResolvedCategory(names))
            .where((p) =>
                _selectedCat == null || p.hasCategory(_selectedCat!))
            .toList();
        _loading = false;
        _searching = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _searching = false;
      });
    }
  }

  void _onChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      _reload,
    );
  }

  void _selectCat(int? id) {
    setState(() => _selectedCat = id);
    _reload();
  }

  Future<void> _openDetail(PostModel p) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ArtikelDetailPage(postId: p.id)),
    );
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Artikel',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AppTextField(
                controller: _search,
                hint: 'Cari judul, isi, atau penulis...',
                onChanged: _onChanged,
                suffix: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent),
                        ),
                      )
                    : const Icon(Icons.search,
                        color: AppColors.textSecondary),
              ),
            ),
            if (_cats.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cats.length + 1,
                  separatorBuilder: (c, i) =>
                      const SizedBox(width: 8),
                  itemBuilder: (c, i) {
                    if (i == 0) {
                      return Center(
                        child: CategoryChip(
                          label: 'Semua',
                          active: _selectedCat == null,
                          onTap: () => _selectCat(null),
                        ),
                      );
                    }
                    final cat = _cats[i - 1];
                    return Center(
                      child: CategoryChip(
                        label: cat.name,
                        active: _selectedCat == cat.id,
                        onTap: () => _selectCat(
                          _selectedCat == cat.id ? null : cat.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorView(
                          message: _error!, onRetry: _reload)
                      : _result.isEmpty
                          ? const EmptyView(
                              message: 'Artikel tidak ditemukan')
                          : RefreshIndicator(
                              color: AppColors.accent,
                              onRefresh: _reload,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 4, 16, 120),
                                itemCount: _result.length,
                                separatorBuilder: (c, i) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (c, i) {
                                  final p = _result[i];
                                  return PostFeedCard(
                                    post: p,
                                    categoryNames: _catName,
                                    onTap: () =>
                                        _openDetail(p),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
