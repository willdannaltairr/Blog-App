import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _name = TextEditingController(text: u?.name ?? '');
    _username = TextEditingController(text: u?.username ?? '');
    _email = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.updateProfile(
        name: _name.text,
        username: _username.text,
        email: _email.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading:
            const BackButton(color: AppColors.textPrimary),
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _name,
                label: 'Nama',
                hint: 'Nama lengkap',
                validator: (v) => validateRequired(v, 'Nama'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _username,
                label: 'Username',
                hint: 'tanpaspasi',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Username wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Username minimal 3 karakter';
                  }
                  if (v.contains(' ')) return 'Username tanpa spasi';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _email,
                label: 'Email',
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentFg))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
