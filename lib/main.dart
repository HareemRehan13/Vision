import 'package:investapp/firebase_options.dart';
import 'package:investapp/screens/home.dart';
import 'package:investapp/screens/login.dart';
import 'package:investapp/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('notificationsEnabled')) {
    await prefs.setBool('notificationsEnabled', true);
  }

  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investify',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: isLoggedIn ? Home() : Login(),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/home': (context) => Home(),
      },
    );
  }
}
