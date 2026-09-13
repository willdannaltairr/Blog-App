import 'dart:io' show File;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'theme.dart';
export 'theme.dart';

class AuthShell extends StatelessWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double headerHeight = (height * AppConstants.authHeaderRatio)
        .clamp(AppConstants.authHeaderMin, AppConstants.authHeaderMax)
        .toDouble();

    double logoTop =
        ((headerHeight - AppConstants.authCardOverlap - AppConstants.authLogoSize) / 2)
            .clamp(8.0, 140.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: AuthBackground(height: headerHeight),
            ),
            Positioned(
              top: logoTop,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  AppConstants.logoPath,
                  width: AppConstants.authLogoSize,
                  height: AppConstants.authLogoSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: headerHeight - AppConstants.authCardOverlap,
              left: 0,
              right: 0,
              bottom: 0,
              child: AuthCard(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  final double height;

  const AuthBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuthPatternPainter(height),
      child: Container(color: AppColors.background),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.authCardRadius),
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class AuthTitle extends StatelessWidget {
  final String text;
  const AuthTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.accentFg,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.accent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class AuthSwitchRow extends StatelessWidget {
  final String prefix;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchRow({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.accentFg,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthPatternPainter extends CustomPainter {
  final double height;

  _AuthPatternPainter(this.height);

  @override
  void paint(Canvas canvas, Size size) {
    var bg = Paint()..color = AppColors.background;
    var grey1 = Paint()..color = AppColors.pattern;
    var grey2 = Paint()..color = AppColors.patternAlt;
    var line = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Offset.zero & size, bg);
    canvas.drawCircle(Offset(size.width * 0.12, -32), 96, grey1);
    canvas.drawCircle(Offset(size.width * 0.82, 4), 112, grey2);
    canvas.drawCircle(Offset(size.width * 0.58, height * 0.78), 72, grey1);
    canvas.drawCircle(Offset(size.width * 0.08, height * 0.72), 58, grey2);
    canvas.drawCircle(Offset(size.width * 0.92, height * 0.62), 48, grey1);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset(size.width * 0.68, height * 0.12) & const Size(72, 72),
        const Radius.circular(18),
      ),
      grey2,
    );

    canvas.save();
    canvas.translate(size.width * 0.28, height * 0.42);
    canvas.rotate(0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Offset(-30, -30) & const Size(60, 60),
        const Radius.circular(14),
      ),
      grey1,
    );
    canvas.restore();

    canvas.drawCircle(Offset(size.width * 0.42, height * 0.2), 24, line);
    canvas.drawCircle(Offset(size.width * 0.76, height * 0.48), 18, line);
    canvas.drawCircle(Offset(size.width * 0.18, height * 0.5), 14, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final bool obscure;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool light;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffix,
    this.validator,
    this.onChanged,
    this.light = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = light ? AppColors.accentFg : AppColors.textPrimary;
    Color borderColor =
        light ? AppColors.inputFillLight : AppColors.surfaceBorder;
    Color focusColor = light ? AppColors.accentFg : AppColors.accent;
    Color errorColor = light ? AppColors.background : AppColors.danger;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            filled: true,
            fillColor: light ? AppColors.inputFillLight : AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            errorStyle: TextStyle(color: errorColor, fontSize: 12),
            border: border(borderColor),
            enabledBorder: border(borderColor),
            focusedBorder: border(focusColor, 1.2),
            errorBorder: border(errorColor),
            focusedErrorBorder: border(errorColor, 1.2),
          ),
        ),
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;

  const EmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class FormErrorBanner extends StatelessWidget {
  final String message;
  final bool light;

  const FormErrorBanner({super.key, required this.message, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: light ? AppColors.inputFillLight : AppColors.surface,
        border: Border.all(
          color: light ? AppColors.background : AppColors.danger,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: light ? AppColors.background : AppColors.danger,
          fontSize: 13,
        ),
      ),
    );
  }
}

bool isNetworkUrl(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

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
    if (isNetworkUrl(u)) {
      img = CachedNetworkImage(
        imageUrl: u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (c, s) => Container(
          height: height,
          width: double.infinity,
          color: AppColors.placeholder,
        ),
        errorWidget: (c, s, e) => fallback(),
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
      img = Image.network(
        u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
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
          const Divider(height: 1),
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
