import 'package:flutter/material.dart';

class MutualFundInvestment extends StatefulWidget {
  const MutualFundInvestment({super.key});

  @override
  State<MutualFundInvestment> createState() => _MutualFundInvestmentState();
}

class _MutualFundInvestmentState extends State<MutualFundInvestment> {
  bool isLoading = true;
  bool isError = false;

  List<Map<String, dynamic>> mutualFunds = [];

  @override
  void initState() {
    super.initState();
    fetchMutualFunds();
  }

  Future<void> fetchMutualFunds() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate network delay
    try {
      // Mock Pakistani mutual funds data
      final List<Map<String, dynamic>> data = [
        {
          "name": "UBL Stock Advantage Fund",
          "nav": 105.23,
          "return1Y": 18.45,
          "lastUpdated": "2025-07-13"
        },
        {
          "name": "Meezan Islamic Fund",
          "nav": 91.75,
          "return1Y": 15.67,
          "lastUpdated": "2025-07-13"
        },
        {
          "name": "HBL Equity Fund",
          "nav": 112.34,
          "return1Y": 12.30,
          "lastUpdated": "2025-07-13"
        },
        {
          "name": "Atlas Stock Market Fund",
          "nav": 88.20,
          "return1Y": 14.92,
          "lastUpdated": "2025-07-13"
        },
      ];

      setState(() {
        mutualFunds = data;
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
   
      body: RefreshIndicator(
        onRefresh: fetchMutualFunds,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
                ? _buildError()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mutualFunds.length,
                    itemBuilder: (_, i) => _buildFundCard(mutualFunds[i]),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              const Text("Failed to load mutual funds data"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchMutualFunds,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundCard(Map<String, dynamic> fund) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("NAV: ₨${fund['nav'].toStringAsFixed(2)}"),
            Text("1-Year Return: ${fund['return1Y']}%"),
            Text("Last Updated: ${fund['lastUpdated']}", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
