import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntermediaryScreen extends StatefulWidget {
  const IntermediaryScreen({super.key});

  @override
  State<IntermediaryScreen> createState() => _IntermediaryScreenState();
}

class _IntermediaryScreenState extends State<IntermediaryScreen> {
  bool _saving = false;

  Future<void> _selectRole(String role) async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intermediary', true);
    await prefs.setString('user_role', role);
    if (!mounted) return;

    // ไปหน้า create ตาม role ที่เลือก
    if (role == 'shop') {
      Navigator.of(context).pushReplacementNamed('/create_shop');
    } else {
      Navigator.of(context).pushReplacementNamed('/create_customer_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text('Choose your role', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Select whether you are using the app as a Shop or as a Customer. You can change this later in settings.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.storefront),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('I am a Shop'),
                ),
                onPressed: _saving ? null : () => _selectRole('shop'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('I am a Customer'),
                ),
                onPressed: _saving ? null : () => _selectRole('customer'),
              ),
              const Spacer(),
              if (_saving) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
