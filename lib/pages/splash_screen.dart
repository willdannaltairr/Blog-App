import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1);
    });
    _decide();
  }

  Future<void> _decide() async {
    await AuthService.init();
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDelayMs),
    );
    if (!mounted) return;
    final next = AuthService.isLoggedIn
        ? const MainShell()
        : const LoginScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => next,
        transitionsBuilder: (c, a, s, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: Image.asset(
            AppConstants.logoPath,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Text(
              'b',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 100,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
