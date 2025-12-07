import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahakorn3/src/screens/intermediary/intermediary.dart';
import 'package:sahakorn3/src/screens/auth/login/login.dart';
import 'package:sahakorn3/src/widgets/shop_navbar.dart';
import 'package:sahakorn3/src/widgets/customer_navbar.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  Future<Map<String, dynamic>> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_intermediary') ?? false;
    final role = prefs.getString('user_role');
    return {'seen': seen, 'role': role};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Case 1: Stream is still waiting for the first event
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Case 2: User is logged in (snapshot has data)
        if (snapshot.hasData && snapshot.data != null) {
          // Now that we know the user is logged in, let's check their role from prefs
          return FutureBuilder<Map<String, dynamic>>(
            future: _getPrefsData(),
            builder: (context, prefSnapshot) {
              if (prefSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool seen = prefSnapshot.data?['seen'] ?? false;
              final String? role = prefSnapshot.data?['role'];

              if (!seen) {
                return const IntermediaryScreen();
              }

              if (role == 'shop') {
                return const NavbarShop();
              }
              // Default to customer if role is null or something else
              return const NavbarCustomer();
            },
          );
        }

        // Case 3: User is logged out (snapshot has no data)
        return const LoginScreen();
      },
    );
  }
}
