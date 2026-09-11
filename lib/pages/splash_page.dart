import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'login_page.dart';
import 'main_nav_page.dart';

// Splash: hanya logo di tengah, background mengikuti tema.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await AuthService.init();
    await Future.delayed(
        const Duration(milliseconds: AppConstants.splashDelayMs));
    if (!mounted) return;
    final next = AuthService.isLoggedIn
        ? const MainNavPage()
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
      body: Center(
        child: Image.asset(
          AppConstants.logoPath,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, size: 64),
        ),
      ),
    );
  }
}
