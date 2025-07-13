import 'package:flutter/material.dart';

class BankTermDepositSimulatorPage extends StatefulWidget {
  const BankTermDepositSimulatorPage({super.key});

  @override
  State<BankTermDepositSimulatorPage> createState() => _BankTermDepositSimulatorPageState();
}

class _BankTermDepositSimulatorPageState extends State<BankTermDepositSimulatorPage> {
  final _amountController = TextEditingController();
  final _yearsController = TextEditingController();

  static const double rate = 12.0;
  static const double earlyWithdrawalPenalty = 2.0;

  double? totalReturn, penaltyAmount;

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;

    if (amount <= 0 || years <= 0) return;

    final total = amount * (rate / 100) * years;
    final penalty = amount * (earlyWithdrawalPenalty / 100);

    setState(() {
      totalReturn = total;
      penaltyAmount = penalty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Term Deposit Simulator'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Deposit Amount (PKR)',
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
            if (totalReturn != null && penaltyAmount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📈 Total Return: PKR ${totalReturn!.toStringAsFixed(2)}'),
                  Text('⚠️ Early Withdrawal Penalty: PKR ${penaltyAmount!.toStringAsFixed(2)}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
