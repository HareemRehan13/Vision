import 'package:flutter/material.dart';

import 'behbood_simulator.dart';
import 'pib_simulator.dart';
import 'bank_term_deposit_simulator.dart';
import 'halal_investments_info.dart';

class Pakistan extends StatelessWidget {
  const Pakistan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🇵🇰 Pakistan Investments'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInvestmentCard(
            context: context,
            title: '🏦 National Savings Schemes (CDNS)',
            subtitle:
                'Behbood, Pensioner\'s, and Regular Income Certificates with fixed returns and maturity benefits.',
            page: const BehboodSimulatorPage(),
          ),
          _buildInvestmentCard(
            context: context,
            title: '💰 Pakistan Investment Bonds (PIBs)',
            subtitle:
                'Simulated government bond returns over 3, 5, and 10 years with fixed interest.',
            page: const PIBSimulatorPage(),
          ),
          _buildInvestmentCard(
            context: context,
            title: '🏦 Bank Term Deposits (Local Banks)',
            subtitle:
                'Understand how fixed-term deposits work with annual returns and early withdrawal penalties.',
            page: const BankTermDepositSimulatorPage(),
          ),
          _buildInvestmentCard(
            context: context,
            title: '🌿 Halal / Shariah-Compliant Investments',
            subtitle:
                'Mock investments in halal stocks, no-interest savings, and ethical businesses.',
            page: const HalalStockTrackerPage(),
          ),
          const SizedBox(height: 20),
          const Text(
            '📚 Educational Value',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('• Compare local and global investment strategies'),
          const Text('• Learn about culturally popular savings models'),
          const Text('• Explore Shariah-compliant finance options'),
          const Text('• Ideal for students, women, and retirees'),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.trending_up, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
