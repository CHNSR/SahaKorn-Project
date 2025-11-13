import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/widgets/shop_navbar.dart';
import 'package:sahakorn3/src/widgets/customer_navbar.dart';
import 'src/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahakorn3/src/screens/intermediary/intermediary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sahakorn3/firebase_options.dart';
import 'package:sahakorn3/src/screens/auth/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // Keep green as the accent (seed) but force neutral white backgrounds
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light),
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            canvasColor: Colors.white,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: false,
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
            // Keep text readable on white
            textTheme: ThemeData.light().textTheme,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: theme.mode,
          home: const Root(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  // We can remove all the manual state variables. StreamBuilder will handle it.

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Case 2: User is logged in (snapshot has data)
        if (snapshot.hasData && snapshot.data != null) {
          // Now that we know the user is logged in, let's check their role from prefs
          return FutureBuilder<Map<String, dynamic>>(
            future: _getPrefsData(),
            builder: (context, prefSnapshot) {
              if (prefSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
