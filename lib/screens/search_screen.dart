import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/show_provider.dart';
import '../enums/ui_state.dart';
import 'details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Shows")),

      body: Column(
        children: [

          /// SEARCH FIELD
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                provider.searchShows(value);
              },
              decoration: const InputDecoration(
                hintText: "Search shows...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          /// BODY
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ShowProvider provider) {
    switch (provider.state) {

    /// LOADING
      case UIState.loading:
        return const Center(child: CircularProgressIndicator());

    /// ERROR
      case UIState.error:
        return const Center(child: Text("Search failed"));

    /// SUCCESS
      case UIState.success:

      /// EMPTY STATE FIX
        if (provider.searchResults.isEmpty) {
          return const Center(child: Text("No results found"));
        }

        return ListView.builder(
          itemCount: provider.searchResults.length,

          itemBuilder: (context, index) {
            final show = provider.searchResults[index];

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

                            Text("⭐ ${show.rating}"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}