import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class AppConstants {
  static const String appName = 'Log';
  static const String logoPath = 'assets/images/logo.png';
  static const double cardRadius = 20;
  static const double inputRadius = 12;
  static const double buttonRadius = 12;
  static const double navRadius = 22;
  static const int splashDelayMs = 1800;
  static const int searchDebounceMs = 400;

  static const double authHeaderRatio = 0.38;
  static const double authHeaderMin = 190;
  static const double authHeaderMax = 270;
  static const double authCardRadius = 36;
  static const double authCardOverlap = 28;
  static const double authLogoSize = 112;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
  String email = value.trim();
  if (!email.contains('@') || !email.contains('.')) {
    return 'Format email tidak valid';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password wajib diisi';
  if (value.length < 6) return 'Password minimal 6 karakter';
  return null;
}

String? validateRequired(String? value, String label) {
  if (value == null || value.trim().isEmpty) return '$label wajib diisi';
  return null;
}

String timeAgo(String? iso) {
  if (iso == null || iso.isEmpty) return 'baru saja';
  try {
    DateTime date = DateTime.parse(iso).toLocal();
    Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    return 'baru saja';
  }
}

class AppTheme {
  static ThemeData get dark {
    ThemeData base = ThemeData(
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

    var text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
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
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
