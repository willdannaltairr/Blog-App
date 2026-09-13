import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'services/auth_service.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const BLogApp());
}

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
