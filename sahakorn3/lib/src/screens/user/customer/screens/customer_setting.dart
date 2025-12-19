import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/theme_provider.dart';
import 'package:sahakorn3/src/screens/user/customer/screens_layer2/editscreen.dart';
import 'package:sahakorn3/src/widgets/logout_list_title.dart';
import 'package:sahakorn3/src/screens/guest/create/create_shop.dart';
import 'package:sahakorn3/src/widgets/shop_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Methods'),
                    subtitle: const Text('Manage cards & bank accounts'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Create Shop'),
                    subtitle: const Text('Start your own shop'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateShopScreen(),
                        ),
                      );
                    },
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
                  Consumer<ThemeProvider>(
                    builder: (context, theme, _) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text('Dark Mode'),
                        value: theme.isDark,
                        onChanged: (val) => theme.toggle(),
                      );
                    },
                  ),
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
                    leading: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Bypass to Shop',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('For testing purposes only'),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_role', 'shop');
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const NavbarShop(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const Divider(),
                  const LogoutListTile(), // 2. เรียกใช้งาน Widget ที่นี่
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Made with ❤ by Sahakorn',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Setting',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Setting your account in this page',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(radius: 30, child: Icon(Icons.person)),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 0),
          ...children,
        ],
      ),
    );
  }
}
