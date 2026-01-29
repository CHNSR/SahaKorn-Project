import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/theme_provider.dart';
import 'package:sahakorn3/src/routes/routes.dart';
import 'package:sahakorn3/src/widgets/logout_list_title.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle('Account & Payment'),
              _buildSectionContainer(
                children: [
                  _buildSettingItem(
                    icon: Icons.person,
                    iconColor: Colors.blueAccent,
                    title: 'Edit Profile',
                    subtitle: 'Name, phone, address',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.createCustomerProfile,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.qr_code,
                    iconColor: Colors.teal,
                    title: 'My QR Code',
                    subtitle: 'Show to shop',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.myQrCode);
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.payment,
                    iconColor: Colors.green,
                    title: 'Payment Methods',
                    subtitle: 'Manage cards & bank accounts',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.store,
                    iconColor: Colors.indigo,
                    title: 'Create Shop',
                    subtitle: 'Start your own shop',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.createShop);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Security & App'),
              _buildSectionContainer(
                children: [
                  _buildSettingItem(
                    icon: Icons.lock,
                    iconColor: Colors.orange,
                    title: 'Change Password / PIN',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    secondary: _buildIcon(Icons.fingerprint, Colors.purple),
                    title: const Text(
                      'Biometrics',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    value: _biometrics,
                    activeTrackColor: Colors.green,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onChanged: (v) => setState(() => _biometrics = v),
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    secondary: _buildIcon(
                      Icons.notifications_active,
                      Colors.redAccent,
                    ),
                    title: const Text(
                      'Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    value: _notification,
                    activeTrackColor: Colors.green,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onChanged: (val) => setState(() => _notification = val),
                  ),
                  _buildDivider(),
                  Consumer<ThemeProvider>(
                    builder: (context, theme, _) {
                      return SwitchListTile(
                        secondary: _buildIcon(Icons.dark_mode, Colors.black87),
                        title: const Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        value: theme.isDark,
                        activeTrackColor: Colors.green,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        onChanged: (val) => theme.toggle(),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.language,
                    iconColor: Colors.teal,
                    title: 'Language',
                    trailing: const Text(
                      'ไทย / TH',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Support & Others'),
              _buildSectionContainer(
                children: [
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    iconColor: Colors.blueGrey,
                    title: 'About',
                    subtitle: 'Version and legal',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    iconColor: Colors.teal,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.admin_panel_settings_outlined,
                    iconColor: Colors.red,
                    title: 'Bypass to Shop',
                    subtitle: 'For testing purposes only',
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_role', 'shop');
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.shopHome,
                          (route) => false,
                        );
                      }
                    },
                  ),
                  _buildDivider(),
                  const LogoutListTile(),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Made with ❤ by Sahakorn',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.indigo.shade50,
            child: Icon(Icons.person, size: 32, color: Colors.indigo.shade400),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {
                Navigator.pushNamed(context, Routes.createCustomerProfile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIcon(icon, iconColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              )
              : null,
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
      onTap: onTap,
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60, // Align with text, skipping icon
      color: Colors.grey[200],
    );
  }
}
