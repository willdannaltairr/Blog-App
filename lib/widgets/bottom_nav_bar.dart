import 'package:flutter/material.dart';
import 'common.dart';

// Bottom navigation pill melayang, dibuat manual (tanpa package UI).
// Susunan: Home - Artikel - [+] - Kategori - Profil.
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
            // Tombol tengah menonjol.
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
