import 'package:flutter/material.dart';
import 'app_shared.dart';

// Edit profil lokal (backend belum ada PUT /users/me).
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _name = TextEditingController(text: u?.name ?? '');
    _username = TextEditingController(text: u?.username ?? '');
    _bio = TextEditingController(text: u?.bio ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await AuthService.updateLocalProfile(
      name: _name.text,
      username: _username.text,
      bio: _bio.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil diperbarui (lokal)')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreadsTextField(
                controller: _name,
                label: 'Nama',
                hint: 'Nama lengkap',
                validator: (v) => validateRequired(v, 'Nama'),
              ),
              const SizedBox(height: 12),
              ThreadsTextField(
                controller: _username,
                label: 'Username',
                hint: 'tanpaspasi',
                validator: validateUsername,
              ),
              const SizedBox(height: 12),
              ThreadsTextField(
                controller: _bio,
                label: 'Bio',
                hint: 'Ceritakan singkat tentangmu',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
