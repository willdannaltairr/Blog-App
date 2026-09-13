import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api.dart';
import '../widgets/widgets.dart';

class ArtikelFormPage extends StatefulWidget {
  final PostModel? postToEdit;
  const ArtikelFormPage({super.key, this.postToEdit});

  @override
  State<ArtikelFormPage> createState() => _ArtikelFormPageState();
}

class _ArtikelFormPageState extends State<ArtikelFormPage> {
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
    final PostModel? b = widget.postToEdit;
    _title = TextEditingController(text: b?.title ?? '');
    _content = TextEditingController(text: b?.content ?? '');
    _imageUrl = TextEditingController(text: b?.imageUrl ?? '');
    final u = AuthService.currentUser;
    String profileName = u?.name.trim() ?? '';
    if (profileName.isEmpty) profileName = u?.username.trim() ?? '';
    _author = TextEditingController(text: b?.authorName ?? profileName);
    _selected.addAll(b?.allCategoryIds ?? const []);
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
        // Pertahankan pilihan user; buang yang sudah tidak tersedia.
        final available = cats.map((c) => c.id).toSet();
        _selected.retainAll(available);
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

  Future<void> _addCategoryInline() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (name == null || !mounted) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    for (final c in _cats) {
      if (c.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        setState(() => _selected.add(c.id));
        return;
      }
    }
    try {
      final created = await ApiService.createCategory(trimmed);
      if (!mounted) return;
      setState(() {
        _cats = [..._cats, created];
        _selected.add(created.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori "$trimmed" ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      if (!mounted) return;
      setState(() => _imageUrl.text = file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
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
      final bool isEdit = widget.postToEdit != null;
      final String rawImg = _imageUrl.text.trim();
      if (rawImg.length > 255) {
        setState(() {
          _saving = false;
          _error =
              'Gambar terlalu panjang (maks 255 karakter). Pakai URL yang lebih pendek.';
        });
        return;
      }
      final String? image = rawImg.isEmpty ? null : rawImg;
      final List<int> ids = _selected.toList();
      String profileName = user.name.trim();
      if (profileName.isEmpty) profileName = user.username.trim();
      String author = _author.text.trim();
      if (author.isEmpty) author = profileName;
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
          author: author,
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
              Row(
                children: [
                  const Expanded(
                    child: Text('Kategori (bisa pilih banyak)',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  GestureDetector(
                    onTap: _addCategoryInline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              size: 16, color: AppColors.accentFg),
                          SizedBox(width: 2),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              color: AppColors.accentFg,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                hint: 'https://... atau pilih dari galeri',
                onChanged: (_) => setState(() {}),
                suffix: IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Pilih dari galeri',
                  onPressed: _pickImage,
                ),
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

class PostImagePreview extends StatelessWidget {
  final String url;
  const PostImagePreview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return PostImage(url: url, height: 180, radius: 18);
  }
}
