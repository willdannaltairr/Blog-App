import 'package:flutter/material.dart';
import 'app_shared.dart';

// CRUD kategori: nama + jumlah artikel (dihitung di klien karena
// backend hanya mengembalikan id/name).
class CategoryCrudPage extends StatefulWidget {
  final bool inTab;
  const CategoryCrudPage({super.key, this.inTab = false});

  @override
  State<CategoryCrudPage> createState() => _CategoryCrudPageState();
}

class _CategoryCrudPageState extends State<CategoryCrudPage> {
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
      final blogs = await ApiService.getAllBlogs();
      final counts = <int, int>{};
      for (final b in blogs) {
        if (b.categoryId != null) {
          counts[b.categoryId!] = (counts[b.categoryId!] ?? 0) + 1;
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(edit == null ? 'Kategori baru' : 'Edit kategori'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
          onSubmitted: (_) => Navigator.pop(c, true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final name = ctrl.text.trim();
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
            style: TextButton.styleFrom(foregroundColor: ThreadsColors.error),
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? ErrorState(message: _error!, onRetry: _load)
            : _cats.isEmpty
                ? const EmptyState(message: 'Belum ada kategori.')
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      itemCount: _cats.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final cat = _cats[i];
                        final n = _counts[cat.id] ?? 0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          title: Text(cat.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          subtitle: Text('$n artikel',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                onPressed: () =>
                                    _showForm(edit: cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: ThreadsColors.error),
                                onPressed: () =>
                                    _confirmDelete(cat),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );

    if (widget.inTab) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kategori'),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showForm(),
                tooltip: 'Tambah'),
          ],
        ),
        body: body,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: body,
    );
  }
}
