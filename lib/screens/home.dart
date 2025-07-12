import 'package:flutter/material.dart';
import '../components/appbar.dart';
import '../components/botton_navbar.dart';
import '../screens/portfolio.dart';
import '../screens/ai_suggestions.dart';
import '../screens/quiz.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeBody(),             // Index 0 - Home
    // PortfolioScreen(),      // Index 1 - Portfolio
    // AiSuggestionsScreen(),  // Index 2 - AI Advisor
    // QuizScreen(),           // Index 3 - Quiz
    // You can add more screens as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: buildInvestWiseAppBar(context),  
    //  drawer: const InvestWiseDrawer(),         // ✅ Drawer added
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "👋 Hello, Investor!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Explore smart investments and track your financial journey with InvestWise.",
            style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}
