import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const BLogApp());
}

// Log: tema hitam-putih (#000000) + auth + bottom nav pill.
class BLogApp extends StatelessWidget {
  const BLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
