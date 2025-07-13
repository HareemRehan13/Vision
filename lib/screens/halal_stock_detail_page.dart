import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HalalStockDetailPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  const HalalStockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final history = List<double>.from(stock['history'] ?? [310, 320, 325, 330, 325]);
    final int totalShares = stock['totalShares'] ?? 5000;
    final int soldShares = stock['soldShares'] ?? 1500;
    final int availableShares = totalShares - soldShares;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${stock['name']} Details'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCompanyOverview(),
            const SizedBox(height: 12),
            _buildStockTable(context, totalShares, soldShares, availableShares),
            const SizedBox(height: 20),
            _buildDetailCard(context, history, availableShares),
            const SizedBox(height: 20),
            _buildOwnedSharesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyOverview() {
    return Center(
      child: SizedBox(
        width: 500,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏢 Company Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF003366))),
                const SizedBox(height: 10),
                Text(stock['description'] ?? 'No company information provided.', style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockTable(BuildContext context, int total, int sold, int available) {
    return Card(
      color: const Color(0xFFE0F7FA),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFF003366)),
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text('Price', style: TextStyle(color: Colors.white))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Total Shares', style: TextStyle(color: Colors.white))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Sold', style: TextStyle(color: Colors.white))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Available', style: TextStyle(color: Colors.white))),
              ],
            ),
            TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text('PKR ${stock['price']}')),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(total.toString())),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(sold.toString())),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(available.toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, List<double> history, int availableShares) {
    final double price = stock['price'];
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('${stock['name']} (${stock['symbol']})',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Current Price', 'PKR $price'),
            _buildStatRow('Change', stock['change']),
            const Divider(height: 30),
            const Text('📈 7-Day Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.teal,
                      belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.25)),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10))),
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📊 Key Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatRow('Market Cap', stock['marketCap'] ?? 'PKR 180B'),
            _buildStatRow('Volume', stock['volume'] ?? '3.2M'),
            _buildStatRow('PE Ratio', stock['peRatio'] ?? '12.5'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Buy Shares'),
                onPressed: () => _showBuyDialog(context, price, availableShares),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyDialog(BuildContext context, double price, int available) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy Shares of ${stock['symbol']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter number of shares (Max: $available)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final shares = int.tryParse(controller.text);
              if (shares != null && shares > 0 && shares <= available) {
                final totalCost = shares * price;
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final portfolioRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('portfolio');

                  final existing = await portfolioRef
                      .where('symbol', isEqualTo: stock['symbol'])
                      .limit(1)
                      .get();

                  if (existing.docs.isNotEmpty) {
                    final doc = existing.docs.first;
                    final prevShares = (doc['shares'] ?? 0) as int;
                    final prevCost = (doc['totalCost'] ?? 0.0) as num;

                    await doc.reference.update({
                      'shares': prevShares + shares,
                      'totalCost': prevCost + totalCost,
                      'pricePerShare': price,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await portfolioRef.add({
                      'symbol': stock['symbol'],
                      'name': stock['name'],
                      'shares': shares,
                      'pricePerShare': price,
                      'totalCost': totalCost,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  }

                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Purchase Confirmed'),
                      content: Text('You purchased $shares shares for PKR ${totalCost.toStringAsFixed(2)}.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid share amount.')),
                );
              }
            },
            child: const Text('Buy'),
          )
        ],
      ),
    );
  }

  Widget _buildOwnedSharesSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .where('symbol', isEqualTo: stock['symbol'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('You don\'t own any shares of this company.');
        }

        final doc = snapshot.data!.docs.first;
        final shares = (doc['shares'] ?? 0) as int;
        final cost = (doc['totalCost'] ?? 0.0) as num;
        final currentPrice = stock['price'];
        final currentValue = shares * currentPrice;
        final profitLoss = currentValue - cost;

        return Card(
          color: const Color(0xFFDFF0D8),
          margin: const EdgeInsets.only(top: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📋 Your Investment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildStatRow('Owned Shares', shares),
                _buildStatRow('Total Investment', 'PKR ${cost.toStringAsFixed(2)}'),
                _buildStatRow('Current Value', 'PKR ${currentValue.toStringAsFixed(2)}'),
                _buildStatRow('Profit / Loss', 'PKR ${profitLoss.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
