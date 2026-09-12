import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../widgets/common.dart';
import 'category_articles_screen.dart';

// CRUD kategori dengan kartu gelap + dialog form.
class CategoryScreen extends StatefulWidget {
  final bool inTab;
  const CategoryScreen({super.key, this.inTab = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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
      final cats = await ApiService.getCategories();
      final posts = await ApiService.getPosts();
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

  Future<void> _showForm({CategoryModel? edit}) async {
    final ctrl = TextEditingController(text: edit?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(edit == null ? 'Kategori baru' : 'Edit kategori'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            decoration:
                const InputDecoration(hintText: 'Nama kategori'),
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(c, true);
              }
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(c, true);
              }
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    final name = ctrl.text.trim();
    ctrl.dispose();
    if (ok != true || !mounted) return;
    if (name.isEmpty) return;
    try {
      if (edit == null) {
        await ApiService.createCategory(name);
      } else {
        await ApiService.updateCategory(edit.id, name);
      }
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

  Future<void> _confirmDelete(CategoryModel c) async {
    final used = _counts[c.id] ?? 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Hapus "${c.name}"?'),
        content: Text(used > 0
            ? 'Kategori dipakai $used artikel. Lanjutkan hapus?'
            : 'Kategori akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteCategory(c.id);
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
                        final n = _counts[cat.id] ?? 0;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryArticlesScreen(
                                category: cat,
                              ),
                            ),
                          ),
                          child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(20),
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
                                  cat.name.trim().isEmpty
                                      ? '?'
                                      : cat.name
                                          .trim()[0]
                                          .toUpperCase(),
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
                                    Text(cat.name,
                                        style: const TextStyle(
                                          color: AppColors
                                              .textPrimary,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 15,
                                        )),
                                    Text('$n artikel',
                                        style: const TextStyle(
                                          color: AppColors
                                              .textSecondary,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color:
                                        AppColors.textSecondary),
                                onPressed: () =>
                                    _showForm(edit: cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.danger),
                                onPressed: () =>
                                    _confirmDelete(cat),
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
                    onPressed: () => _showForm(),
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
