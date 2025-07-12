import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoldInvestment extends StatefulWidget {
  const GoldInvestment({super.key});

  @override
  State<GoldInvestment> createState() => _GoldInvestmentState();
}

class _GoldInvestmentState extends State<GoldInvestment> {
  double? goldPriceUSD;
  double? goldPricePKR;
  bool isLoading = true;
  bool isError = false;
  DateTime? lastUpdated;
  final double usdToPkrRate = 278.0;

  @override
  void initState() {
    super.initState();
    fetchGoldPrice();
  }

  Future<void> fetchGoldPrice() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final url = Uri.parse(
      'https://api.metalpriceapi.com/v1/latest?api_key=81956052f98a23ce2de4af145439c986&base=USD&currencies=XAU',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      final usdPrice = data['rates']['XAU'];

      setState(() {
        goldPriceUSD = usdPrice;
        goldPricePKR = usdPrice * usdToPkrRate;
        lastUpdated = DateTime.now();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
     
      body: RefreshIndicator(
        onRefresh: fetchGoldPrice,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 50),
                            const SizedBox(height: 10),
                            const Text("Failed to fetch data", style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: fetchGoldPrice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Live Gold Rate",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPriceRow("Price in USD", "\$${goldPriceUSD?.toStringAsFixed(2)} / ounce"),
                                const SizedBox(height: 12),
                                _buildPriceRow("Price in PKR", "₨${goldPricePKR?.toStringAsFixed(0)} / ounce"),
                                if (lastUpdated != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    "Last updated: ${_formatTime(lastUpdated!)}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Why Invest in Gold?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Gold is a timeless asset that retains value and protects against inflation. "
                          "It provides safety during market volatility and is globally recognized as a strong store of value.",
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return "${time.day}/${time.month}/${time.year} at $formattedTime";
  }
}
