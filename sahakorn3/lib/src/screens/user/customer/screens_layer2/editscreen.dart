import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahakorn3/src/services/firebase/user/user_repository.dart';
import 'package:sahakorn3/src/models/user.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  /// If [uid] is not provided, current FirebaseAuth user uid will be used.
  final String? uid;
  const EditProfileScreen({super.key, this.uid});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = UserRepository();

  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  bool _saving = false;
  AppUser? _user;

  String? get _uid => widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _loading = true);
    final user = await _repo.getById(uid);
    if (!mounted) return;
    setState(() {
      _user = user;
      _nameCtrl.text = user?.name ?? '';
      _surnameCtrl.text = user?.surname ?? '';
      _phoneCtrl.text = user?.phone ?? '';
      _emailCtrl.text = user?.email ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = _uid;
    if (uid == null) {
      AppSnackBar.showError(context, 'No authenticated user');
      return;
    }

    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'surname': _surnameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    };

    final String? err = await _repo.update(uid, data);
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      AppSnackBar.showSuccess(context, 'Profile updated');
      await _loadUser(); // refresh
    } else {
      AppSnackBar.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child:
                _saving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Please enter name'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _surnameCtrl,
                        decoration: const InputDecoration(labelText: 'Surname'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child:
                            _saving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
