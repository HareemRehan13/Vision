import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockInvestment extends StatefulWidget {
  const StockInvestment({super.key});

  @override
  State<StockInvestment> createState() => _StockInvestmentState();
}

class _StockInvestmentState extends State<StockInvestment> {
  final double usdToPkrRate = 278.0;
  final String apiKey = 'ecf15b9fc8a5460192db0d33a2fad51c'; // Your TwelveData API key

  String selectedSymbol = 'AAPL';
  final List<String> stockSymbols = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'META'];

  double? stockPriceUSD;
  double? stockPricePKR;
  bool isLoading = true;
  bool isError = false;
  bool isTrendingUp = true;
  double? previousPrice;
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    fetchStockPrice();
  }

  Future<void> fetchStockPrice() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final url = Uri.parse(
        'https://api.twelvedata.com/price?symbol=$selectedSymbol&apikey=$apiKey');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['price'] != null) {
        final double usdPrice = double.parse(data['price']);
        setState(() {
          isTrendingUp = previousPrice == null ? true : usdPrice >= previousPrice!;
          previousPrice = usdPrice;
          stockPriceUSD = usdPrice;
          stockPricePKR = usdPrice * usdToPkrRate;
          lastUpdated = DateTime.now();
          isLoading = false;
        });
      } else {
        throw Exception("Invalid data");
      }
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
        onRefresh: fetchStockPrice,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
                ? _buildErrorUI()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildDropdown(),
                        const SizedBox(height: 20),
                        _buildPriceCard(),
                        const SizedBox(height: 30),
                        _buildWhyInvestSection(),
                        const SizedBox(height: 30),
                        // Placeholder for chart
                        // Container(
                        //   height: 200,
                        //   width: double.infinity,
                        //   color: Colors.white,
                        //   child: Center(child: Text("Chart Coming Soon")),
                        // ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isTrendingUp ? Icons.trending_up : Icons.trending_down,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Live Stock Price",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                selectedSymbol,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Row(
      children: [
        const Text(
          "Select Stock:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: selectedSymbol,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedSymbol = newValue;
              });
              fetchStockPrice();
            }
          },
          items: stockSymbols.map((symbol) {
            return DropdownMenuItem(
              value: symbol,
              child: Text(symbol),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRow("💵 Price in USD", "\$${stockPriceUSD?.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            _buildPriceRow("🇵🇰 Price in PKR", "₨${stockPricePKR?.toStringAsFixed(0)}"),
            const SizedBox(height: 12),
            if (lastUpdated != null)
              Text(
                "Last updated: ${_formatTime(lastUpdated!)}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWhyInvestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "📈 Why Invest in Stocks?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueAccent),
        ),
        SizedBox(height: 10),
        Text(
          "Stocks offer long-term growth and ownership in companies. "
          "They have the potential for high returns and are a key part of diversified portfolios.",
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildErrorUI() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              const Text("Failed to fetch stock data", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchStockPrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return "${time.day}/${time.month}/${time.year} at $formattedTime";
  }
}
