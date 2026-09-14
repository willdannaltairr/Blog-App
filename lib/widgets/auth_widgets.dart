import 'package:flutter/material.dart';
import 'theme.dart';

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
    return Container(color: AppColors.background);
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
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.background,
          disabledForegroundColor: AppColors.accent,
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
                  strokeWidth: 2.5,
                  color: AppColors.accent,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
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
