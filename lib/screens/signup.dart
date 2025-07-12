import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();

  String? investmentExperience;
  List<String> selectedInvestmentTypes = [];
  String? selectedCity;
  String? selectedBank;

  bool agreeTerms = false;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> experienceOptions = ['Beginner', 'Intermediate', 'Expert'];
  final List<String> investmentTypes = ['Stocks', 'Gold', 'Property', 'Crypto', 'Mutual Funds'];
  final List<String> cities = ['Karachi', 'Lahore', 'Islamabad', 'Peshawar', 'Quetta'];
  final List<String> bankOptions = ['HBL', 'UBL', 'Meezan Bank', 'MCB', 'Alfalah Bank', 'JazzCash', 'EasyPaisa'];

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  signup() async {
    if (!_formKey.currentState!.validate() || !agreeTerms) {
      if (!agreeTerms) showSnack("You must agree to the terms and conditions.");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullNameController.text.trim(),
        'nic': nicController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'experience': investmentExperience,
        'preferredTypes': selectedInvestmentTypes,
        'city': selectedCity,
        'bankName': selectedBank,
        'accountNumber': accountNumberController.text.trim(),
        'initialDeposit': double.parse(depositAmountController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showSnack("Signup failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _input(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              const SizedBox(height: 20),

              TextFormField(
                controller: fullNameController,
                decoration: _input("Full Name", Icons.person),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: nicController,
                decoration: _input("NIC Number", Icons.badge),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'NIC is required';
                  final nicPattern = RegExp(r'^(\d{5}-\d{7}-\d{1}|\d{13})$');
                  if (!nicPattern.hasMatch(value)) return 'Enter a valid NIC (e.g. 12345-1234567-1)';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                decoration: _input("Email", Icons.email),
                validator: (v) => v != null && v.contains('@') ? null : "Enter valid email",
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: _input("Phone", Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (v) => v != null && v.length >= 10 ? null : "Enter valid phone",
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: investmentExperience,
                decoration: _input("Investment Experience", Icons.bar_chart),
                items: experienceOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => investmentExperience = val),
                validator: (v) => v == null ? "Select experience level" : null,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 6,
                children: investmentTypes.map((type) {
                  final isSelected = selectedInvestmentTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedInvestmentTypes.add(type);
                        } else {
                          selectedInvestmentTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: Colors.blue[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: _input("City", Icons.location_city),
                items: cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => selectedCity = val),
                validator: (v) => v == null ? "Select city" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedBank,
                decoration: _input("Select Bank or Wallet", Icons.account_balance),
                items: bankOptions.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                onChanged: (val) => setState(() => selectedBank = val),
                validator: (v) => v == null ? "Please select a bank or wallet" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: accountNumberController,
                decoration: _input("Account Number", Icons.credit_card),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.length < 10 ? "Enter valid account number" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: depositAmountController,
                decoration: _input("Initial Deposit Amount", Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter amount";
                  final amount = double.tryParse(v);
                  if (amount == null) return "Enter a valid amount";
                  if (amount < 50000) return "Minimum deposit is Rs. 50,000";
                  return null;
                },
              ),
              const SizedBox(height: 6),

              const Text(
                "* This is a virtual deposit for simulation only. No real bank transaction will occur.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: _input("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => v != null && v.length >= 6 ? null : "Min 6 characters",
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _input("Confirm Password", Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (v) => v != null && v == passwordController.text ? null : "Passwords don’t match",
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                title: const Text("I agree to the Terms and Conditions", style: TextStyle(fontSize: 14)),
                value: agreeTerms,
                onChanged: (val) => setState(() => agreeTerms = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/login"),
                    child: Text("Login", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
