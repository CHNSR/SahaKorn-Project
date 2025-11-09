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
  bool _loading = true;
  bool _seen = false;
  String? _role;
  User? _firebaseUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _firebaseUser = user;
        _checkSeen(); // Re-check seen status and role when auth state changes
      });
    });
    _checkSeen();
  }

  Future<void> _checkSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_intermediary') ?? false;
    final role = prefs.getString('user_role');
    setState(() {
      _seen = seen;
      _role = role;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // If Firebase user is null, navigate to LoginScreen
    if (_firebaseUser == null) return const LoginScreen();

    // If user is logged in via Firebase, proceed with existing logic
    if (!_seen) return const IntermediaryScreen();
    if (_role == 'customer') return const NavbarCustomer();
    // default to shop for any other/unknown role
    return const NavbarShop();
  }
}
