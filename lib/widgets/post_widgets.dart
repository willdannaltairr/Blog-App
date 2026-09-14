import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import 'theme.dart';

class PostImage extends StatelessWidget {
  final String? url;
  final double height;
  final double radius;

  const PostImage(
      {super.key, this.url, this.height = 180, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          height: height,
          width: double.infinity,
          color: AppColors.placeholder,
          child: const Icon(Icons.image_outlined,
              color: AppColors.textSecondary, size: 36),
        );
    final u = (url ?? '').trim();
    if (u.isEmpty) return fallback();

    Widget img;
    if (u.startsWith('http://') || u.startsWith('https://')) {
      img = Image.network(
        u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
    } else if (!kIsWeb) {
      img = Image.file(
        File(u),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
    } else {
      return fallback();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: img,
    );
  }
}

class PostFeedCard extends StatelessWidget {
  final PostModel post;
  final Map<int, String> categoryNames;
  final VoidCallback onTap;

  const PostFeedCard({
    super.key,
    required this.post,
    this.categoryNames = const {},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String author = post.authorName.trim();
    if (author.isEmpty) author = 'Anonymous';
    List<String> names = post.displayCategoryNames(categoryNames);
    String content = post.content.trim();
    String huruf = author.isNotEmpty ? author[0].toUpperCase() : 'A';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.placeholder,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    huruf,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$author · ${timeAgo(post.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (names.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final n in names)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  n,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if ((post.imageUrl ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        PostImage(
                            url: post.imageUrl,
                            height: 200,
                            radius: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

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

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  Widget _item({
    required IconData active,
    required IconData idle,
    required int index,
    required String label,
  }) {
    final selected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? active : idle,
                color:
                    selected ? AppColors.accent : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color:
                      selected ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.navRadius),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _item(
                active: Icons.home,
                idle: Icons.home_outlined,
                index: 0,
                label: 'Home'),
            _item(
                active: Icons.article,
                idle: Icons.article_outlined,
                index: 1,
                label: 'Artikel'),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: AppColors.accentFg, size: 30),
                  ),
                ),
              ),
            ),
            _item(
                active: Icons.grid_view_rounded,
                idle: Icons.grid_view_outlined,
                index: 2,
                label: 'Kategori'),
            _item(
                active: Icons.person,
                idle: Icons.person_outline,
                index: 3,
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
