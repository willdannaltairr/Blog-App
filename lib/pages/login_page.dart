import 'package:flutter/material.dart';

import '../services/api.dart';
import '../widgets/widgets.dart';
import 'main_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sembunyi = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.login(_email.text, _password.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const AuthTitle('Login'),
              const SizedBox(height: 28),
              if (_error != null) ...[
                FormErrorBanner(message: _error!, light: true),
                const SizedBox(height: 16),
              ],
              AppTextField(
                light: true,
                controller: _email,
                label: 'Email',
                hint: 'youremail@gmail.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 14),
              AppTextField(
                light: true,
                controller: _password,
                label: 'Password',
                hint: 'Enter your password',
                obscure: _sembunyi,
                validator: validatePassword,
                suffix: IconButton(
                  icon: Icon(
                    _sembunyi
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.accentFg,
                  ),
                  onPressed: () {
                    setState(() => _sembunyi = !_sembunyi);
                  },
                ),
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: 'Login',
                loading: _loading,
                onPressed: _login,
              ),
              const SizedBox(height: 22),
              AuthSwitchRow(
                prefix: "Don't have any account? ",
                action: 'Sign Up',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
