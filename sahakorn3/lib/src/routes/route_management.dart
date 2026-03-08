import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<Map<String, dynamic>> _determineUserRole(String uid) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check local first (fastest)
    bool seen = prefs.getBool('seen_intermediary') ?? false;
    String? role = prefs.getString('user_role');

    if (seen && role != null) {
      return {'seen': true, 'role': role};
    }

    // 2. If not found locally, check Firestore (e.g. new install, clear data)
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Assuming 'user_level' stores 'shop' or 'customer'
        final String? firestoreRole = data['user_level'];

        if (firestoreRole != null && firestoreRole.isNotEmpty) {
          // Save to local for next time
          await prefs.setBool('seen_intermediary', true);
          await prefs.setString('user_role', firestoreRole);
          return {'seen': true, 'role': firestoreRole};
        }
      }
    } catch (e) {
      debugPrint("AuthGate: Error checking user role from Firestore: $e");
    }

    // Default: Not seen or role not found
    return {'seen': false, 'role': null};
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
          final user = snapshot.data!;
          // Now that we know the user is logged in, let's check their role from prefs/firestore
          return FutureBuilder<Map<String, dynamic>>(
            future: _determineUserRole(user.uid),
            builder: (context, prefSnapshot) {
              if (prefSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool seen = prefSnapshot.data?['seen'] ?? false;
              final String? role = prefSnapshot.data?['role'];

              if (!seen) {
                return const SelectRole();
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
