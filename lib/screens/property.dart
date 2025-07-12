import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PropertyInvestment extends StatefulWidget {
  const PropertyInvestment({super.key});
  @override State<PropertyInvestment> createState() => _PropertyInvestmentState();
}

class _PropertyInvestmentState extends State<PropertyInvestment> {
  final String apiKey = '71e56eca4a814a6ebf54cb69570d6785';
  final String baseUrl = 'https://api.rentcast.io/v1'; // example
  bool isLoading = true, isError = false;
  List<dynamic> listings = [];

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

 Future<void> fetchProperties() async {
  setState(() { isLoading = true; isError = false; });

  final url = Uri.parse('https://api.rentcast.io/v1/listings/sale?city=Karachi&state=SD&status=Active&limit=5');

  try {
    final response = await http.get(url, headers: {
      'X-Api-Key': apiKey,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        listings = data['listings'] ?? [];
        isLoading = false;
      });
    } else {
      throw Exception('Invalid response: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching properties: $e');
    setState(() { isError = true; isLoading = false; });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Investment')),
      body: RefreshIndicator(
        onRefresh: fetchProperties,
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? _buildError()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (_, i) => _buildPropertyCard(listings[i]),
                ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(child: Column(
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load properties'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: fetchProperties, child: const Text('Retry'))
          ],
        )),
      ],
    );
  }

  Widget _buildPropertyCard(dynamic prop) {
    final imageUrl = prop['images']?.first ?? '';
    final price = prop['price'];
    final area = prop['area'];
    final address = prop['address'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // on tap: open property detail
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(address ?? '–', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Price: ₨${price?.toStringAsFixed(0)}/PKR', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 4),
              Text('Area: ${area ?? '–'} sq ft', style: const TextStyle(color: Colors.grey)),
            ]),
          )
        ]),
      ),
    );
  }
}
