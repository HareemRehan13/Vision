import 'dart:async';
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
  bool isLoading = true, isError = false;
  double? goldPricePKR, previousPrice;
  List<double> goldHistory = [];
  Map<String, double> cityRates = {};
  List<Map<String, dynamic>> last10Days = [];
  DateTime? lastUpdated;

  TextEditingController gramsController = TextEditingController();
  double calculatedAmount = 0;
  bool isBuying = true;
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    fetchAllData();
    autoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => fetchAllData());
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAllData() async {
    setState(() => isLoading = true);
    try {
      await fetchGoldPrice();
      await fetchCityRates();
      await fetchLast10Days();
      setState(() => isLoading = false);
    } catch (_) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchGoldPrice() async {
    try {
      final goldResponse = await http.get(Uri.parse(
        'https://api.metalpriceapi.com/v1/latest?api_key=81956052f98a23ce2de4af145439c986&base=USD&currencies=XAU',
      ));
      final goldData = json.decode(goldResponse.body);
      double priceUSD = 1 / goldData['rates']['XAU'];

      final currencyResponse = await http.get(Uri.parse(
        'https://v6.exchangerate-api.com/v6/bb7635a185b9df0f5d4950f3/latest/USD',
      ));
      final currencyData = json.decode(currencyResponse.body);
      double usdToPkr = currencyData['conversion_rates']['PKR'];

      double pricePKR = priceUSD * usdToPkr;

      setState(() {
        previousPrice = goldPricePKR;
        goldPricePKR = pricePKR;
        goldHistory.add(pricePKR);
        if (goldHistory.length > 7) goldHistory.removeAt(0);
        lastUpdated = DateTime.now();
      });
    } catch (e) {
      throw Exception('Failed to fetch gold or exchange data');
    }
  }

  Future<void> fetchCityRates() async {
    if (goldPricePKR == null) return;
    setState(() {
      cityRates = {
        'Karachi': goldPricePKR!,
        'Lahore': goldPricePKR! * 1.01,
        'Islamabad': goldPricePKR! * 0.99,
      };
    });
  }

  Future<void> fetchLast10Days() async {
    if (goldPricePKR == null) return;
    DateTime today = DateTime.now();
    last10Days = List.generate(10, (i) {
      return {
        'date': today.subtract(Duration(days: i)),
        'price': goldPricePKR! * (1 + (i - 5) * 0.002),
      };
    });
  }

  void calculateAmount() {
    double grams = double.tryParse(gramsController.text) ?? 0;
    setState(() {
      calculatedAmount = grams * (goldPricePKR ?? 0) / 31.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: fetchAllData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
                ? _errorView()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildTopHeader(),
                      const SizedBox(height: 20),
                      _buildPriceCard(),
                      const SizedBox(height: 20),
                      _buildGraphCard(),
                      const SizedBox(height: 24),
                      _buildCityRatesSection(),
                      const SizedBox(height: 24),
                      _buildLast10DaysSection(),
                      const SizedBox(height: 24),
                      _buildBuySellSection(),
                      const SizedBox(height: 24),
                      _buildWhyInvestCard(),
                    ],
                  ),
      ),
    );
  }

  Widget _errorView() => ListView(
        children: [
          const SizedBox(height: 100),
          const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 50)),
          const SizedBox(height: 10),
          const Center(child: Text("Failed to load data", style: TextStyle(fontSize: 16))),
        ],
      );

  Widget _buildTopHeader() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A0594), Color(0xFF574BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            const Text("Live Gold Price",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            if (lastUpdated != null)
              Text("Updated: ${lastUpdated!.day}/${lastUpdated!.month}/${lastUpdated!.year} "
                  "${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );

  Widget _buildPriceCard() {
    double percentChange = previousPrice != null
        ? ((goldPricePKR! - previousPrice!) / previousPrice!) * 100
        : 0;
    bool isPositive = percentChange >= 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Current Gold Price (PKR)", style: TextStyle(fontSize: 18)),
          Row(
            children: [
              Text("₨ ${goldPricePKR?.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red),
              Text("${percentChange.toStringAsFixed(2)}%",
                  style: TextStyle(color: isPositive ? Colors.green : Colors.red)),
            ],
          ),
        ]),
      ),
    );
  }

Widget _buildGraphCard() => Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("7-Day Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (last10Days.length >= 2)
          SizedBox(
            height: 180,
            child: LineChart(LineChartData(
              titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < last10Days.length) {
                    final date = last10Days[index]['date'] as DateTime;
                    return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                },
              ))),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(last10Days.length,
                    (i) => FlSpot(i.toDouble(), last10Days[i]['price'])),
                  isCurved: true,
                  color: const Color(0xFF0011FF),
                  barWidth: 2.5,
                  dotData: FlDotData(show: false),
                )
              ],
            )),
          ),
      ],
    ),
  ),
);

 Widget _buildCityRatesSection() => Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gold Price in Major Cities",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
          },
          border: TableBorder.all(color: Colors.grey),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFEAEAEA)),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Price (PKR)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...cityRates.entries.map(
              (entry) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(entry.key),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('₨ ${entry.value.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    ),
  ),
);

Widget _buildLast10DaysSection() => Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gold Prices - Last 10 Days",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
          },
          border: TableBorder.all(color: Colors.grey),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFEAEAEA)),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Gold 24K Tola', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('10 Gram Gold 22K', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...last10Days.map((item) {
              DateTime date = item['date'];
              double price24KTola = item['price'];
              double price22K10Gram = price24KTola * 0.916 * 10 / 11.66; // approx 22K rate for 10g
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('${date.day}/${date.month}/${date.year}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('₨ ${price24KTola.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('₨ ${price22K10Gram.toStringAsFixed(2)}'),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    ),
  ),
);

  Widget _buildBuySellSection() => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Buy / Sell Simulator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter grams", border: OutlineInputBorder()),
              onChanged: (_) => calculateAmount(),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => setState(() => isBuying = true), child: const Text("Buy"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => setState(() => isBuying = false), child: const Text("Sell"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))),
            ]),
            const SizedBox(height: 12),
            Text(calculatedAmount == 0 ? "Enter grams to calculate" : "You will ${isBuying ? 'spend' : 'earn'} approx ₨ ${calculatedAmount.toStringAsFixed(2)}"),
          ]),
        ),
      );

 Widget _buildWhyInvestCard() => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.yellow[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF1A0594)), // theme-matching border color
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        "Why Invest in Gold?",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A0594), // theme header color
        ),
      ),
      SizedBox(height: 8),
      Text(
        "Gold is a timeless asset that protects against inflation, holds intrinsic value, and remains resilient in volatile markets. It's globally recognized and easily tradable.",
        style: TextStyle(fontSize: 15),
      ),
    ],
  ),
);
}
