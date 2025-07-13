import 'package:flutter/material.dart';
import 'halal_stock_detail_page.dart';

class HalalStockTrackerPage extends StatefulWidget {
  const HalalStockTrackerPage({super.key});

  @override
  State<HalalStockTrackerPage> createState() => _HalalStockTrackerPageState();
}

class _HalalStockTrackerPageState extends State<HalalStockTrackerPage> {
  final List<Map<String, dynamic>> mockStocks = [
    {
      "symbol": "ENGRO",
      "name": "Engro Corp",
      "price": 325.50,
      "change": "+1.35%",
      "description": "Engro is a diversified conglomerate in fertilizer, food, energy, etc."
    },
    {
      "symbol": "LUCK",
      "name": "Lucky Cement",
      "price": 785.00,
      "change": "-0.75%",
      "description": "Major cement producer with global exports."
    },
    {
      "symbol": "MEBL",
      "name": "Meezan Bank",
      "price": 162.25,
      "change": "+0.98%",
      "description": "Largest Islamic bank in Pakistan."
    },
    {
      "symbol": "SYS",
      "name": "Systems Ltd",
      "price": 523.40,
      "change": "-0.20%",
      "description": "Leading IT & software firm in Pakistan."
    },
    {
      "symbol": "INDU",
      "name": "Indus Motors",
      "price": 1095.00,
      "change": "+2.10%",
      "description": "Manufacturer & distributor of Toyota vehicles."
    },
  ];

  String searchQuery = '';
  final Set<String> watchlist = {};
  bool showWatchlist = false;

  @override
  Widget build(BuildContext context) {
    final filtered = mockStocks.where((stock) {
      final nameMatch = stock['name'].toLowerCase().contains(searchQuery.toLowerCase());
      final isFav = watchlist.contains(stock['symbol']);
      return showWatchlist ? isFav && nameMatch : nameMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Halal Stock Tracker'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(
            icon: Icon(showWatchlist ? Icons.favorite : Icons.favorite_border),
            tooltip: 'Toggle Watchlist',
            onPressed: () => setState(() => showWatchlist = !showWatchlist),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildStockList(filtered)),
            const SizedBox(height: 12),
            _buildTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Halal Stocks...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildStockList(List<Map<String, dynamic>> stocks) {
    if (stocks.isEmpty) {
      return const Center(child: Text('No matching stocks found.'));
    }

    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final isFav = watchlist.contains(stock['symbol']);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.business_center, color: Colors.teal),
            title: Text('${stock['name']} (${stock['symbol']})'),
            subtitle: Text('Price: PKR ${stock['price']}'),
            trailing: IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey),
              onPressed: () {
                setState(() {
                  if (isFav) {
                    watchlist.remove(stock['symbol']);
                  } else {
                    watchlist.add(stock['symbol']);
                  }
                });
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HalalStockDetailPage(stock: stock),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All stocks follow Islamic finance principles — no riba, no gambling, and ethical businesses.',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
