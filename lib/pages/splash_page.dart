import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'login_page.dart';
import 'main_shell.dart';

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
      const Duration(milliseconds: AppConstants.splashDelayMs),
    );
    if (!mounted) return;
    Widget next =
        AuthService.isLoggedIn ? const MainShell() : const LoginPage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
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
    );
  }
}
