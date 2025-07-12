import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mutual_funds.dart';
import 'gold.dart';
import 'stock.dart';
import 'property.dart';

class InvestmentCategories extends StatefulWidget {
  const InvestmentCategories({super.key});

  @override
  State<InvestmentCategories> createState() => _InvestmentCategoriesState();
}

class _InvestmentCategoriesState extends State<InvestmentCategories> {
  final List<String> categories = ['Crypto', 'Gold', 'Stocks', 'Property', 'Mutual Funds'];
  String selectedCategory = 'Crypto';
  bool isLoading = true;
  List<dynamic> cryptoData = [];

  @override
  void initState() {
    super.initState();
    fetchCryptoData();
  }

  Future<void> fetchCryptoData() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          cryptoData = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load crypto data");
      }
    } catch (e) {
      print("Error fetching crypto data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Investment Categories", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Category Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategory == category ? Colors.white : Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selectedCategory == category,
                    selectedColor: Colors.blue[900],
                    backgroundColor: Colors.white,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    shape: StadiumBorder(side: BorderSide(color: Colors.blue[900]!)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: getCategoryWidget(selectedCategory),
            ),
          ),
        ],
      ),
    );
  }

   Widget getCategoryWidget(String category) {
    if (category == 'Crypto') {
      return isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cryptoData.length,
              itemBuilder: (context, index) {
                final coin = cryptoData[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(coin['image'], width: 36, height: 36),
                    title: Text("${coin['name']} (${coin['symbol'].toUpperCase()})"),
                    subtitle: Text("Price: \$${coin['current_price']}"),
                    trailing: Text(
                      "${coin['price_change_percentage_24h'].toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: coin['price_change_percentage_24h'] >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
    } else if (category == 'Gold') {
      return const GoldInvestment();  
    } else if (category == 'Stocks') {
      return const StockInvestment();  
    } else if (category == 'Property') {
      return const PropertyInvestment();  
    } else if (category == 'Mutual Funds') {
      return const MutualFundInvestment();  
    }else {
      return Center(
        child: Text("Coming soon: $category", style: const TextStyle(fontSize: 16)),
      );
    }
  }
}
