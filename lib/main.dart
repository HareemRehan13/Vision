import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/splash.dart';
import 'screens/onboarding.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Set default preferences
  if (!prefs.containsKey('notificationsEnabled')) {
    await prefs.setBool('notificationsEnabled', true);
  }

  // Check onboarding & login status
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  runApp(MyApp(
    isFirstTime: isFirstTime,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isFirstTime,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),

      // Start with splash screen and pass onboarding/login state
      home: Splash(
        isFirstTime: isFirstTime,
        isLoggedIn: isLoggedIn,
      ),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/home': (context) => const Home(),
      },
    );
  }
}
