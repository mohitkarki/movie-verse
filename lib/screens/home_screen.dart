import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/show_provider.dart';
import '../enums/ui_state.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'details_screen.dart';
import '../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/filter_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    /// CALL API WHEN SCREEN LOADS
    Future.microtask(() {
      Provider.of<ShowProvider>(context, listen: false).fetchShows();
    });
  }

  @override
  Widget build(BuildContext context) {

    /// GET PROVIDER (STATE MANAGEMENT)
    final provider = Provider.of<ShowProvider>(context);

    return Scaffold(

      /// APP BAR
      appBar: AppBar(
        title: const Text("Movie Verse"),
        actions: [

          /// SEARCH BUTTON → NAVIGATE TO SEARCH SCREEN
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
          ),

          ///  FAVORITES BUTTON
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
          ),

          /// DARK / LIGHT MODE TOGGLE
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),

          /// LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {

              /// CONFIRMATION DIALOG
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content:
                  const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        /// FIREBASE LOGOUT
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      /// BODY HANDLED BY STATE (LOADING / SUCCESS / ERROR)
      body: _buildBody(provider),
    );
  }

  /// HANDLE DIFFERENT STATES
  Widget _buildBody(ShowProvider provider) {

    switch (provider.state) {

    /// LOADING STATE
      case UIState.loading:
        return Center(
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 200,
            height: 200,
          ),
        );

    /// ERROR STATE
      case UIState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.error_outline,
                  size: 60, color: Colors.red),

              const SizedBox(height: 10),

              const Text("Failed to load data"),

              const SizedBox(height: 10),

              /// RETRY BUTTON
              ElevatedButton(
                onPressed: () {
                  provider.fetchShows();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        );

    /// SUCCESS STATE
      case UIState.success:
        return Column(
          children: [

            /// FILTER OPTIONS (TRENDING / POPULAR / UPCOMING)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(provider, "Trending",
                      FilterType.trending),
                  _buildFilterChip(provider, "Popular",
                      FilterType.popular),
                  _buildFilterChip(provider, "Upcoming",
                      FilterType.upcoming),
                ],
              ),
            ),

            /// LIST OF SHOWS
            Expanded(
              child: ListView.builder(
                itemCount: provider.filteredShows.length,

                itemBuilder: (context, index) {
                  final show = provider.filteredShows[index];

                  /// ANIMATION (FADE + SLIDE)
                  return TweenAnimationBuilder(
                    tween: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ),
                    duration: Duration(
                        milliseconds: 400 + (index * 100)),

                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: Offset(0, offset.dy * 50),

                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: Duration(
                              milliseconds:
                              400 + (index * 100)),
                          child: child,
                        ),
                      );
                    },

                    /// 🔥 CLICKABLE CARD
                    child: GestureDetector(
                      onTap: () {

                        /// NAVIGATE TO DETAILS SCREEN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailsScreen(show: show),
                          ),
                        );
                      },

                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        elevation: 4,

                        child: Row(
                          children: [

                            /// IMAGE + HERO ANIMATION
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft:
                                Radius.circular(12),
                              ),
                              child: Hero(
                                tag: show.id,
                                child: Image.network(
                                  show.image,
                                  width: 100,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// SHOW DETAILS
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    /// 🎬 TITLE
                                    Text(
                                      show.name,
                                      style:
                                      const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    /// ⭐ RATING
                                    Text(
                                        "⭐ Rating: ${show.rating}"),

                                    /// FAVORITE BUTTON
                                    IconButton(
                                      icon: Icon(
                                        provider.isFavorite(
                                            show.id)
                                            ? Icons.favorite
                                            : Icons
                                            .favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        provider
                                            .toggleFavorite(
                                            show);
                                      },
                                    ),
                                  ],
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
          ],
        );
    }
  }

  /// FILTER CHIP UI
  Widget _buildFilterChip(
      ShowProvider provider, String label, FilterType type) {

    final isSelected = provider.currentFilter == type;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),

      child: ChoiceChip(
        label: Text(label),

        /// SELECTED STATE
        selected: isSelected,

        /// CHANGE FILTER
        onSelected: (_) {
          provider.setFilter(type);
        },
      ),
    );
  }
}