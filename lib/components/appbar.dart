import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investapp/screens/login.dart';
import 'package:investapp/screens/pak_investments.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const InvestWiseApp());
}

class InvestWiseApp extends StatelessWidget {
  const InvestWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InvestWise',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false); // ✅ important line
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: buildInvestWiseAppBar(context),
      body: const Center(
        child: Text(
          'Welcome to Investify!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Stateful widget to toggle balance visibility
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  _isVisible ? 'Rs. 25,000' : '••••••',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _isVisible = !_isVisible),
                  child: Icon(
                    _isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget buildInvestWiseAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: const Color(0xFF003366),
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.menu, color: Color(0xFF003366)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'InvestiFy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
       IconButton(
        
  icon: const Icon(Icons.flag, color: Colors.white),
  tooltip: 'Pakistan Investments',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Pakistan(),
      ),
    );
  },
),

      IconButton(
  icon: const Icon(Icons.logout, color: Colors.white),
  onPressed: () => _showLogoutConfirmationDialog(context),
),


      ],
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
        child: BalanceCard(),
      ),
    ),
  );
}
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _settingsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF003366)),
              accountName: const Text("Ansharah Sabir"),
              accountEmail: const Text("investor@example.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF003366), size: 30),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Savings & Deposits'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Help & Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.swap_vert),
              title: const Text('Transaction History'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('Watchlist'),
              onTap: () {},
            ),

            ExpansionTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Preferences'),
              initiallyExpanded: _settingsExpanded,
              onExpansionChanged: (expanded) =>
                  setState(() => _settingsExpanded = expanded),
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Alerts'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Appearance'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Data & Privacy'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About InvestWise'),
                  onTap: () {},
                ),
              ],
            ),

            const Divider(),
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", false); 
      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  },
),


          ],
        ),
      ),
    );
  }
}
