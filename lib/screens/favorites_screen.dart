import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/show_provider.dart';
import 'details_screen.dart';
import '../models/show_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
      ),

      /// BODY WITH CONSUMER
      body: Consumer<ShowProvider>(
        builder: (context, provider, child) {
          final favorites = provider.getFavorites();

          /// EMPTY STATE
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet ❤️",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          /// LIST
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];

              /// SAFE DATA HANDLING
              final show = Show(
                id: item['id'] ?? 0,
                name: item['name'] ?? '',
                image: item['image'] ?? '',
                rating: item['rating'] ?? 0.0,
                genres: const [],
                summary: '',
                url: item['url'] ?? '',
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsScreen(show: show),
                    ),
                  );
                },

                child: Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  elevation: 3,

                  child: Row(
                    children: [

                      /// IMAGE
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: Image.network(
                          show.image,
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,

                          /// ERROR HANDLING
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              width: 100,
                              height: 120,
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// DETAILS
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                show.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text("⭐ Rating: ${show.rating}"),
                            ],
                          ),
                        ),
                      ),

                      /// DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () {
                          provider.toggleFavorite(show);
                        },
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