import 'package:flutter/material.dart';
import 'app_shared.dart';
import 'main_nav_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ApiService.register(
        name: _username.text,
        email: _email.text,
        password: _password.text,
        username: _username.text,
      );
      await AuthService.saveUser(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavPage()),
        (r) => false,
      );
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(AppConstants.logoPath,
                      width: 72, height: 72, fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.article_outlined, size: 48)),
                  const SizedBox(height: 24),
                  Text('Daftar',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('Buat akun baru',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThreadsColors.error),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: ThreadsColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ThreadsTextField(
                    controller: _username,
                    hint: 'Username',
                    validator: validateUsername,
                  ),
                  const SizedBox(height: 12),
                  ThreadsTextField(
                    controller: _email,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 12),
                  ThreadsTextField(
                    controller: _password,
                    hint: 'Password',
                    obscure: _obscure,
                    validator: validatePassword,
                    suffix: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Daftar'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ',
                          style: Theme.of(context).textTheme.bodySmall),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Masuk',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
