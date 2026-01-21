import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
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
            return const Center(child: Text("No favorites found."));
          }

          final favList = FavoriteService.favoritesMap.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final PropertyModel item = favList[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // Navigate to details if needed
                  },
                  child: Column(
                    children: [
                      if (item.images.isNotEmpty)
                        Image.network(
                          item.images[0],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ListTile(
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("PKR ${item.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () =>
                              FavoriteService.toggleFavorite(item.id, true),
                        ),
                      ),
                    ],
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
