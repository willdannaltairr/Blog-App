import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_shared.dart';

// Form tambah/edit: judul, konten multiline, dropdown kategori,
// gambar opsional via URL atau image_picker.
class BlogFormPage extends StatefulWidget {
  final BlogModel? blogToEdit;
  const BlogFormPage({super.key, this.blogToEdit});

  @override
  State<BlogFormPage> createState() => _BlogFormPageState();
}

class _BlogFormPageState extends State<BlogFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _imageUrl;
  List<CategoryModel> _cats = [];
  int? _categoryId;
  XFile? _picked;
  Uint8List? _pickedBytes;
  bool _loadingCats = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final b = widget.blogToEdit;
    _title = TextEditingController(text: b?.title ?? '');
    _content = TextEditingController(text: b?.content ?? '');
    _imageUrl = TextEditingController(text: b?.imageUrl ?? '');
    _categoryId = b?.categoryId;
    _loadCats();
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _loadCats() async {
    try {
      final cats = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _cats = cats;
        if (_categoryId == null && cats.isNotEmpty) {
          _categoryId = cats.first.id;
        }
        // Pastikan id lama masih valid.
        if (_categoryId != null &&
            cats.every((c) => c.id != _categoryId)) {
          _categoryId = cats.isEmpty ? null : cats.first.id;
        }
        _loadingCats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final img =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;
      // Baca bytes agar preview jalan di semua platform (termasuk Web).
      // Path tetap disimpan ke field untuk dikirim ke backend.
      final bytes = await img.readAsBytes();
      if (!mounted) return;
      setState(() {
        _picked = img;
        _pickedBytes = bytes;
        _imageUrl.text = kIsWeb ? '' : img.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Widget _preview(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    if (_pickedBytes != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(AppConstants.imageRadius),
        child: Image.memory(_pickedBytes!,
            height: 180, width: double.infinity, fit: BoxFit.cover),
      );
    }
    final url = _imageUrl.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(AppConstants.imageRadius),
        child: CachedNetworkImage(
          imageUrl: url,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (c, u, e) => Container(
            height: 100,
            alignment: Alignment.center,
            child: Text('Gambar tidak dapat dimuat',
                style: TextStyle(color: secondary, fontSize: 12)),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      setState(() => _error = 'Pilih kategori terlebih dahulu');
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
      final isEdit = widget.blogToEdit != null;
      if (!isEdit) {
        await ApiService.createBlog(
          title: _title.text,
          content: _content.text,
          author: user.name,
          image: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
          categoryId: _categoryId!,
        );
      } else {
        await ApiService.updateBlog(
          id: widget.blogToEdit!.id,
          title: _title.text,
          content: _content.text,
          author: user.name,
          image: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
          categoryId: _categoryId!,
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
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.blogToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Artikel' : 'Artikel Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThreadsColors.error),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: ThreadsColors.error, fontSize: 13)),
                ),
                const SizedBox(height: 12),
              ],
              ThreadsTextField(
                controller: _title,
                label: 'Judul',
                hint: 'Judul artikel',
                validator: (v) => validateRequired(v, 'Judul'),
              ),
              const SizedBox(height: 12),
              ThreadsTextField(
                controller: _content,
                label: 'Konten',
                hint: 'Tulis isi artikel...',
                maxLines: 8,
                validator: (v) => validateRequired(v, 'Konten'),
              ),
              const SizedBox(height: 12),
              Text('Kategori',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _CategoryDropdown(
                loading: _loadingCats,
                categories: _cats,
                value: _categoryId,
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              ThreadsTextField(
                controller: _imageUrl,
                label: 'Gambar (opsional)',
                hint: 'https://... atau hasil picker',
                onChanged: (v) {
                  if (_pickedBytes != null &&
                      v.trim() != (_picked?.path ?? '')) {
                    _picked = null;
                    _pickedBytes = null;
                  }
                  setState(() {});
                },
                suffix: IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: _pickImage,
                  tooltip: 'Pilih dari galeri',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text('Upload gambar'),
              ),
              const SizedBox(height: 8),
              _preview(context),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit ? 'Simpan perubahan' : 'Terbitkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final bool loading;
  final List<CategoryModel> categories;
  final int? value;
  final ValueChanged<int?> onChanged;
  const _CategoryDropdown({
    required this.loading,
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (categories.isEmpty) {
      return const Text(
        'Belum ada kategori. Tambahkan dulu di tab Kategori.',
        style: TextStyle(fontSize: 13),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: value,
      items: categories
          .map((c) =>
              DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
      decoration: const InputDecoration(hintText: 'Pilih kategori'),
    );
  }
}
