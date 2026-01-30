import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/helpers/favorite_helpers.dart';

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

  Future<void> _refreshFavorites() async {
    // Simply refetch local favorites (no API)
    await FavoriteService.fetchMyFavorites();
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: FavoriteService.favoriteIds,
        builder: (context, favSet, _) {
          // No favorites case
          if (favSet.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshFavorites,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      "No favorites found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          final favList = FavoriteService.favoritesMap.values.toList();

          return RefreshIndicator(
            onRefresh: _refreshFavorites,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: favList.length,
              itemBuilder: (context, index) {
                return FavoriteHelpers.buildFavoriteCard(
                  context,
                  favList[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
