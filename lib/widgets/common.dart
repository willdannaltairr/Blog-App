import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pindahan dari utils/colors.dart — satu-satunya sumber warna.
class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color pattern = Color(0xFF101010);
  static const Color patternAlt = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceBorder = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color accent = Color(0xFFFFFFFF);
  static const Color accentFg = Color(0xFF000000);
  static const Color danger = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFF121212);
  static const Color inputFillLight = Color(0xFFF5F5F5);
  static const Color placeholder = Color(0xFF2A2A2A);
}

// Pindahan dari utils/constants.dart.
class AppConstants {
  static const String appName = 'Log';
  static const String logoPath = 'assets/images/logo.png';
  static const double cardRadius = 20;
  static const double inputRadius = 12;
  static const double buttonRadius = 12;
  static const double navRadius = 22;
  static const int splashDelayMs = 1800;
  static const int searchDebounceMs = 400;
}

// Pindahan dari utils/validators.dart.
String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
  final t = v.trim();
  if (!t.contains('@') || !t.contains('.')) return 'Format email tidak valid';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password wajib diisi';
  if (v.length < 6) return 'Password minimal 6 karakter';
  return null;
}

String? validateRequired(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label wajib diisi';
  return null;
}

String timeAgo(String? isoString) {
  if (isoString == null || isoString.isEmpty) return 'baru saja';
  try {
    final dt = DateTime.parse(isoString).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return 'baru saja';
  }
}

// Pindahan dari utils/theme.dart.
class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.textPrimary,
        secondary: AppColors.textSecondary,
        surface: AppColors.surface,
        onPrimary: AppColors.accentFg,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      dividerColor: AppColors.surfaceBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
    );

    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary, height: 1.5),
      bodySmall: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
    );

    return base.copyWith(
      textTheme: text,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.accentFg,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

class AuthShell extends StatelessWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final headerHeight = (height * 0.31).clamp(150.0, 230.0).toDouble();
    const logoSize = 112.0;
    // Ruang hitam di atas kartu putih; logo diratakan tengah di ruang itu.
    final logoTop = ((headerHeight - 24 - logoSize) / 2).clamp(8.0, 120.0);

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
                // Logo tanpa kotak: gambarnya hitam-putih sehingga
                // menyatu dengan background hitam.
                child: Image.asset(
                  AppConstants.logoPath,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: headerHeight - 24,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(child: child),
    );
  }
}

class _AuthPatternPainter extends CustomPainter {
  final double height;

  const _AuthPatternPainter(this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.background;
    final pattern = Paint()..color = AppColors.pattern;
    final patternAlt = Paint()..color = AppColors.patternAlt;
    final edge = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Offset.zero & size, background);
    canvas.drawCircle(Offset(size.width * 0.12, -32), 96, pattern);
    canvas.drawCircle(Offset(size.width * 0.82, 4), 112, patternAlt);
    canvas.drawCircle(Offset(size.width * 0.58, height * 0.78), 72, pattern);
    canvas.drawCircle(Offset(size.width * 0.08, height * 0.72), 58, patternAlt);
    canvas.drawCircle(Offset(size.width * 0.92, height * 0.62), 48, pattern);

    final first = RRect.fromRectAndRadius(
      Offset(size.width * 0.68, height * 0.12) & const Size(72, 72),
      const Radius.circular(18),
    );
    canvas.drawRRect(first, patternAlt);

    canvas.save();
    canvas.translate(size.width * 0.28, height * 0.42);
    canvas.rotate(0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Offset(-30, -30) & const Size(60, 60),
        const Radius.circular(14),
      ),
      pattern,
    );
    canvas.restore();

    canvas.drawCircle(Offset(size.width * 0.42, height * 0.2), 24, edge);
    canvas.drawCircle(Offset(size.width * 0.76, height * 0.48), 18, edge);
    canvas.drawCircle(Offset(size.width * 0.18, height * 0.5), 14, edge);
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
    final textColor = light ? AppColors.accentFg : AppColors.textPrimary;
    final borderColor = light
        ? AppColors.inputFillLight
        : AppColors.surfaceBorder;
    final focusedColor = light ? AppColors.accentFg : AppColors.accent;
    final errorColor = light ? AppColors.background : AppColors.danger;

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
            // Teks validasi: hitam di kartu putih agar selalu terbaca.
            errorStyle: TextStyle(color: errorColor, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(color: focusedColor, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(color: errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(color: errorColor, width: 1.2),
            ),
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
