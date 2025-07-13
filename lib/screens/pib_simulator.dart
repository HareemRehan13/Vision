import 'package:flutter/material.dart';

class PIBSimulatorPage extends StatefulWidget {
  const PIBSimulatorPage({super.key});

  @override
  State<PIBSimulatorPage> createState() => _PIBSimulatorPageState();
}

class _PIBSimulatorPageState extends State<PIBSimulatorPage> {
  final _amountController = TextEditingController();
  String selectedDuration = '3 Years';

  final Map<String, double> bondRates = {
    '3 Years': 15.20,
    '5 Years': 14.80,
    '10 Years': 13.90,
  };

  double? annualReturn, totalReturn;

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final years = int.parse(selectedDuration.split(' ')[0]);
    final rate = bondRates[selectedDuration]!;

    if (amount <= 0) return;

    final annual = amount * rate / 100;
    setState(() {
      annualReturn = annual;
      totalReturn = annual * years;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIB Bonds Simulator'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDuration,
              decoration: const InputDecoration(
                labelText: 'Select Duration',
                border: OutlineInputBorder(),
              ),
              items: bondRates.keys
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedDuration = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Investment Amount (PKR)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate Return'),
            ),
            const SizedBox(height: 20),
            if (annualReturn != null && totalReturn != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📅 Annual Return: PKR ${annualReturn!.toStringAsFixed(2)}'),
                  Text('🏁 Total Return: PKR ${totalReturn!.toStringAsFixed(2)}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
