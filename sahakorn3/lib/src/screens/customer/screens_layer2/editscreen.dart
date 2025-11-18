import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // To display non-editable email

  final _currentUser = FirebaseAuth.instance.currentUser;
  late DocumentReference _userDocRef;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final docSnapshot = await _userDocRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _surnameController.text = data['surname'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = _currentUser!.email ?? 'No email';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _userDocRef.update({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Error: No user is logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture Section
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              onPressed: () {
                                // TODO: Implement image picker logic
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: 'Surname'),
                      validator: (value) => value!.isEmpty ? 'Please enter your surname' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true, // Make email non-editable
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}