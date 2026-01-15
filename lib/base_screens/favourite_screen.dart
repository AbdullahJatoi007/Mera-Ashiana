import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the API call when the screen opens
    FavoriteService.fetchMyFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: FavoriteService.favoriteIds,
        builder: (context, favSet, _) {
          if (favSet.isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }

          final favList = FavoriteService.favoritesMap.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final item = favList[index];
              final imageUrl = (item['images'] as List?)?.isNotEmpty == true
                  ? "http://api.staging.mera-ashiana.com${item['images'][0]}"
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(item['title'] ?? "Property"),
                  subtitle: Text("PKR ${item['price'] ?? "N/A"}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () =>
                        FavoriteService.toggleFavorite(item['id'], true),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
