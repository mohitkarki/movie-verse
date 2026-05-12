import 'package:flutter/material.dart';
import '../models/show_model.dart';
import '../services/api_service.dart';
import '../enums/ui_state.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/filter_type.dart';

class ShowProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Show> shows = [];
  List<Show> searchResults = [];

  UIState state = UIState.loading;
  FilterType currentFilter = FilterType.trending;

  /// GET USER-SPECIFIC BOX
  Box getUserBox() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'guest';
    final boxName = 'favorites_$uid';

    if (!Hive.isBoxOpen(boxName)) {
      return Hive.box('favorites_guest'); // fallback safety
    }

    return Hive.box(boxName);
  }

  /// FETCH SHOWS
  Future<void> fetchShows() async {
    try {
      state = UIState.loading;
      notifyListeners();

      shows = await _apiService.fetchShows();

      state = UIState.success;
    } catch (e) {
      state = UIState.error;
    }

    notifyListeners();
  }

  /// SEARCH
  Future<void> searchShows(String query) async {
    if (query.isEmpty) return;

    try {
      state = UIState.loading;
      notifyListeners();

      searchResults = await _apiService.searchShows(query);

      state = UIState.success;
    } catch (e) {
      state = UIState.error;
    }

    notifyListeners();
  }

  /// CHECK FAVORITE
  bool isFavorite(int id) {
    final box = getUserBox();
    return box.containsKey(id);
  }

  /// TOGGLE FAVORITE
  void toggleFavorite(Show show) {
    final box = getUserBox();

    if (box.containsKey(show.id)) {
      box.delete(show.id);
    } else {
      box.put(show.id, {
        'id': show.id,
        'name': show.name,
        'image': show.image,
        'rating': show.rating,
        'url': show.url,
      });
    }

    notifyListeners();
  }

  /// GET FAVORITES LIST
  List<Map<String, dynamic>> getFavorites() {
    final box = getUserBox();
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void setFilter(FilterType filter) {
    currentFilter = filter;
    notifyListeners();
  }

  List<Show> get filteredShows {
    switch (currentFilter) {
      case FilterType.trending:
        return shows;

      case FilterType.popular:
        return shows.where((show) => show.rating >= 7).toList();

      case FilterType.upcoming:
        return shows.where((show) => show.rating < 7).toList();
    }
  }

}