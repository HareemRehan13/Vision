import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        prefs.setBool("isLoggedIn", true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful!', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF003366),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(context, '/');
      } on FirebaseAuthException catch (e) {
        String errorMsg = e.code == 'user-not-found'
            ? 'No user found with this email.'
            : e.code == 'wrong-password'
                ? 'Incorrect password.'
                : 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("An error occurred")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF003366)),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      suffixIcon: Icon(icon, color: Colors.grey, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF003366)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF003366), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          color: Color(0xFF003366),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Sign in to continue",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(70),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: const Icon(Icons.lock_outline, color: Color(0xFF003366), size: 80),
                    ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email', 'Enter your email', Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Password', 'Enter your password', Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return 'Minimum 6 characters required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF003366))
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                    const SizedBox(height: 20),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5.0,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/signup"),
                          child: const Text(
                            "Signup",
                            style: TextStyle(color: Color(0xFF003366), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
