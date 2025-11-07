import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/theme_provider.dart';

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  bool _notification = true;
  // remove local dark mode flag; use ThemeProvider instead
  bool _biometrics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView(
            children: [
              _buildAccountHeader(),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Profile',
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Name, phone, shop info'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Methods'),
                    subtitle: const Text('Manage cards & bank accounts'),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Security',
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {},
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Use Biometrics'),
                    value: _biometrics,
                    onChanged: (v) => setState(() => _biometrics = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Notifications & Appearance',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active),
                    title: const Text('Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _notification,
                    onChanged: (val) => setState(() => _notification = val),
                  ),
                  Consumer<ThemeProvider>(builder: (context, theme, _) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: const Text('Dark Mode'),
                      value: theme.isDark,
                      onChanged: (val) => theme.toggle(),
                    );
                  }),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: const Text('ไทย / TH'),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Account & App',
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    subtitle: const Text('Version and legal'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Sign out', style: TextStyle(color: Colors.red)),
                    onTap: _confirmSignOut,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text('Made with ❤ by Sahakorn', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 36, backgroundColor: Colors.green[100], child: const Icon(Icons.store, size: 34, color: Colors.green)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('ร้านค้าของฉัน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('owner@example.com', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 0),
          ...children,
        ],
      ),
    );
  }

  void _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      // TODO: perform sign out logic
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
    }
  }
}

