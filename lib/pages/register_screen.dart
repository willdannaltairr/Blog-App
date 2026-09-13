import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sembunyi = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.register(
        name: _nama.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Selamat datang!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
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
              const AuthTitle('Register'),
              const SizedBox(height: 24),
              if (_error != null) ...[
                FormErrorBanner(message: _error!, light: true),
                const SizedBox(height: 14),
              ],
              AppTextField(
                light: true,
                controller: _nama,
                label: 'Name',
                hint: 'Your name',
                validator: (value) => validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                light: true,
                controller: _email,
                label: 'Email',
                hint: 'youremail@gmail.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              AppTextField(
                light: true,
                controller: _password,
                label: 'Password',
                hint: 'Minimum 6 characters',
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
                label: 'Register',
                loading: _loading,
                onPressed: _daftar,
              ),
              const SizedBox(height: 20),
              AuthSwitchRow(
                prefix: 'Already have an account? ',
                action: 'Login',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
