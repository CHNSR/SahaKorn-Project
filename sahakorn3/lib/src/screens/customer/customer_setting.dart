import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahakorn3/src/widgets/logout_list_title.dart';


class CustomerSetting extends StatefulWidget {
  const CustomerSetting({super.key});

  @override
  State<CustomerSetting> createState() => _CustomerSettingState();
}

class _CustomerSettingState extends State<CustomerSetting> {
  bool _notification = true;
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
                    subtitle: const Text('Name, phone, address'),
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
                    title: const Text('Change Password / PIN'),
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
                  const Divider(),
                  const LogoutListTile(), // 2. เรียกใช้งาน Widget ที่นี่
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
    // Get the current user from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        CircleAvatar(radius: 36, backgroundColor: Colors.green[100], child: const Icon(Icons.person, size: 34, color: Colors.green)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('บัญชีของฉัน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // Display the user's actual email
              Text(user?.email ?? 'No email found', style: const TextStyle(color: Colors.black54)),
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
}
