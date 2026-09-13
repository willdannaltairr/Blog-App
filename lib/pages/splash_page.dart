import 'package:flutter/material.dart';

import '../services/api.dart';
import '../widgets/widgets.dart';
import 'login_page.dart';
import 'main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
        : const LoginPage();
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
