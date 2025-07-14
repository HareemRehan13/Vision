import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatelessWidget {
  final bool isFirstTime;
  final bool isLoggedIn;

  const Splash({
    super.key,
    required this.isFirstTime,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    // Navigate after 2 seconds
    Timer(const Duration(seconds: 2), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (isFirstTime) {
        prefs.setBool('isFirstTime', false);
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF003366), // deep blue
   body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
     'public/assets/images/logo.png',
        width: 280,
        height: 280,
      ),
    
      
      const Text(
        'Learn. Simulate. Grow.',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
          color: Colors.white70,
        ),
      ),
    ],
  ),
),
);
  }
}
