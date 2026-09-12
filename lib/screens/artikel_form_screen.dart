import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/validators.dart';
import '../widgets/category_chip.dart';
import '../widgets/common.dart';

// Tambah & edit artikel: judul, konten, pilih banyak kategori,
// gambar opsional.
class ArtikelFormScreen extends StatefulWidget {
  final PostModel? postToEdit;
  const ArtikelFormScreen({super.key, this.postToEdit});

  @override
  State<ArtikelFormScreen> createState() => _ArtikelFormScreenState();
}

class _ArtikelFormScreenState extends State<ArtikelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _imageUrl;
  late final TextEditingController _author;
  List<CategoryModel> _cats = [];
  final Set<int> _selected = {};
  bool _loadingCats = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final b = widget.postToEdit;
    _title = TextEditingController(text: b?.title ?? '');
    _content = TextEditingController(text: b?.content ?? '');
    _imageUrl = TextEditingController(text: b?.imageUrl ?? '');
    // Author menyesuaikan profil yang sedang login (buat baru) /
    // pakai author lama saat edit.
    final u = AuthService.currentUser;
    final profileName = (u?.name.trim().isNotEmpty == true
            ? u!.name.trim()
            : u?.username.trim() ?? '')
        .trim();
    _author = TextEditingController(
      text: b?.authorName ?? profileName,
    );
    _loadCats();
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _imageUrl.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _loadCats() async {
    try {
      final cats = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _cats = cats;
        // Saat edit: tandai kategori lama yang masih tersedia.
        final old = widget.postToEdit?.allCategoryIds ?? const [];
        final available = cats.map((c) => c.id).toSet();
        _selected
          ..clear()
          ..addAll(old.where(available.contains));
        _loadingCats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selected.isEmpty) {
      setState(() => _error = 'Pilih minimal 1 kategori');
      return;
    }
    final user = AuthService.currentUser;
    if (user == null) {
      setState(() => _error = 'Sesi berakhir. Login ulang.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final isEdit = widget.postToEdit != null;
      final image = _imageUrl.text.trim().isEmpty
          ? null
          : _imageUrl.text.trim();
      final ids = _selected.toList();
      // Buat baru: author selalu menyesuaikan profil yang login.
      final profileName = (user.name.trim().isNotEmpty
              ? user.name.trim()
              : user.username.trim())
          .trim();
      final author = isEdit
          ? _author.text.trim().isEmpty
              ? profileName
              : _author.text.trim()
          : (_author.text.trim().isEmpty ? profileName : _author.text.trim());
      if (!isEdit) {
        await ApiService.createPost(
          title: _title.text,
          content: _content.text,
          author: author,
          image: image,
          categoryIds: ids,
        );
      } else {
        await ApiService.updatePost(
          id: widget.postToEdit!.id,
          title: _title.text,
          content: _content.text,
          author: _author.text,
          image: image,
          categoryIds: ids,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEdit
                ? 'Artikel diperbarui'
                : 'Artikel ditambahkan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(
          () => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.postToEdit != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading:
            const BackButton(color: AppColors.textPrimary),
        title: Text(isEdit ? 'Edit Artikel' : 'Artikel Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                FormErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: _title,
                label: 'Judul',
                hint: 'Judul artikel',
                validator: (v) => validateRequired(v, 'Judul'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _content,
                label: 'Konten',
                hint: 'Tulis isi artikel...',
                maxLines: 8,
                validator: (v) => validateRequired(v, 'Konten'),
              ),
              const SizedBox(height: 12),
              const Text('Kategori (bisa pilih banyak)',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const SizedBox(height: 6),
              _CategoryMultiSelect(
                loading: _loadingCats,
                categories: _cats,
                selected: _selected,
                onToggle: _toggle,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _author,
                label: 'Penulis',
                hint: 'Otomatis dari profil login',
                readOnly: !isEdit,
                validator: (v) => validateRequired(v, 'Penulis'),
              ),
              if (!isEdit)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Penulis otomatis menyesuaikan profil yang sedang login.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _imageUrl,
                label: 'Gambar (opsional)',
                hint: 'https://...',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              if (_imageUrl.text.trim().isNotEmpty)
                PostImagePreview(url: _imageUrl.text.trim()),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentFg))
                    : Text(isEdit ? 'Simpan perubahan' : 'Terbitkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pilihan kategori berupa tombol/chip yang bisa dipilih banyak.
class _CategoryMultiSelect extends StatelessWidget {
  final bool loading;
  final List<CategoryModel> categories;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  const _CategoryMultiSelect({
    required this.loading,
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accent),
        ),
      );
    }
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Text(
          'Belum ada kategori. Tambahkan dulu di tab Kategori.',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in categories)
          CategoryChip(
            label: c.name,
            active: selected.contains(c.id),
            onTap: () => onToggle(c.id),
          ),
      ],
    );
  }
}

// Preview kecil: network pakai Image.network, file lokal pakai teks path.
class PostImagePreview extends StatelessWidget {
  final String url;
  const PostImagePreview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final isNet =
        url.startsWith('http://') || url.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: isNet
          ? Image.network(
              url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 80,
                alignment: Alignment.center,
                color: AppColors.surface,
                child: const Text('Gambar tidak dapat dimuat',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
              ),
            )
          : Container(
              height: 60,
              alignment: Alignment.center,
              color: AppColors.surface,
              child: Text(
                'Gambar lokal dipilih',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
    );
  }
}
