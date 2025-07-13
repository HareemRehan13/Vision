import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class GoldInvestment extends StatefulWidget {
  const GoldInvestment({super.key});

  @override
  State<GoldInvestment> createState() => _GoldInvestmentState();
}

class _GoldInvestmentState extends State<GoldInvestment> {
  double? goldPriceUSD;
  double? goldPricePKR;
  double? previousPrice;
  bool isLoading = true;
  bool isError = false;
  DateTime? lastUpdated;
  final double usdToPkrRate = 278.0;
  List<double> goldHistory = [];

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
      final double rawXAU = data['rates']['XAU'];
      final double priceInUSD = 1 / rawXAU;

      setState(() {
        previousPrice = goldPriceUSD ?? priceInUSD;
        goldPriceUSD = priceInUSD;
        goldPricePKR = priceInUSD * usdToPkrRate;
        lastUpdated = DateTime.now();

        goldHistory.add(priceInUSD);
        if (goldHistory.length > 7) {
          goldHistory.removeAt(0);
        }

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
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildTopHeader(),
                      const SizedBox(height: 20),
                      _buildPriceCard(),
                      const SizedBox(height: 20),
                      _buildGraphCard(),
                      const SizedBox(height: 24),
                      Text(
                        "Why Invest in Gold?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color.fromARGB(255, 91, 79, 255)!),
                        ),
                        child: const Text(
                          "Gold is a timeless asset that protects against inflation, "
                          "holds intrinsic value, and remains resilient in volatile markets. "
                          "It's globally recognized and easily tradable.",
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 26, 5, 148)!, const Color.fromARGB(255, 87, 75, 255)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            "Live Gold Price",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black45,
                  offset: Offset(1, 2),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (lastUpdated != null)
            Text(
              "Updated: ${_formatTime(lastUpdated!)}",
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    double percentChange = previousPrice != null && goldPriceUSD != null
        ? ((goldPriceUSD! - previousPrice!) / previousPrice!) * 100
        : 0;
    final bool isPositive = percentChange >= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Gold Price", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "\$${goldPriceUSD?.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  "${percentChange.toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("₨${goldPricePKR?.toStringAsFixed(0)} PKR", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              "Last updated: ${_formatTime(lastUpdated!)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("7-Day Price Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        goldHistory.length,
                        (index) => FlSpot(index.toDouble(), goldHistory[index]),
                      ),
                      isCurved: true,
                      barWidth: 2.5,
                      color: const Color.fromARGB(223, 0, 17, 255),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return "${time.day}/${time.month}/${time.year} at $formattedTime";
  }
}
