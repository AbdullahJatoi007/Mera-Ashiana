import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/features/properties/screens/add_listing_screen.dart';
import 'package:mera_ashiana/core/utils/currency_formatter.dart'; // 🌟 Added import
import 'package:mera_ashiana/core/theme/app_colors.dart'; // 🌟 Added for consistent theme colors
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<Listing> _listings = [];
  bool _isLoading = true;
  final String _imageBaseUrl = "https://api-staging.mera-ashiana.com";

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$_imageBaseUrl/api/properties"),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        setState(() {
          _listings = data.map((json) => Listing.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Properties"),
        actions: [
          IconButton(
            onPressed: _fetchListings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddListingScreen()),
        ).then((_) => _fetchListings()),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _listings.length,
              itemBuilder: (context, index) =>
                  _buildListingCard(_listings[index]),
            ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    String imageUrl = 'https://via.placeholder.com/300x200?text=No+Image';
    if (listing.images.isNotEmpty) {
      String path = listing.images[0];
      // 🔧 FIX: Check if it's already a full URL (like in your other screens)
      // before manually appending the base URL string.
      if (path.startsWith('http://') || path.startsWith('https://')) {
        imageUrl = path;
      } else {
        imageUrl = "$_imageBaseUrl${path.startsWith('/') ? '' : '/'}$path";
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatPakistaniPrice(listing.price),
                  // ✨ Dynamic formatting
                  style: const TextStyle(
                    color: AppColors.accentYellow,
                    // Matches your app's yellow accent brand theme
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
