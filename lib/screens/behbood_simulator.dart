import 'package:flutter/material.dart';

class BehboodSimulatorPage extends StatefulWidget {
  const BehboodSimulatorPage({super.key});

  @override
  State<BehboodSimulatorPage> createState() => _BehboodSimulatorPageState();
}

class _BehboodSimulatorPageState extends State<BehboodSimulatorPage> {
  final _amountController = TextEditingController();
  final _yearsController = TextEditingController();

  static const double annualRate = 14.16;
  double? monthlyReturn, totalReturn;

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;

    if (amount <= 0 || years <= 0) return;

    final annual = amount * annualRate / 100;
    setState(() {
      monthlyReturn = annual / 12;
      totalReturn = annual * years;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CDNS: Behbood Simulator'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Investment Amount (PKR)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: 'Duration in Years',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            if (monthlyReturn != null && totalReturn != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📅 Monthly Return: PKR ${monthlyReturn!.toStringAsFixed(2)}'),
                  Text('🏁 Total Return: PKR ${totalReturn!.toStringAsFixed(2)}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
