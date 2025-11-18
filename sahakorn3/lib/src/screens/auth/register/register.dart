import 'package:flutter/material.dart';
import 'package:sahakorn3/src/screens/auth/login/login.dart';
import 'package:sahakorn3/src/services/firebase/auth/fire_register.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _surnameCtrl = TextEditingController();
  final TextEditingController _phonenumCtrl = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  final FirebaseRegisterService _registerService = FirebaseRegisterService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final String? errorMessage = await _registerService.registerUser(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        phone: _phonenumCtrl.text.trim(),
      );

      if (!mounted) return;

      if (errorMessage == null) {
        // success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        // service returned an error message
        debugPrint('Register error: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      // unexpected exception
      debugPrint('Unexpected register exception: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFb8c1ec),
      appBar: AppBar(
        title: const Text('Sign up',style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 20)),
        backgroundColor: const Color(0xFF232946),
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                surfaceTintColor: Color(0xFFfffffe),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Color(0xFF121629), width: 2),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text('Create an account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Sign up to get started with SahaKorn', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameCtrl,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Surname',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter surname';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phonenumCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter phone number';
                            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(v)) return 'Enter a valid phone number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: _hideConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hideConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm your password';
                            if (v != _passCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFabd1c6),
                              side: BorderSide(color: Color(0xFF121629), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFFF9bc60), strokeWidth: 2))
                                : const Text('Sign up'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?'),
                            TextButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              )); 
                            }, child: const Text('Sign in')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
