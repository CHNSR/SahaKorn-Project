import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sahakorn3/firebase_options.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/providers/theme_provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserInformationProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahakorn',
      theme: ThemeData(
        // Keep green as the accent (seed) but force neutral white backgrounds
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
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
        textTheme: ThemeData.light().textTheme,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: context.watch<ThemeProvider>().mode,
      routes: Routes.getRoutes(context),
      initialRoute: Routes.root,
      debugShowCheckedModeBanner: false,
    );
  }
}
