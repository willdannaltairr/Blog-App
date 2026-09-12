import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
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
  Map<int, int> _primaryCounts = {};
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
      final primary = <int, int>{};
      for (final p in posts) {
        for (final id in p.allCategoryIds) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
        final first = p.firstCategoryId;
        if (first != null) primary[first] = (primary[first] ?? 0) + 1;
      }
      if (!mounted) return;
      setState(() {
        _cats = cats;
        _counts = counts;
        _primaryCounts = primary;
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
    // Dialog stateful sendiri: controller hidup-mati ikut dialog,
    // tidak dibuang manual dari sini (anti crash framework).
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryFormDialog(initial: edit?.name ?? ''),
    );
    if (name == null || !mounted) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    // Cek duplikat di perangkat dulu biar pesan jelas tanpa ke server.
    final bool duplikat = _cats.any((c) =>
        c.name.trim().toLowerCase() == trimmed.toLowerCase() &&
        c.id != edit?.id);
    if (duplikat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori "$trimmed" sudah ada')),
      );
      return;
    }
    try {
      if (edit == null) {
        await ApiService.createCategory(trimmed);
      } else {
        await ApiService.updateCategory(edit.id, trimmed);
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
    final usedPrimary = _primaryCounts[c.id] ?? 0;
    // Server menolak hapus kategori utama artikel (FK), jadi cegah dari UI.
    // Kategori yang hanya jadi tambahan masih bisa dihapus.
    if (usedPrimary > 0) {
      await showDialog<void>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text('"${c.name}" dipakai $usedPrimary artikel'),
          content: const Text(
              'Ubah dulu kategori artikelnya, baru kategori ini bisa dihapus.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d),
                child: const Text('Mengerti')),
          ],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Hapus "${c.name}"?'),
        content: const Text('Kategori akan dihapus permanen.'),
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

// Dialog tambah/edit kategori. Controller milik dialog sendiri dan dibuang
// di dispose() dialog, jadi aman dari crash framework saat dialog ditutup.
class _CategoryFormDialog extends StatefulWidget {
  final String initial;
  const _CategoryFormDialog({required this.initial});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initial.trim().isNotEmpty;
    return AlertDialog(
      title: Text(isEdit ? 'Edit kategori' : 'Kategori baru'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        TextButton(
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
