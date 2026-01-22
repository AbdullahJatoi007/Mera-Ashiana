import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/listing_service.dart';
import 'package:mera_ashiana/screens/add_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool _isLoading = true;
  List<Listing> _myListings = [];
  final String _imageBaseUrl = "http://api.staging.mera-ashiana.com";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ListingService.getMyListings();
    if (mounted) {
      setState(() {
        _myListings = data;
        _isLoading = false;
      });
    }
  }

  /// Handles deleting the listing locally first, then on the server
  Future<void> _handleDelete(int index, int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Property"),
        content: const Text(
          "Are you sure you want to delete this rejected property?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Remove from UI immediately for "Instant" feel
      setState(() {
        _myListings.removeAt(index);
      });

      // 2. Execute background delete on server using the 'id' parameter
      final success = await ListingService.deleteListing(id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Property removed successfully")),
          );
        } else {
          // Log server error but keep the item removed from UI to clean up the screen
          debugPrint("Server-side deletion failed for ID: $id");
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Properties"),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddListingScreen()),
        ).then((_) => _loadData()),
        label: const Text("Add Property"),
        icon: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _myListings.isEmpty
                  ? const Center(child: Text("You haven't posted any ads yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: _myListings.length,
                      itemBuilder: (context, index) {
                        final item = _myListings[index];
                        // Using 'status' as defined in your model (mapped from approval_status)
                        final bool isRejected =
                            item.status?.toLowerCase() == 'rejected';

                        String imageUrl = item.images.isNotEmpty
                            ? (item.images[0].startsWith('http')
                                  ? item.images[0]
                                  : "$_imageBaseUrl${item.images[0]}")
                            : "https://via.placeholder.com/150";

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "PKR ${item.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        item.status!,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getStatusColor(item.status!),
                                      ),
                                    ),
                                    child: Text(
                                      item.status!.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(item.status!),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Delete button only for Rejected items
                                  if (isRejected && item.id != null)
                                    GestureDetector(
                                      onTap: () =>
                                          _handleDelete(index, item.id!),
                                      child: const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
