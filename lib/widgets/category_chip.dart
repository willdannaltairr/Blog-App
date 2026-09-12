import 'package:flutter/material.dart';
import 'common.dart';

// Chip kategori: aktif = putih, nonaktif = kartu gelap berborder.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              // Buletan di kiri tulisan saat chip terpilih (putih).
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentFg,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.accentFg : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog tambah kategori (hanya tambah, tanpa edit/hapus).
// Controller milik dialog sendiri dan dibuang di dispose() dialog,
// jadi aman dari crash framework saat dialog ditutup.
class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
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
    return AlertDialog(
      title: const Text('Kategori baru'),
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
